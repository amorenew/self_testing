import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class ReportGenerator {
  static Future<void> generateHtmlReport() async {
    // Read test results
    final resultsFile = File('report/test_results.json');
    if (!await resultsFile.exists()) {
      debugPrint('❌ Test results file not found!');
      return;
    }

    final resultsJson = await resultsFile.readAsString();
    final results = List<Map<String, dynamic>>.from(jsonDecode(resultsJson));

    // Generate HTML
    final html = _buildHtml(results);

    // Save HTML report
    final reportFile = File('report/test_report.html');
    await reportFile.writeAsString(html);

    debugPrint('✅ HTML report generated at: ${reportFile.absolute.path}');
  }

  static String _buildHtml(List<Map<String, dynamic>> results) {
    final scenarios = results;
    final allSteps =
        scenarios.map(_extractSteps).expand((steps) => steps).toList();

    final totalTests = allSteps.length;
    final passedTests =
        allSteps.where((step) => step['status'] == 'passed').length;
    final failedTests = totalTests - passedTests;
    final successRate = totalTests > 0
        ? (passedTests / totalTests * 100).toStringAsFixed(1)
        : '0.0';

    final scenarioCards = scenarios.asMap().entries
        .map((entry) => _buildScenarioCard(entry.value, index: entry.key))
        .join('\n');

    final totalScenarios = scenarios.length;
    final runStart = _findBoundaryTimestamp(
      scenarios,
      'startedAt',
      findEarliest: true,
    );
    final runEnd = _findBoundaryTimestamp(
      scenarios,
      'endedAt',
      findEarliest: false,
    );
    final runStartLabel =
        runStart != null ? _formatDateTime(runStart.toIso8601String()) : 'N/A';
    final runEndLabel =
        runEnd != null ? _formatDateTime(runEnd.toIso8601String()) : 'N/A';

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
        hasDurationData ? _formatDuration(totalDurationMs) : 'N/A';

    final goldenEntries = allSteps
        .map((step) => _normalizeGoldenEntries(step['golden']))
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
                    <h3>${_formatPercent(avgGoldenDiff)}</h3>
                    <p>Avg Golden Diff</p>
                </div>
        '''
        : '';

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Report - Flutter Self Testing</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 1rem 0;
        }

        .container {
            width: calc(100% - 40px);
            margin: 0 20px;
        }

        .header {
            background: white;
            border-radius: 16px;
            padding: 1.1rem;
            margin-bottom: 1rem;
            box-shadow: 0 16px 50px rgba(0, 0, 0, 0.28);
        }

        .header-top {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            flex-wrap: wrap;
            margin-bottom: 0.75rem;
        }

        .header h1 {
            font-size: 1.2rem;
            color: #2d3748;
            margin-bottom: 0;
            display: flex;
            align-items: center;
            gap: 0.6rem;
        }

        .header h1::before {
            content: '🧪';
            font-size: 1.5rem;
        }

        .header-timestamps {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            margin-left: auto;
            justify-content: flex-end;
            flex-wrap: wrap;
        }

        .header-chip {
            background: rgba(236, 241, 248, 0.9);
            padding: 0.3rem 0.6rem;
            border-radius: 16px;
            font-size: 0.64rem;
            font-weight: 600;
            color: #2d3748;
            box-shadow: 0 6px 18px rgba(76, 81, 191, 0.1);
            display: inline-flex;
            align-items: center;
            gap: 0.28rem;
            letter-spacing: 0.35px;
            white-space: nowrap;
        }

        .header-chip .chip-label {
            font-size: 0.52rem;
            text-transform: uppercase;
            letter-spacing: 0.55px;
            color: #5a6b82;
        }

        .header-chip .chip-value {
            font-size: 0.7rem;
            color: #1a202c;
        }

        .stats {
            display: flex;
            flex-wrap: wrap;
            gap: 0.45rem;
            margin-top: 0.75rem;
        }

        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 0.4rem 0.75rem;
            border-radius: 999px;
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.18);
            transition: transform 0.2s, box-shadow 0.2s;
            min-height: 2.1rem;
        }

        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 24px rgba(0, 0, 0, 0.22);
        }

        .stat-card.passed {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        }

        .stat-card.failed {
            background: linear-gradient(135deg, #ee0979 0%, #ff6a00 100%);
        }

        .stat-card.golden {
            background: linear-gradient(135deg, #f6d365 0%, #fda085 100%);
            color: #553c02;
        }

        .stat-card h3 {
            font-size: 0.95rem;
            font-weight: 700;
            margin: 0;
        }

        .stat-card p {
            font-size: 0.58rem;
            opacity: 0.9;
            text-transform: uppercase;
            letter-spacing: 0.85px;
            margin: 0;
        }

        .scenario-list {
            display: grid;
            gap: 1.15rem;
        }

        .scenario-card,
        .test-card {
            background: white;
            border-radius: 18px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .scenario-card:hover,
        .test-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 30px 80px rgba(0, 0, 0, 0.4);
        }

        .scenario-card {
            border-left: 6px solid #4c51bf;
        }

        .scenario-card.passed {
            border-left-color: #38ef7d;
        }

        .scenario-card.failed {
            border-left-color: #ff6a00;
        }

        .scenario-card.expandable .scenario-body {
            display: none;
        }

        .scenario-card.expandable.open .scenario-body {
            display: block;
        }

        .test-card.expandable .test-body {
            display: none;
        }

        .test-card.expandable.open .test-body {
            display: block;
        }

        .scenario-header {
            padding: 0.72rem 1rem;
            display: flex;
            align-items: center;
            gap: 0.55rem;
            border-bottom: 2px solid #e2e8f0;
            flex-wrap: wrap;
            justify-content: flex-start;
        }

        .scenario-metrics {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 0.5rem;
            flex-wrap: wrap;
            margin-left: auto;
        }

        .scenario-chip-group {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 0.35rem;
            flex-wrap: wrap;
        }

        .scenario-chip {
            background: rgba(255, 255, 255, 0.9);
            padding: 0.16rem 0.32rem;
            border-radius: 16px;
            font-size: 0.64rem;
            font-weight: 600;
            color: #2d3748;
            box-shadow: 0 6px 18px rgba(76, 81, 191, 0.12);
            display: inline-flex;
            align-items: center;
            gap: 0.15rem;
            letter-spacing: 0.4px;
            min-width: 4.2rem;
            justify-content: space-between;
        }

        .scenario-chip .chip-label {
            font-size: 0.52rem;
            text-transform: uppercase;
            letter-spacing: 0.55px;
            color: #5a6b82;
        }

        .scenario-chip .chip-value {
            font-size: 0.72rem;
            color: #1a202c;
        }

        .scenario-chip.total {
            background: rgba(102, 126, 234, 0.16);
            color: #3c3fa3;
        }

        .scenario-chip.passed {
            background: rgba(56, 239, 125, 0.18);
            color: #067a4d;
        }

        .scenario-chip.failed {
            background: rgba(255, 107, 107, 0.2);
            color: #c53030;
        }

        .scenario-chip.subtle {
            background: rgba(236, 241, 248, 0.8);
            color: #4a5568;
            box-shadow: none;
        }

        .scenario-header.passed {
            background: linear-gradient(135deg, rgba(17, 153, 142, 0.12) 0%, rgba(56, 239, 125, 0.12) 100%);
        }

        .scenario-header.failed {
            background: linear-gradient(135deg, rgba(238, 9, 121, 0.12) 0%, rgba(255, 106, 0, 0.12) 100%);
        }

        .scenario-header.expandable-header {
            cursor: pointer;
            user-select: none;
        }

        .scenario-header.expandable-header:focus {
            outline: none;
        }

        .scenario-header.expandable-header:focus-visible {
            box-shadow: inset 0 0 0 2px rgba(102, 126, 234, 0.28);
        }

        .scenario-title {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 1.05rem;
            font-weight: 600;
            color: #1a202c;
            flex: 0 1 auto;
        }

        .scenario-toggle-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 1.3rem;
            height: 1.3rem;
            color: #4c51bf;
            font-size: 0.85rem;
            transition: transform 0.2s ease;
        }

        .scenario-card.expandable.open .scenario-toggle-icon {
            transform: rotate(90deg);
        }

        .copy-button {
            border: none;
            background: rgba(76, 81, 191, 0.12);
            color: #4c51bf;
            width: 1.2rem;
            height: 1.2rem;
            border-radius: 999px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 0.85rem;
            line-height: 1;
            transition: background 0.2s ease, transform 0.2s ease, color 0.2s ease;
        }

        .copy-button:hover {
            background: rgba(76, 81, 191, 0.22);
            transform: translateY(-1px);
        }

        .copy-button:focus {
            outline: none;
            box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.35);
        }

        .copy-button:active {
            transform: translateY(0);
        }

        .scenario-title .copy-button,
        .test-name .copy-button,
        .details-section summary .copy-button,
        .error-title .copy-button {
            margin-left: 0.35rem;
            flex: 0 0 auto;
        }

        .scenario-title-text,
        .test-name-text,
        .error-title-text {
            flex: 0 1 auto;
            min-width: 0;
        }

        .scenario-status {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.18rem 0.4rem;
            border-radius: 16px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            font-size: 0.62rem;
            margin-left: 0.4rem;
            min-width: 4.5rem;
            justify-content: center;
        }

        .scenario-status.passed {
            background: rgba(56, 239, 125, 0.24);
            color: #067a4d;
        }

        .scenario-status.failed {
            background: rgba(255, 107, 107, 0.26);
            color: #c24024;
        }

        .scenario-status::before {
            font-size: 0.85rem;
        }

        .scenario-status.passed::before {
            content: '✅';
        }

        .scenario-status.failed::before {
            content: '❌';
        }

        .scenario-body {
            padding: 1.25rem;
            background: #f8fafc;
        }

        .scenario-steps {
            display: grid;
            gap: 1rem;
        }

        .test-header.expandable-header {
            cursor: pointer;
            user-select: none;
        }

        .test-header.expandable-header:focus {
            outline: none;
        }

        .test-header.expandable-header:focus-visible {
            box-shadow: inset 0 0 0 2px rgba(102, 126, 234, 0.28);
        }

        .test-header {
            padding: 0.55rem 0.9rem;
            display: flex;
            align-items: center;
            justify-content: flex-start;
            gap: 0.6rem;
            flex-wrap: wrap;
            border-bottom: 2px solid #e2e8f0;
        }

        .test-header.passed {
            background: linear-gradient(135deg, rgba(17, 153, 142, 0.1) 0%, rgba(56, 239, 125, 0.1) 100%);
            border-left: 5px solid #38ef7d;
        }

        .test-header.failed {
            background: linear-gradient(135deg, rgba(238, 9, 121, 0.1) 0%, rgba(255, 106, 0, 0.1) 100%);
            border-left: 5px solid #ff6a00;
        }

        .test-name {
            font-size: 0.95rem;
            font-weight: 600;
            color: #2d3748;
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            flex: 1 1 auto;
            min-width: 0;
        }

        .test-toggle-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 1.1rem;
            height: 1.1rem;
            color: #4c51bf;
            font-size: 0.8rem;
            line-height: 1;
            transition: transform 0.2s ease;
        }

        .test-card.expandable.open .test-toggle-icon {
            transform: rotate(90deg);
        }

        .test-meta {
            display: flex;
            align-items: center;
            gap: 0.35rem;
            flex-wrap: wrap;
            margin-left: auto;
        }

        .test-status {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.28rem 0.62rem;
            border-radius: 16px;
            font-weight: 600;
            font-size: 0.64rem;
            text-transform: uppercase;
            letter-spacing: 0.55px;
            margin-left: 0.4rem;
        }

        .test-status.passed {
            background: rgba(56, 239, 125, 0.18);
            color: #0a7a4f;
        }

        .test-status.failed {
            background: rgba(255, 107, 107, 0.2);
            color: #c53030;
        }

        .test-status::before {
            font-size: 0.75rem;
        }

        .test-status.passed::before {
            content: '✅';
        }

        .test-status.failed::before {
            content: '❌';
        }

        .test-body {
            padding: 0.95rem 1rem;
        }

        .test-card.nested {
            border-radius: 16px;
            box-shadow: none;
            border: 1px solid #e2e8f0;
            background: white;
        }

        .test-card.nested:hover {
            transform: none;
            box-shadow: none;
        }

        .test-card.nested .test-header {
            border-left-width: 3px;
            padding: 0.65rem 0.95rem;
        }

        .test-card.nested .test-body {
            padding: 0.9rem 1.1rem;
        }

        .error-section {
            background: #fff5f5;
            border: 2px solid #fc8181;
            border-radius: 10px;
            padding: 1rem;
            margin-top: 1rem;
        }

        .details-section {
            margin-top: 1rem;
            background: #edf2f7;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            overflow: hidden;
        }

        .details-section summary {
            list-style: none;
            cursor: pointer;
            padding: 0.75rem 1rem;
            display: flex;
            align-items: center;
            justify-content: flex-start;
            gap: 0.45rem;
        }

        .details-section summary::-webkit-details-marker {
            display: none;
        }

        .details-toggle-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 1.1rem;
            height: 1.1rem;
            color: #4c51bf;
            font-size: 0.8rem;
            line-height: 1;
            transition: transform 0.2s ease;
        }

        .details-section[open] .details-toggle-icon {
            transform: rotate(90deg);
        }

        .details-summary {
            display: inline-flex;
            align-items: center;
            gap: 0.55rem;
            font-size: 0.9rem;
            font-weight: 600;
            color: #2d3748;
        }

        .details-summary::before {
            content: '📝';
        }

        .details-section[open] summary {
            border-bottom: 1px solid #cbd5e0;
            background: rgba(148, 163, 184, 0.15);
        }

        .details-section ul {
            list-style: disc;
            margin: 0;
            padding: 0.85rem 1.2rem 1.1rem 2.2rem;
            color: #4a5568;
            display: grid;
            gap: 0.35rem;
        }

        .error-title {
            color: #c53030;
            font-weight: 600;
            margin-bottom: 0.4rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            justify-content: flex-start;
        }

        .error-title::before {
            content: '⚠️';
        }

        .error-message {
            color: #742a2a;
            font-family: 'Courier New', monospace;
            font-size: 0.9rem;
            white-space: pre-wrap;
            word-break: break-word;
        }

        .screenshots-section {
            margin-top: 1.1rem;
        }

        .screenshots-title {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .screenshots-title::before {
            content: '📸';
        }

        .screenshots-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 0.75rem;
        }

        .golden-section {
            margin-top: 1.1rem;
            background: #f8fafc;
            border-radius: 15px;
            padding: 1rem 1.25rem;
            border: 1px solid #e2e8f0;
            box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.6);
        }

        .golden-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 1rem;
            margin-bottom: 0.6rem;
        }

        .golden-title {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2d3748;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .golden-title::before {
            content: '🎯';
        }

        .golden-badge {
            display: inline-flex;
            align-items: center;
            padding: 0.35rem 0.85rem;
            border-radius: 999px;
            font-size: 0.65rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 700;
        }

        .golden-match {
            background: rgba(56, 239, 125, 0.18);
            color: #0c7c4f;
            border: 1px solid rgba(56, 239, 125, 0.4);
        }

        .golden-mismatch {
            background: rgba(255, 106, 0, 0.2);
            color: #b43403;
            border: 1px solid rgba(255, 106, 0, 0.4);
        }

        .golden-baselinecreated,
        .golden-baselineupdated {
            background: rgba(102, 126, 234, 0.2);
            color: #364fc7;
            border: 1px solid rgba(102, 126, 234, 0.4);
        }

        .golden-error-badge {
            background: rgba(254, 178, 178, 0.3);
            color: #c53030;
            border: 1px solid rgba(254, 178, 178, 0.6);
        }

        .golden-metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 0.4rem;
            margin-bottom: 0.6rem;
            font-size: 0.8rem;
            color: #2d3748;
        }

        .golden-label {
            font-weight: 600;
            margin-right: 0.2rem;
            color: #4a5568;
        }

        .golden-links {
            display: flex;
            gap: 0.6rem;
            flex-wrap: wrap;
            margin-top: 0.6rem;
        }

        .golden-link {
            padding: 0.45rem 0.75rem;
            border-radius: 999px;
            background: #edf2f7;
            color: #2d3748;
            font-weight: 600;
            text-decoration: none;
            transition: background 0.2s, transform 0.2s;
        }

        .golden-link:hover {
            background: #e2e8f0;
            transform: translateY(-2px);
        }

        .golden-note {
            margin-top: 0.5rem;
            color: #1f2933;
            font-size: 0.78rem;
            line-height: 1.35;
            background: linear-gradient(120deg, rgba(102, 126, 234, 0.18), rgba(118, 75, 162, 0.08));
            border-radius: 12px;
            padding: 0.75rem 0.85rem;
            border: 1px solid rgba(102, 126, 234, 0.2);
        }

        .golden-error {
            margin-top: 0.75rem;
            display: flex;
            align-items: flex-start;
            gap: 0.75rem;
            color: #822727;
            font-size: 0.8rem;
            line-height: 1.35;
            background: linear-gradient(120deg, rgba(254, 178, 178, 0.35), rgba(254, 215, 215, 0.25));
            border: 1px solid rgba(229, 62, 62, 0.3);
            border-radius: 12px;
            padding: 0.75rem 0.95rem;
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.35);
        }

        .golden-error-icon {
            font-size: 1.25rem;
            line-height: 1;
            margin-top: 0.15rem;
        }

        .golden-error-text {
            flex: 1;
        }

        .golden-images {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 0.75rem;
            margin-top: 0.75rem;
        }

        .golden-image-card {
            position: relative;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.18);
            background: white;
            display: flex;
            flex-direction: column;
            cursor: pointer;
            transition: transform 0.25s, box-shadow 0.25s;
        }

        .golden-image-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 18px 40px rgba(0, 0, 0, 0.25);
        }

        .golden-image-card img {
            width: 100%;
            height: auto;
            display: block;
            object-fit: contain;
            background: #1a202c;
        }

        .golden-image-label {
            padding: 0.6rem 0.85rem;
            font-weight: 600;
            color: #2d3748;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .golden-image-label::before {
            content: '🖼️';
        }

        .golden-image-card.placeholder,
        .golden-image-card.missing {
            cursor: default;
            align-items: center;
            justify-content: center;
            padding: 1.5rem 1.25rem;
            background: #edf2f7;
            border: 2px dashed #cbd5e0;
        }

        .golden-image-card.placeholder:hover,
        .golden-image-card.missing:hover {
            transform: none;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.18);
        }

        .golden-image-placeholder {
            text-align: center;
            color: #4a5568;
            font-weight: 600;
        }

        .screenshot-item {
            position: relative;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            transition: transform 0.3s;
            cursor: pointer;
        }

        .screenshot-item:hover {
            transform: scale(1.05);
        }

        .screenshot-item img {
            width: 100%;
            height: auto;
            display: block;
            transition: transform 0.3s;
        }

        .screenshot-item:hover img {
            transform: scale(1.1);
        }

        .screenshot-label {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background: rgba(0, 0, 0, 0.7);
            color: white;
            padding: 0.6rem;
            font-size: 0.8rem;
            text-align: center;
            backdrop-filter: blur(10px);
        }

        .no-screenshots {
            color: #a0aec0;
            font-style: italic;
            text-align: center;
            padding: 1.5rem;
            background: #f7fafc;
            border-radius: 10px;
        }

        .footer {
            margin-top: 2rem;
            text-align: center;
            color: white;
            opacity: 0.8;
            font-size: 0.8rem;
        }

        /* Modal for full-size screenshots */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.9);
            justify-content: center;
            align-items: center;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            max-width: 90%;
            max-height: 90%;
            object-fit: contain;
            border-radius: 10px;
        }

        .modal-close {
            position: absolute;
            top: 2rem;
            right: 2rem;
            color: white;
            font-size: 3rem;
            cursor: pointer;
            font-weight: bold;
            transition: transform 0.2s;
        }

        .modal-close:hover {
            transform: scale(1.2);
        }

        @media (max-width: 768px) {
            body {
                padding: 1rem;
            }

            .header-top {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.5rem;
            }

            .header-timestamps {
                margin-left: 0;
                width: 100%;
                justify-content: flex-start;
            }

            .header h1 {
                font-size: 1.4rem;
            }

            .stat-card {
                width: 100%;
                justify-content: space-between;
            }

            .stat-card h3 {
                font-size: 1.05rem;
            }

            .screenshots-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="header-top">
                <h1>Flutter Self Testing Report</h1>
                <div class="header-timestamps">
                    <div class="header-chip">
                        <span class="chip-label">Run Start</span>
                        <span class="chip-value">$runStartLabel</span>
                    </div>
                    <div class="header-chip">
                        <span class="chip-label">Run End</span>
                        <span class="chip-value">$runEndLabel</span>
                    </div>
                </div>
            </div>
            <div class="stats">
                <div class="stat-card">
                    <h3>$totalScenarios</h3>
                    <p>Total Scenarios</p>
                </div>
                <div class="stat-card">
                    <h3>$totalTests</h3>
                    <p>Total Steps</p>
                </div>
                <div class="stat-card passed">
                    <h3>$passedTests</h3>
                    <p>Steps Passed</p>
                </div>
                <div class="stat-card failed">
                    <h3>$failedTests</h3>
                    <p>Steps Failed</p>
                </div>
                <div class="stat-card">
                    <h3>$successRate%</h3>
                    <p>Success Rate</p>
                </div>
                <div class="stat-card">
                    <h3>$totalDurationLabel</h3>
                    <p>Total Duration</p>
                </div>
                $goldenStatCard
            </div>
        </div>

        <div class="scenario-list">
            $scenarioCards
        </div>

        <div class="footer">
            <p>🚀 Generated by Flutter Self Testing Framework</p>
        </div>
    </div>

    <!-- Modal for full-size screenshots -->
    <div class="modal" id="screenshotModal" onclick="closeModal()">
        <span class="modal-close">&times;</span>
        <img class="modal-content" id="modalImage">
    </div>

    <script>
        function openModal(src) {
            const modal = document.getElementById('screenshotModal');
            const modalImg = document.getElementById('modalImage');
            modal.classList.add('active');
            modalImg.src = src;
        }

        function closeModal() {
            const modal = document.getElementById('screenshotModal');
            modal.classList.remove('active');
        }

        // Close modal with Escape key
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                closeModal();
            }
        });

        function fallbackCopy(text, onSuccess, onFailure) {
            try {
                const textarea = document.createElement('textarea');
                textarea.value = text;
                textarea.style.position = 'fixed';
                textarea.style.opacity = '0';
                document.body.appendChild(textarea);
                textarea.focus();
                textarea.select();
                const successful = document.execCommand('copy');
                document.body.removeChild(textarea);
                if (successful) {
                    onSuccess();
                } else {
                    onFailure();
                }
            } catch (error) {
                onFailure();
            }
        }

        function setupCopyButtons() {
            document.querySelectorAll('.copy-button').forEach(function(button) {
                button.addEventListener('click', function(event) {
                    event.preventDefault();
                    event.stopPropagation();

                    const targetId = button.getAttribute('data-copy-target');
                    let text = '';

                    if (targetId) {
                        const targetElement = document.getElementById(targetId);
                        if (targetElement) {
                            text = targetElement.textContent || '';
                        }
                    } else {
                        text = button.getAttribute('data-copy') || '';
                    }

                    if (!text) {
                        return;
                    }

                    const originalIcon = button.getAttribute('data-icon') || button.innerHTML;
                    const originalLabel = button.getAttribute('data-original-label') || button.getAttribute('aria-label') || 'Copy to clipboard';
                    button.setAttribute('data-icon', originalIcon);
                    button.setAttribute('data-original-label', originalLabel);

                    const markSuccess = function() {
                        button.innerHTML = '✅';
                        button.setAttribute('aria-label', 'Copied to clipboard');
                        setTimeout(function() {
                            button.innerHTML = originalIcon;
                            button.setAttribute('aria-label', originalLabel);
                        }, 2000);
                    };

                    const markFailure = function() {
                        button.innerHTML = '⚠️';
                        button.setAttribute('aria-label', 'Copy failed');
                        setTimeout(function() {
                            button.innerHTML = originalIcon;
                            button.setAttribute('aria-label', originalLabel);
                        }, 2000);
                    };

                    if (navigator.clipboard && navigator.clipboard.writeText) {
                        navigator.clipboard.writeText(text).then(markSuccess).catch(function() {
                            fallbackCopy(text, markSuccess, markFailure);
                        });
                    } else {
                        fallbackCopy(text, markSuccess, markFailure);
                    }
                });
            });
        }

        document.querySelectorAll('.expandable-header').forEach(function(header) {
            const card = header.parentElement;

            const toggleCard = function() {
                const isOpen = card.classList.toggle('open');
                header.setAttribute('aria-expanded', isOpen ? 'true' : 'false');

                card.querySelectorAll('.test-body, .scenario-body').forEach(function(body) {
                    if (isOpen) {
                        body.classList.add('visible');
                    } else {
                        body.classList.remove('visible');
                    }
                });

                const status = header.querySelector('.test-status, .scenario-status');
                if (status) {
                    status.setAttribute('aria-hidden', (!isOpen).toString());
                }
            };

            header.addEventListener('click', function() {
                toggleCard();
            });

            header.addEventListener('keydown', function(event) {
                if (event.key === 'Enter' || event.key === ' ') {
                    event.preventDefault();
                    toggleCard();
                }
            });
        });

        document.querySelectorAll('.test-card.expandable, .scenario-card.expandable').forEach(function(card) {
            const hasGoldenMismatch = card.querySelector('.golden-mismatch');
            if (hasGoldenMismatch) {
                card.classList.add('open');
                const header = card.querySelector('.expandable-header');
                if (header) {
                    header.setAttribute('aria-expanded', 'true');
                }
                card.querySelectorAll('.test-body, .scenario-body').forEach(function(body) {
                    body.classList.add('visible');
                });
            }
        });

        setupCopyButtons();
    </script>
</body>
</html>
''';
  }

  static List<Map<String, dynamic>> _extractSteps(
    Map<String, dynamic> scenario,
  ) {
    final steps = scenario['steps'];
    if (steps is List) {
      return steps
          .map<Map<String, dynamic>>((step) {
            if (step is Map<String, dynamic>) {
              return Map<String, dynamic>.from(step);
            }
            if (step is Map) {
              return Map<String, dynamic>.from(step.cast<String, dynamic>());
            }
            return <String, dynamic>{};
          })
          .where((step) => step.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static String _buildScenarioCard(
    Map<String, dynamic> scenario, {
    required int index,
  }) {
    final steps = _extractSteps(scenario);
    final status = (scenario['status'] ?? 'unknown').toString();
    final scenarioName = (scenario['name'] ?? 'Scenario').toString();
    final scenarioId = 'scenario-$index';
    final scenarioCopyText = _escapeAttribute(scenarioName);
    final passedSteps =
        steps.where((step) => step['status'] == 'passed').length;
    final failedSteps = steps.length - passedSteps;
    final durationValue = scenario['durationMs'];
    final durationMs = durationValue is num ? durationValue.toInt() : null;
    final formattedStart = _formatDateTime(scenario['startedAt']?.toString());
    final formattedEnd = _formatDateTime(scenario['endedAt']?.toString());
    final durationLabel = _formatDuration(durationMs);
    final stepsMarkup = steps.isNotEmpty
        ? steps.asMap().entries
            .map(
              (entry) => _buildTestCard(
                entry.value,
                scenarioId: scenarioId,
                index: entry.key,
                nested: true,
              ),
            )
            .join('\n')
        : '<div class="no-screenshots">No steps recorded.</div>';

    final cardClasses = ['scenario-card', 'expandable', status].join(' ');

    return '''
        <div class="$cardClasses">
            <div class="scenario-header $status expandable-header" role="button" tabindex="0" aria-expanded="false">
                <div class="scenario-title">
                    <span class="scenario-toggle-icon" aria-hidden="true">&#9654;</span>
                    <span class="scenario-title-text">${_escapeHtml(scenarioName)}</span>
                    <button class="copy-button" type="button" aria-label="Copy scenario title" data-copy="$scenarioCopyText">📋</button>
                </div>
                <div class="scenario-metrics">
                    <div class="scenario-chip-group">
                        <span class="scenario-chip total"><span class="chip-label">Steps</span><span class="chip-value">${steps.length}</span></span>
                        <span class="scenario-chip passed"><span class="chip-label">Passed</span><span class="chip-value">$passedSteps</span></span>
                        <span class="scenario-chip failed"><span class="chip-label">Failed</span><span class="chip-value">$failedSteps</span></span>
                    </div>
                    <div class="scenario-chip-group">
                        <span class="scenario-chip subtle"><span class="chip-label">Start</span><span class="chip-value">$formattedStart</span></span>
                        <span class="scenario-chip subtle"><span class="chip-label">End</span><span class="chip-value">$formattedEnd</span></span>
                        <span class="scenario-chip subtle"><span class="chip-label">Duration</span><span class="chip-value">$durationLabel</span></span>
                    </div>
                </div>
                <div class="scenario-status $status">${status.toUpperCase()}</div>
            </div>
            <div class="scenario-body">
                <div class="scenario-steps">
                    $stepsMarkup
                </div>
            </div>
        </div>
    ''';
  }

  static String _buildTestCard(
    Map<String, dynamic> result, {
    required String scenarioId,
    required int index,
    bool nested = false,
  }) {
    final name = (result['name'] ?? 'Unknown Test').toString();
    final status = (result['status'] ?? 'unknown').toString();
    final timestamp = result['timestamp']?.toString() ?? '';
    final durationValue = result['durationMs'];
    final durationMs = durationValue is num ? durationValue.toInt() : null;
    final error = result['error'];
    final stepCopyText = _escapeAttribute(name);

    final rawScreenshots = result['screenshots'];
    final screenshots = rawScreenshots is List
        ? rawScreenshots.map((value) => value.toString()).toList()
        : const <String>[];
    final goldenEntries = _normalizeGoldenEntries(result['golden']);
    final rawDetails = result['details'];
    final details = rawDetails is List
        ? rawDetails
            .map((value) => value.toString())
            .where((value) => value.trim().isNotEmpty)
            .toList()
        : const <String>[];

    final errorCopyText = error != null
        ? _escapeAttribute('Error Details\n${error.toString()}')
        : '';
    final detailsCopyText = details.isNotEmpty
        ? _escapeAttribute(
            [
              'Verification Details',
              ...details.map((item) => '- $item'),
            ].join('\n'),
          )
        : '';

    final hasScreenshots = screenshots.isNotEmpty;
    final hasGolden = goldenEntries.isNotEmpty;
    final showScreenshots = hasScreenshots && !hasGolden;
    final isExpandable = showScreenshots || hasGolden;

    final finishedAt =
        timestamp.isNotEmpty ? _formatDateTime(timestamp) : 'N/A';
    final durationLabel = _formatDuration(durationMs);

    final errorSection = error != null
        ? '''
            <div class="error-section">
                <div class="error-title">
                    <span class="error-title-text">Error Details</span>
                    <button class="copy-button" type="button" aria-label="Copy error details" data-copy="$errorCopyText">📋</button>
                </div>
                <div class="error-message">${_escapeHtml(error.toString())}</div>
            </div>
        '''
        : '';

    final screenshotsSection = showScreenshots
        ? '''
            <div class="screenshots-section">
                <div class="screenshots-title">Screenshots</div>
                <div class="screenshots-grid">
                    ${screenshots.map((screenshot) => '''
                        <div class="screenshot-item" onclick="openModal('screenshots/${_escapeHtml(screenshot)}')">
                            <img src="screenshots/${_escapeHtml(screenshot)}" alt="${_escapeHtml(screenshot)}">
                            <div class="screenshot-label">${_escapeHtml(screenshot)}</div>
                        </div>
                    ''').join('\n')}
                </div>
            </div>
        '''
        : '';

    final detailsSection = details.isNotEmpty
        ? '''
            <details class="details-section">
                <summary>
                    <span class="details-toggle-icon" aria-hidden="true">&#9654;</span>
                    <span class="details-summary">Verification Details</span>
                    <button class="copy-button" type="button" aria-label="Copy verification details" data-copy="$detailsCopyText">📋</button>
                </summary>
                <ul>
                    ${details.map((item) => '<li>${_escapeHtml(item)}</li>').join('\n')}
                </ul>
            </details>
        '''
        : '';

    final goldenSection = _buildGoldenSection(goldenEntries);
    final bodySections = [
      detailsSection,
      errorSection,
      screenshotsSection,
      goldenSection,
    ].where((section) => section.trim().isNotEmpty).join('\n');
    final bodyMarkup = bodySections.isEmpty
        ? ''
        : '''
            <div class="test-body">
                $bodySections
            </div>
        ''';
    final cardClasses = [
      'test-card',
      if (isExpandable) 'expandable',
      if (nested) 'nested',
    ].join(' ');

    final headerClasses = [
      'test-header',
      status,
      if (isExpandable) 'expandable-header',
    ].join(' ');

    final headerAttributes = isExpandable
        ? 'class="$headerClasses" role="button" tabindex="0" aria-expanded="false"'
        : 'class="$headerClasses"';

    final toggleIcon = isExpandable
        ? '<span class="test-toggle-icon" aria-hidden="true">&#9654;</span>'
        : '';

    final finishedChip =
        '<span class="scenario-chip subtle"><span class="chip-label">Finished</span><span class="chip-value">${_escapeHtml(finishedAt)}</span></span>';
    final durationChip =
        '<span class="scenario-chip subtle"><span class="chip-label">Duration</span><span class="chip-value">${_escapeHtml(durationLabel)}</span></span>';
    final metaSection =
        '<div class="test-meta">$finishedChip $durationChip</div>';

    return '''
        <div class="$cardClasses">
            <div $headerAttributes>
                <div class="test-name">$toggleIcon<span class="test-name-text">${_escapeHtml(name)}</span><button class="copy-button" type="button" aria-label="Copy step title" data-copy="$stepCopyText">📋</button></div>
                $metaSection
                <div class="test-status $status">${status.toUpperCase()}</div>
            </div>
            $bodyMarkup
        </div>
    ''';
  }

  static DateTime? _findBoundaryTimestamp(
    List<Map<String, dynamic>> scenarios,
    String field, {
    required bool findEarliest,
  }) {
    DateTime? boundary;
    for (final scenario in scenarios) {
      final rawValue = scenario[field];
      if (rawValue == null) {
        continue;
      }
      final parsed = DateTime.tryParse(rawValue.toString());
      if (parsed == null) {
        continue;
      }
      if (boundary == null) {
        boundary = parsed;
        continue;
      }
      final shouldReplace =
          findEarliest ? parsed.isBefore(boundary) : parsed.isAfter(boundary);
      if (shouldReplace) {
        boundary = parsed;
      }
    }
    return boundary;
  }

  static String _formatDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'N/A';
    }
    try {
      final parsed = DateTime.parse(value).toLocal();
      return parsed.toString().split('.').first;
    } catch (_) {
      return value;
    }
  }

  static String _formatDuration(int? durationMs) {
    if (durationMs == null) {
      return 'N/A';
    }
    if (durationMs < 1000) {
      return '${durationMs}ms';
    }
    final totalSeconds = durationMs / 1000;
    if (totalSeconds < 60) {
      return '${totalSeconds.toStringAsFixed(2)}s';
    }
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final secondsLabel = seconds >= 1
        ? '${seconds.toStringAsFixed(seconds >= 10 ? 0 : 1)}s'
        : '';
    final minutesLabel = '${minutes}m';
    return secondsLabel.isEmpty ? minutesLabel : '$minutesLabel $secondsLabel';
  }

  static List<Map<String, dynamic>> _normalizeGoldenEntries(dynamic raw) {
    if (raw is Map) {
      return [Map<String, dynamic>.from(raw.cast<String, dynamic>())];
    }

    if (raw is Iterable) {
      return raw
          .whereType<Map>()
          .map(
            (value) => Map<String, dynamic>.from(value.cast<String, dynamic>()),
          )
          .toList();
    }

    return const [];
  }

  static String _buildGoldenSection(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) {
      return '';
    }

    final hasMultiple = entries.length > 1;
    final sections = <String>[];

    for (var index = 0; index < entries.length; index++) {
      final suffix = hasMultiple ? ' #${index + 1}' : '';
      sections.add(_buildSingleGoldenSection(entries[index], suffix));
    }

    return sections.join('\n');
  }

  static String _buildSingleGoldenSection(
    Map<String, dynamic> golden,
    String titleSuffix,
  ) {
    if (golden.isEmpty) {
      return '';
    }

    final status = (golden['status'] ?? 'unknown').toString();
    final statusSlug = _statusToSlug(status);
    final badgeClass = _badgeClassForStatus(statusSlug);
    final statusLabel = _formatGoldenStatus(status);
    final diffValue = (golden['diffPercentage'] as num?)?.toDouble();
    final toleranceValue = (golden['tolerance'] as num?)?.toDouble();
    final diffLabel = _formatPercent(diffValue);
    final toleranceLabel = _formatPercent(toleranceValue);
    final baselineCreated = golden['baselineCreated'] == true;
    final baselineUpdated = golden['baselineUpdated'] == true;
    final rawError = golden['error']?.toString();
    final friendlyError = _buildGoldenErrorMessage(
      statusSlug,
      diffValue,
      toleranceValue,
      rawError,
    );

    final notes = <String>[];
    if (baselineCreated) {
      notes.add('A new golden baseline was captured during this run.');
    }
    if (baselineUpdated) {
      notes.add(
        'The golden baseline was refreshed with the latest screenshot.',
      );
    }

    final noteSection = notes.isNotEmpty
        ? '<div class="golden-note">${notes.join('<br>')}</div>'
        : '';

    final links = <String>[];
    final actualImage = golden['actualImage']?.toString();
    if (actualImage != null && actualImage.isNotEmpty) {
      links.add(
        '<a class="golden-link" href="$actualImage" target="_blank">Actual</a>',
      );
    }

    final goldenImage = golden['goldenImage']?.toString();
    if (goldenImage != null && goldenImage.isNotEmpty) {
      links.add(
        '<a class="golden-link" href="$goldenImage" target="_blank">Baseline</a>',
      );
    }

    final diffImage = golden['diffImage']?.toString();
    if (diffImage != null && diffImage.isNotEmpty) {
      links.add(
        '<a class="golden-link" href="$diffImage" target="_blank">Diff</a>',
      );
    }

    final linksSection = links.isNotEmpty
        ? '<div class="golden-links">${links.join('')}</div>'
        : '';

    final imagesSection = _buildGoldenImages(golden);

    final errorSection = friendlyError != null
        ? '<div class="golden-error"><span class="golden-error-icon">⚠️</span><div class="golden-error-text">$friendlyError</div></div>'
        : '';

    return '''
        <div class="golden-section">
                        <div class="golden-header">
                <div class="golden-title">Golden Comparison$titleSuffix</div>
                                <div class="golden-badge $badgeClass">$statusLabel</div>
                        </div>
                        <div class="golden-metrics">
                                <div><span class="golden-label">Difference:</span> $diffLabel</div>
                                <div><span class="golden-label">Tolerance:</span> $toleranceLabel</div>
                        </div>
                        $imagesSection
                        $noteSection
                        $linksSection
                        $errorSection
                </div>
        ''';
  }

  static String _buildGoldenImages(Map<String, dynamic> golden) {
    final cards = <String>[];

    final actualImage = golden['actualImage']?.toString();
    if (actualImage != null && actualImage.isNotEmpty) {
      cards.add(_goldenImageCard('Actual', actualImage));
    }

    final baselineImage = golden['goldenImage']?.toString();
    if (baselineImage != null && baselineImage.isNotEmpty) {
      cards.add(_goldenImageCard('Baseline', baselineImage));
    }

    final diffImage = golden['diffImage']?.toString();
    if (diffImage != null && diffImage.isNotEmpty) {
      cards.add(_goldenImageCard('Diff', diffImage));
    } else {
      final statusSlug = _statusToSlug((golden['status'] ?? '').toString());
      final message =
          statusSlug == 'baselinecreated' || statusSlug == 'baselineupdated'
              ? 'Diff image will be generated after the next comparison run.'
              : 'Diff image not available.';
      cards.add(_goldenImagePlaceholder('Diff', message));
    }

    if (cards.isEmpty) {
      return '';
    }

    return '''
        <div class="golden-images">
            ${cards.join('\n')}
        </div>
    ''';
  }

  static String _goldenImageCard(String label, String imagePath) {
    final safeLabel = _escapeHtml(label);
    final safeImagePath = _escapeHtml(imagePath);
    return '''
        <div class="golden-image-card" onclick="openModal('$safeImagePath')">
            <img src="$safeImagePath" alt="$safeLabel image">
            <div class="golden-image-label">$safeLabel</div>
        </div>
    ''';
  }

  static String _goldenImagePlaceholder(String label, String message) {
    final safeLabel = _escapeHtml(label);
    final safeMessage = _escapeHtml(message);
    return '''
        <div class="golden-image-card placeholder">
            <div class="golden-image-placeholder">$safeMessage</div>
            <div class="golden-image-label">$safeLabel</div>
        </div>
    ''';
  }

  static String? _buildGoldenErrorMessage(
    String statusSlug,
    double? diffValue,
    double? toleranceValue,
    String? rawError,
  ) {
    if (statusSlug == 'mismatch') {
      return null;
    }

    if (statusSlug == 'error') {
      if (rawError == null || rawError.isEmpty) {
        return _escapeHtml(
          'Golden comparison failed because an unexpected error occurred.',
        );
      }

      final cleaned = rawError.replaceFirst(
        RegExp(r'^Golden comparison for [^:]+ failed: '),
        '',
      );
      return _escapeHtml(cleaned);
    }

    return null;
  }

  static String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  static String _escapeAttribute(String value) {
    return _escapeHtml(value).replaceAll('\n', '&#10;');
  }

  static String _badgeClassForStatus(String statusSlug) {
    switch (statusSlug) {
      case 'match':
        return 'golden-match';
      case 'mismatch':
        return 'golden-mismatch';
      case 'baselinecreated':
      case 'baselineupdated':
        return 'golden-baselinecreated';
      case 'error':
        return 'golden-error-badge';
      default:
        return 'golden-baselinecreated';
    }
  }

  static String _statusToSlug(String status) {
    final cleaned = status.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return cleaned.toLowerCase();
  }

  static String _formatGoldenStatus(String status) {
    switch (status) {
      case 'match':
        return 'Match';
      case 'mismatch':
        return 'Mismatch';
      case 'baselineCreated':
        return 'Baseline Created';
      case 'baselineUpdated':
        return 'Baseline Updated';
      case 'error':
        return 'Error';
      default:
        if (status.isEmpty) {
          return 'Unknown';
        }
        final spaced = status
            .replaceAll('_', ' ')
            .replaceAllMapped(
              RegExp(r'([a-z])([A-Z])'),
              (match) => '${match.group(1)} ${match.group(2)}',
            )
            .toLowerCase();
        return spaced[0].toUpperCase() + spaced.substring(1);
    }
  }

  static String _formatPercent(num? value) {
    if (value == null) {
      return 'N/A';
    }
    return '${value.toDouble().toStringAsFixed(2)}%';
  }
}
