import 'dart:io';

import 'step_model.dart';

class ScenarioReport {
  ScenarioReport({
    required this.name,
    required this.status,
    required this.startedAt,
    required this.endedAt,
    required this.duration,
    required this.steps,
  });

  final String name;
  final String status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final Duration? duration;
  final List<StepReport> steps;

  bool get passed => status.toLowerCase() == 'passed';
  int get totalSteps => steps.length;
  int get passedSteps => steps.where((step) => step.passed).length;
  int get failedSteps => totalSteps - passedSteps;

  bool get hasGoldenComparisons =>
      steps.any((step) => step.goldenComparisons.isNotEmpty);

  factory ScenarioReport.fromJson(
    Map<String, dynamic> json, {
    required Directory reportDirectory,
  }) {
    final stepsJson = json['steps'];
    final steps = (stepsJson is List)
        ? stepsJson
            .whereType<Map>()
            .map((value) => value.cast<String, dynamic>())
            .map(
              (value) => StepReport.fromJson(
                value,
                reportDirectory: reportDirectory,
              ),
            )
            .toList()
        : <StepReport>[];

    final startedAt = _parseDate(json['startedAt']);
    final endedAt = _parseDate(json['endedAt']);
    final duration = _parseDuration(
      json['durationMs'],
      fallback: _differenceOrNull(startedAt, endedAt),
    );

    return ScenarioReport(
      name: json['name']?.toString() ?? 'Unnamed Scenario',
      status: json['status']?.toString() ?? 'unknown',
      startedAt: startedAt,
      endedAt: endedAt,
      duration: duration,
      steps: steps,
    );
  }
}

Duration? _differenceOrNull(DateTime? start, DateTime? end) {
  if (start == null || end == null) {
    return null;
  }
  return end.difference(start);
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
