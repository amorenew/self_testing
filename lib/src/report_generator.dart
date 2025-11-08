import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:self_testing/src/testing_manager.dart';
import 'package:self_testing/src/testing_report_models.dart';

/// Loads and caches testing report data for Flutter presentation.
///
/// The previous HTML generator wrote a static HTML file. This class now reads
/// the JSON results produced during the test run and converts them into domain
/// objects that can be rendered by Flutter widgets such as [TestingReportPage].
class ReportGenerator {
  ReportGenerator._();

  static TestingReportData? _cachedReport;

  /// Legacy entrypoint retained for backwards compatibility.
  ///
  /// Instead of generating HTML, the method now refreshes the cached
  /// [TestingReportData] so that UI layers can display the report with Flutter
  /// widgets.
  static Future<void> generateHtmlReport() async {
    try {
      final report = await loadReportData();
      _cachedReport = report;
      debugPrint(
        '✅ Testing report refreshed with ${report.scenarios.length} scenario(s).',
      );
    } on Object catch (error, stackTrace) {
      debugPrint(
        '⚠️ Failed to refresh testing report data: $error\n$stackTrace',
      );
    }
  }

  /// Loads the latest testing report from disk and returns strongly typed
  /// models for Flutter rendering.
  static Future<TestingReportData> loadReportData() async {
    final resultsFile = await _resolveResultsFile();
    if (!await resultsFile.exists()) {
      throw StateError('Test results file not found at ${resultsFile.path}');
    }

    final rawContent = await resultsFile.readAsString();

    dynamic decoded;
    try {
      decoded = jsonDecode(rawContent);
    } on Object catch (error) {
      throw FormatException('Unable to parse test results JSON: $error');
    }

    if (decoded is! List) {
      throw FormatException('Test results JSON must be a list of scenarios.');
    }

    final scenarios = decoded
        .whereType<Map>()
        .map(
          (value) => Map<String, dynamic>.from(
            value.cast<String, dynamic>(),
          ),
        )
        .toList(growable: false);

    final reportDirectory = resultsFile.parent;
    return TestingReportData.fromJson(
      scenarios,
      reportDirectory: reportDirectory,
    );
  }

  /// Returns the most recently cached report data.
  static TestingReportData? get cachedReport => _cachedReport;

  /// Clears the cached report forcing the next access to reload from disk.
  static void clearCache() {
    _cachedReport = null;
  }

  /// Checks whether a results file is present on disk.
  static Future<bool> hasReportFile() async {
    final file = await _resolveResultsFile();
    return file.exists();
  }

  static Future<File> _resolveResultsFile() async {
    final projectRoot = SelfTesting.projectRootDirectory;
    final reportDirectory = Directory('${projectRoot.path}/report');
    if (!await reportDirectory.exists()) {
      await reportDirectory.create(recursive: true);
    }
    return File('${reportDirectory.path}/test_results.json');
  }
}
