import 'dart:io';

import 'golden_model.dart';
import 'screenshot_model.dart';

class StepReport {
  StepReport({
    required this.name,
    required this.status,
    required this.finishedAt,
    required this.duration,
    required this.error,
    required this.details,
    required this.screenshots,
    required this.goldenComparisons,
  });

  final String name;
  final String status;
  final DateTime? finishedAt;
  final Duration? duration;
  final String? error;
  final List<String> details;
  final List<ReportScreenshot> screenshots;
  final List<GoldenComparison> goldenComparisons;

  bool get passed => status.toLowerCase() == 'passed';

  factory StepReport.fromJson(
    Map<String, dynamic> json, {
    required Directory reportDirectory,
  }) {
    final rawDetails = json['details'];
    final details = (rawDetails is List)
        ? rawDetails
            .map((value) => value.toString().trim())
            .where((value) => value.isNotEmpty)
            .toList()
        : <String>[];

    final rawScreenshots = json['screenshots'];
    final screenshots = (rawScreenshots is List)
        ? rawScreenshots
            .map((value) => ReportScreenshot.tryParse(
                  value,
                  reportDirectory: reportDirectory,
                ))
            .whereType<ReportScreenshot>()
            .toList()
        : <ReportScreenshot>[];

    final goldenRaw = json['golden'];
    final goldenComparisons = _extractGoldenEntries(goldenRaw)
        .map(
          (value) => GoldenComparison.fromJson(
            value,
            reportDirectory: reportDirectory,
          ),
        )
        .toList();

    return StepReport(
      name: json['name']?.toString() ?? 'Unnamed Step',
      status: json['status']?.toString() ?? 'unknown',
      finishedAt: _parseDate(json['timestamp']),
      duration: _parseDuration(
        json['durationMs'],
        fallback: null,
      ),
      error: json['error']?.toString(),
      details: details,
      screenshots: screenshots,
      goldenComparisons: goldenComparisons,
    );
  }
}

List<Map<String, dynamic>> _extractGoldenEntries(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return [raw];
  }
  if (raw is Map) {
    return [raw.cast<String, dynamic>()];
  }
  if (raw is Iterable) {
    return raw
        .whereType<Map>()
        .map((value) => value.cast<String, dynamic>())
        .toList();
  }
  return const [];
}

Duration? _parseDuration(dynamic raw, {Duration? fallback}) {
  if (raw is int) {
    return Duration(milliseconds: raw);
  }
  if (raw is double) {
    return Duration(milliseconds: raw.round());
  }
  return fallback;
}

DateTime? _parseDate(dynamic raw) {
  if (raw == null) {
    return null;
  }
  if (raw is DateTime) {
    return raw;
  }
  if (raw is num) {
    return DateTime.fromMillisecondsSinceEpoch(raw.toInt(), isUtc: true)
        .toLocal();
  }
  final value = raw.toString();
  if (value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toLocal();
}
