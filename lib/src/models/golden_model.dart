import 'dart:io';

import 'screenshot_model.dart';

class GoldenComparison {
  GoldenComparison({
    required this.id,
    required this.status,
    required this.diffPercentage,
    required this.tolerance,
    required this.actual,
    required this.baseline,
    required this.diff,
    this.note,
    this.links = const [],
    this.errorMessage,
  });

  final String id;
  final GoldenStatus status;
  final double? diffPercentage;
  final double? tolerance;
  final ReportScreenshot? actual;
  final ReportScreenshot? baseline;
  final ReportScreenshot? diff;
  final String? note;
  final List<String> links;
  final String? errorMessage;

  String get statusLabel {
    switch (status) {
      case GoldenStatus.match:
        return 'Match';
      case GoldenStatus.mismatch:
        return 'Mismatch';
      case GoldenStatus.baselineCreated:
        return 'Baseline Created';
      case GoldenStatus.baselineUpdated:
        return 'Baseline Updated';
      case GoldenStatus.error:
        return 'Error';
      case GoldenStatus.unknown:
        return 'Unknown';
    }
  }

  factory GoldenComparison.fromJson(
    Map<String, dynamic> json, {
    required Directory reportDirectory,
  }) {
    final linksRaw = json['links'];
    final links = (linksRaw is List)
        ? linksRaw.map((value) => value.toString()).toList()
        : const <String>[];

    final noteRaw = json['note'] ?? json['message'];

    return GoldenComparison(
      id: json['id']?.toString() ?? 'golden',
      status: _parseGoldenStatus(json['status']?.toString()),
      diffPercentage: _parseDouble(json['diffPercentage']),
      tolerance: _parseDouble(json['tolerance']),
      actual: ReportScreenshot.tryParse(
        json['actualImage'] ?? json['actual'],
        reportDirectory: reportDirectory,
      ),
      baseline: ReportScreenshot.tryParse(
        json['goldenImage'] ?? json['baseline'],
        reportDirectory: reportDirectory,
      ),
      diff: ReportScreenshot.tryParse(
        json['diffImage'] ?? json['diff'],
        reportDirectory: reportDirectory,
      ),
      note: noteRaw?.toString(),
      links: links,
      errorMessage: json['error']?.toString(),
    );
  }
}

enum GoldenStatus {
  match,
  mismatch,
  baselineCreated,
  baselineUpdated,
  error,
  unknown,
}

GoldenStatus _parseGoldenStatus(String? raw) {
  if (raw == null || raw.isEmpty) {
    return GoldenStatus.unknown;
  }
  final normalized = raw.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
  switch (normalized) {
    case 'match':
      return GoldenStatus.match;
    case 'mismatch':
      return GoldenStatus.mismatch;
    case 'baselinecreated':
      return GoldenStatus.baselineCreated;
    case 'baselineupdated':
      return GoldenStatus.baselineUpdated;
    case 'error':
      return GoldenStatus.error;
    default:
      return GoldenStatus.unknown;
  }
}

double? _parseDouble(dynamic raw) {
  if (raw == null) {
    return null;
  }
  if (raw is num) {
    return raw.toDouble();
  }
  if (raw is String) {
    return double.tryParse(raw);
  }
  return null;
}
