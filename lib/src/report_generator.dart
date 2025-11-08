import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:self_testing/src/report_builders.dart';
import 'package:self_testing/src/report_helpers.dart';
import 'package:self_testing/src/templates/html_template.dart';

class ReportGenerator {
  static Future<void> generateHtmlReport() async {
    final resultsFile = File('report/test_results.json');
    if (!await resultsFile.exists()) {
      debugPrint('❌ Test results file not found!');
      return;
    }

    final resultsJson = await resultsFile.readAsString();
    final results = List<Map<String, dynamic>>.from(jsonDecode(resultsJson));

    final html = _buildHtml(results);

    final reportFile = File('report/test_report.html');
    await reportFile.writeAsString(html);

    debugPrint('✅ HTML report generated at: ${reportFile.absolute.path}');
  }

  static String _buildHtml(List<Map<String, dynamic>> results) {
    final scenarios = results;
    final allSteps =
        scenarios.map(extractSteps).expand((steps) => steps).toList();

    final totalTests = allSteps.length;
    final passedTests =
        allSteps.where((step) => step['status'] == 'passed').length;
    final failedTests = totalTests - passedTests;
    final successRate = totalTests > 0
        ? (passedTests / totalTests * 100).toStringAsFixed(1)
        : '0.0';

    final scenarioCards = scenarios
        .asMap()
        .entries
        .map((entry) => buildScenarioCard(entry.value, index: entry.key))
        .join('\n');

    final totalScenarios = scenarios.length;
    final runStart = findBoundaryTimestamp(
      scenarios,
      'startedAt',
      findEarliest: true,
    );
    final runEnd = findBoundaryTimestamp(
      scenarios,
      'endedAt',
      findEarliest: false,
    );
    final runStartLabel =
        runStart != null ? formatDateTime(runStart.toIso8601String()) : 'N/A';
    final runEndLabel =
        runEnd != null ? formatDateTime(runEnd.toIso8601String()) : 'N/A';

    final hasDurationData = scenarios.any(
      (scenario) => scenario['durationMs'] != null,
    );
    final totalDurationMs = hasDurationData
        ? scenarios
            .map((scenario) => scenario['durationMs'])
            .whereType<num>()
            .fold<int>(0, (sum, value) => sum + value.toInt())
        : 0;
    final totalDurationLabel =
        hasDurationData ? formatDuration(totalDurationMs) : 'N/A';

    final goldenEntries = allSteps
        .map((step) => normalizeGoldenEntries(step['golden']))
        .expand((entries) => entries)
        .toList();

    final goldenDiffs = goldenEntries
        .map((golden) => golden['diffPercentage'])
        .whereType<num>()
        .map((value) => value.toDouble())
        .toList();

    final avgGoldenDiff = goldenDiffs.isNotEmpty
        ? goldenDiffs.reduce((a, b) => a + b) / goldenDiffs.length
        : null;

    final goldenStatCard = goldenEntries.isNotEmpty
        ? '''
                <div class="stat-card golden">
                    <h3>${formatPercent(avgGoldenDiff)}</h3>
                    <p>Avg Golden Diff</p>
                </div>
        '''
        : '';

    return htmlTemplate(
      runStartLabel: runStartLabel,
      runEndLabel: runEndLabel,
      totalScenarios: totalScenarios,
      totalTests: totalTests,
      passedTests: passedTests,
      failedTests: failedTests,
      successRate: successRate,
      totalDurationLabel: totalDurationLabel,
      goldenStatCard: goldenStatCard,
      scenarioCards: scenarioCards,
    );
  }
}
