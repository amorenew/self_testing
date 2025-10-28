import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:diff_image2/diff_image2.dart';
import 'package:flutter/rendering.dart';
import 'package:self_testing/src/testing_manager.dart';

class ScreenshotHelper {
  ScreenshotHelper._();

  static final Map<String, List<Map<String, dynamic>>> _goldenMetadata = {};
  static final Map<String, List<String>> _aliasLookup = {};

  static Future<void> captureAndSend(
    String name, {
    double? tolerance,
    List<String> aliases = const [],
  }) async {
    try {
      final screenshotContext = SelfTesting.screenshotKey.currentContext;
      if (screenshotContext == null) {
        throw StateError('Screenshot key context is unavailable.');
      }

      final boundary =
          screenshotContext.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final fileName = _ensurePngExtension(name);

      if (SelfTesting.useLocalStorage) {
        final screenshotsDir = await _ensureScreenshotsDirectory();
        final screenshotFile = File('${screenshotsDir.path}/$fileName');
        await screenshotFile.writeAsBytes(pngBytes);
        debugPrint('✅ Screenshot saved locally at: ${screenshotFile.path}');

        await _handleGoldenComparison(
          name: name,
          actualFile: screenshotFile,
          tolerance: tolerance ?? SelfTesting.goldenDiffTolerance,
          aliases: aliases,
        );
        return;
      }

      await Dio().post(
        'https://api.example.com/screenshots',
        data: FormData.fromMap({
          'name': name,
          'file': MultipartFile.fromBytes(pngBytes, filename: fileName),
        }),
      );

      debugPrint('✅ Screenshot $name sent successfully.');
    } catch (e) {
      debugPrint('❌ Screenshot $name failed: $e');
      rethrow;
    }
  }

  static Map<String, dynamic>? consumeGoldenMetadata(String key) {
    final attempts = <String>{key, key.split('/').last};

    for (final attempt in attempts) {
      final normalized = _normalizeKey(attempt);
      while (true) {
        final queue = _aliasLookup[normalized];
        final canonical =
            queue != null && queue.isNotEmpty ? queue.first : normalized;
        final entries = _goldenMetadata[canonical];

        if (entries != null && entries.isNotEmpty) {
          final metadata = entries.removeAt(0);
          if (queue != null && queue.isNotEmpty) {
            queue.removeAt(0);
            if (queue.isEmpty) {
              _aliasLookup.remove(normalized);
            }
          }
          if (entries.isEmpty) {
            _goldenMetadata.remove(canonical);
            _purgeCanonicalFromAliases(canonical);
          }
          return Map<String, dynamic>.from(metadata);
        }

        if (queue != null && queue.isNotEmpty) {
          queue.removeAt(0);
          if (queue.isEmpty) {
            _aliasLookup.remove(normalized);
          }
          continue;
        }

        break;
      }
    }

    return null;
  }

  static Future<Directory> _ensureScreenshotsDirectory() async {
    final directory = Directory(
      '${SelfTesting.projectRootPath}/report/screenshots',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static Future<void> _handleGoldenComparison({
    required String name,
    required File actualFile,
    required double tolerance,
    required List<String> aliases,
  }) async {
    final normalizedKey = _normalizeKey(name);
    final screenshotFileName = _ensurePngExtension(name);
    final goldenDir = await _ensureGoldenDirectory();
    final diffDir = await _ensureDiffDirectory();
    final goldenFile = File('${goldenDir.path}/$screenshotFileName');

    final metadata = <String, dynamic>{
      'id': normalizedKey,
      'name': name,
      'screenshot': screenshotFileName,
      'actualImage': 'screenshots/$screenshotFileName',
      'actualImageAbsolute': actualFile.path,
      'tolerance': tolerance,
      'recordedAt': DateTime.now().toIso8601String(),
    };

    final shouldCreateBaseline =
        SelfTesting.updateGoldenBaselines || !await goldenFile.exists();
    if (shouldCreateBaseline) {
      await actualFile.copy(goldenFile.path);

      final status = SelfTesting.updateGoldenBaselines
          ? 'baselineUpdated'
          : 'baselineCreated';

      metadata.addAll({
        'status': status,
        'baselineCreated': !SelfTesting.updateGoldenBaselines,
        'baselineUpdated': SelfTesting.updateGoldenBaselines,
        'goldenImage': 'goldens/$screenshotFileName',
        'goldenImageAbsolute': goldenFile.path,
        'diffPercentage': 0.0,
      });

      _storeGoldenMetadata(normalizedKey, metadata, aliases);

      final baselineStatus =
          SelfTesting.updateGoldenBaselines ? 'updated' : 'created';
      debugPrint(
        '⭐️ Golden baseline $baselineStatus for $name at ${goldenFile.path}',
      );
      return;
    }

    try {
      final result = await DiffImage.compareFromFile(
        goldenFile,
        actualFile,
        asPercentage: true,
        ignoreAlpha: false,
      );

      final diffPercentage = result.diffValue.toDouble();
      final diffFileName = '${normalizedKey}_diff.png';
      final diffFile = await DiffImage.saveImage(
        image: result.diffImage,
        name: diffFileName,
        directory: diffDir.path,
      );

      metadata.addAll({
        'status': diffPercentage > tolerance ? 'mismatch' : 'match',
        'baselineCreated': false,
        'baselineUpdated': false,
        'goldenImage': 'goldens/$screenshotFileName',
        'goldenImageAbsolute': goldenFile.path,
        'diffPercentage': double.parse(diffPercentage.toStringAsFixed(2)),
        'diffImage': 'diffs/$diffFileName',
        'diffImageAbsolute': diffFile.path,
      });

      _storeGoldenMetadata(normalizedKey, metadata, aliases);

      debugPrint(
        '📐 Golden diff for $name: ${diffPercentage.toStringAsFixed(2)}% (tolerance ${tolerance.toStringAsFixed(2)}%)',
      );

      if (diffPercentage > tolerance) {
        throw GoldenMismatchException(
          name: name,
          diffPercentage: diffPercentage,
          tolerance: tolerance,
          diffImagePath: diffFile.path,
        );
      }
    } on GoldenMismatchException {
      rethrow;
    } catch (error) {
      final exception = GoldenComparisonException(name: name, cause: error);
      metadata.addAll({
        'status': 'error',
        'baselineCreated': false,
        'baselineUpdated': false,
        'goldenImage': 'goldens/$screenshotFileName',
        'goldenImageAbsolute': goldenFile.path,
        'error': exception.toString(),
      });
      _storeGoldenMetadata(normalizedKey, metadata, aliases);
      throw exception;
    }
  }

  static Future<Directory> _ensureGoldenDirectory() async {
    final directory = Directory(
      '${SelfTesting.projectRootPath}/report/goldens',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static Future<Directory> _ensureDiffDirectory() async {
    final directory = Directory(
      '${SelfTesting.projectRootPath}/report/diffs',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static String _normalizeKey(String value) {
    var normalized = value.toLowerCase().trim();
    if (normalized.contains('/')) {
      normalized = normalized.split('/').last;
    }
    normalized = normalized.replaceAll(
      RegExp(r'\.(png|jpg|jpeg)$', caseSensitive: false),
      '',
    );
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    normalized = normalized.replaceAll(RegExp(r'_+'), '_');
    normalized = normalized.replaceAll(RegExp(r'^_+|_+$'), '');
    return normalized.isEmpty ? value.toLowerCase() : normalized;
  }

  static String _ensurePngExtension(String name) {
    return name.toLowerCase().endsWith('.png') ? name : '$name.png';
  }

  static void _storeGoldenMetadata(
    String key,
    Map<String, dynamic> metadata,
    List<String> aliases,
  ) {
    final canonical = _normalizeKey(key);
    final entry = Map<String, dynamic>.from(metadata);
    final list = _goldenMetadata.putIfAbsent(
      canonical,
      () => <Map<String, dynamic>>[],
    );
    list.add(entry);

    final canonicalQueue = _aliasLookup.putIfAbsent(
      canonical,
      () => <String>[],
    );
    canonicalQueue.add(canonical);

    for (final alias in aliases) {
      final normalized = _normalizeKey(alias);
      if (normalized == canonical) {
        continue;
      }
      final queue = _aliasLookup.putIfAbsent(normalized, () => <String>[]);
      queue.add(canonical);
    }
  }

  static void _purgeCanonicalFromAliases(String canonical) {
    final keysToRemove = <String>[];
    _aliasLookup.forEach((alias, queue) {
      queue.removeWhere((value) => value == canonical);
      if (queue.isEmpty) {
        keysToRemove.add(alias);
      }
    });

    for (final alias in keysToRemove) {
      _aliasLookup.remove(alias);
    }
  }
}

class GoldenComparisonException implements Exception {
  GoldenComparisonException({required this.name, required this.cause});

  final String name;
  final Object cause;

  @override
  String toString() => 'Golden comparison for $name failed: $cause';
}

class GoldenMismatchException extends GoldenComparisonException {
  GoldenMismatchException({
    required super.name,
    required this.diffPercentage,
    required this.tolerance,
    this.diffImagePath,
  }) : super(
          cause:
              'diff ${diffPercentage.toStringAsFixed(2)}% > tolerance ${tolerance.toStringAsFixed(2)}%',
        );

  final double diffPercentage;
  final double tolerance;
  final String? diffImagePath;

  @override
  String toString() {
    final diffPart = diffPercentage.toStringAsFixed(2);
    final tolerancePart = tolerance.toStringAsFixed(2);
    final diffPathPart =
        diffImagePath != null ? ' (diff image: $diffImagePath)' : '';
    return 'Golden diff exceeded for $name: $diffPart% > $tolerancePart%$diffPathPart';
  }
}
