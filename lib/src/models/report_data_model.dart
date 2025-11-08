import 'dart:io';

import 'scenario_model.dart';

/// Aggregated data for rendering a testing report with Flutter widgets.
class TestingReportData {
  TestingReportData({
    required this.scenarios,
    required this.reportDirectory,
    this.runStart,
    this.runEnd,
    this.totalDuration,
    required this.totalSteps,
    required this.passedSteps,
    required this.failedSteps,
    this.averageGoldenDiff,
  });

  final List<ScenarioReport> scenarios;
  final Directory reportDirectory;
  final DateTime? runStart;
  final DateTime? runEnd;
  final Duration? totalDuration;
  final int totalSteps;
  final int passedSteps;
  final int failedSteps;
  final double? averageGoldenDiff;

  double get successRate =>
      totalSteps == 0 ? 0 : passedSteps / totalSteps * 100.0;

  bool get hasGoldenComparisons =>
      scenarios.any((scenario) => scenario.hasGoldenComparisons);

  factory TestingReportData.fromJson(
    List<Map<String, dynamic>> json, {
    required Directory reportDirectory,
  }) {
    final scenarios = json
        .map(
          (value) => ScenarioReport.fromJson(
            value,
            reportDirectory: reportDirectory,
          ),
        )
        .toList(growable: false);

    final allSteps = scenarios.expand((scenario) => scenario.steps).toList();
    final totalSteps = allSteps.length;
    final passedSteps = allSteps.where((step) => step.passed).length;
    final failedSteps = totalSteps - passedSteps;

    final runStart = _findBoundary(allScenarios: scenarios, earliest: true);
    final runEnd = _findBoundary(allScenarios: scenarios, earliest: false);
    final totalDuration =
        runStart != null && runEnd != null ? runEnd.difference(runStart) : null;

    final goldenDiffs = <double>[];
    for (final step in allSteps) {
      for (final comparison in step.goldenComparisons) {
        if (comparison.diffPercentage != null) {
          goldenDiffs.add(comparison.diffPercentage!);
        }
      }
    }

    final averageGoldenDiff = goldenDiffs.isNotEmpty
        ? goldenDiffs.reduce((a, b) => a + b) / goldenDiffs.length
        : null;

    return TestingReportData(
      scenarios: scenarios,
      reportDirectory: reportDirectory,
      runStart: runStart,
      runEnd: runEnd,
      totalDuration: totalDuration,
      totalSteps: totalSteps,
      passedSteps: passedSteps,
      failedSteps: failedSteps,
      averageGoldenDiff: averageGoldenDiff,
    );
  }
}

DateTime? _findBoundary({
  required List<ScenarioReport> allScenarios,
  required bool earliest,
}) {
  DateTime? boundary;
  for (final scenario in allScenarios) {
    final candidate = earliest ? scenario.startedAt : scenario.endedAt;
    if (candidate == null) continue;
    if (boundary == null) {
      boundary = candidate;
      continue;
    }
    final shouldReplace =
        earliest ? candidate.isBefore(boundary) : candidate.isAfter(boundary);
    if (shouldReplace) {
      boundary = candidate;
    }
  }
  return boundary;
}
