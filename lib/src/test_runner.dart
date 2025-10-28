import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:self_testing/src/report_generator.dart';
import 'package:self_testing/src/robot_config.dart';
import 'package:self_testing/src/screenshot_helper.dart';
import 'package:self_testing/src/test_detail_recorder.dart';
import 'package:self_testing/src/testing_manager.dart';

class TestRunner {
  static Future<void> runAll(
    List<TestScenario> scenarios, {
    bool useLocalStorage = false,
  }) async {
    if (useLocalStorage) {
      await _resetResultsFile();
    }

    final scenarioResults = <Map<String, dynamic>>[];

    for (final scenario in scenarios) {
      debugPrint('🎯 Scenario: ${scenario.name}');
      final scenarioStart = DateTime.now();
      final stepResults = <Map<String, dynamic>>[];

      for (final step in scenario.steps) {
        final stepResult = await _runStep(
          step,
          useLocalStorage: useLocalStorage,
        );
        stepResults.add(stepResult);
        await _waitForUiIdle();
      }

      final scenarioEnd = DateTime.now();
      final scenarioPassed = stepResults.every((r) => r['status'] == 'passed');

      scenarioResults.add({
        'name': scenario.name,
        'status': scenarioPassed ? 'passed' : 'failed',
        'startedAt': scenarioStart.toIso8601String(),
        'endedAt': scenarioEnd.toIso8601String(),
        'durationMs': scenarioEnd.difference(scenarioStart).inMilliseconds,
        'steps': stepResults,
      });
    }

    debugPrint('✅ Testing session completed.');

    if (useLocalStorage) {
      await _writeScenarioResults(scenarioResults);
      debugPrint('📊 Generating HTML report...');
      await ReportGenerator.generateHtmlReport();
      await _showReportToast();
    }
  }

  static Future<File> _getResultsFile() async {
    // Get the project root by navigating up from the executable
    final executablePath = Platform.resolvedExecutable;
    final executableDir = Directory(executablePath).parent;

    // Navigate to project root
    var projectRoot = executableDir;

    // Try to find the project root by looking for pubspec.yaml
    while (projectRoot.path != projectRoot.parent.path) {
      final pubspecFile = File('${projectRoot.path}/pubspec.yaml');
      if (await pubspecFile.exists()) {
        break;
      }
      projectRoot = projectRoot.parent;
    }

    // If not found, use a fallback absolute path
    if (!await File('${projectRoot.path}/pubspec.yaml').exists()) {
      projectRoot = SelfTesting.projectRootDirectory;
    }

    final directory = Directory('${projectRoot.path}/report');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final file = File('${directory.path}/test_results.json');
    debugPrint('📁 Using test results file: ${file.path}');
    return file;
  }

  static Future<void> _resetResultsFile() async {
    final file = await _getResultsFile();
    await file.writeAsString('[]', flush: true);
    debugPrint('🧹 Cleared old test results at ${file.path}.');
  }

  static Future<Map<String, dynamic>> _runStep(
    TestStep step, {
    required bool useLocalStorage,
  }) async {
    debugPrint('▶️ Running test: ${step.name}');
    final stepStart = DateTime.now();
    String? error;

    TestDetailRecorder.start();
    var recordedDetails = const <String>[];

    try {
      await step.action(step);
      debugPrint('✅ Test ${step.name} passed');
    } catch (e) {
      error = e.toString();
      debugPrint('❌ Test ${step.name} failed: $error');
    } finally {
      recordedDetails = TestDetailRecorder.finish();
    }

    final stepEnd = DateTime.now();
    final result = <String, dynamic>{
      'name': step.name,
      'status': error == null ? 'passed' : 'failed',
      'timestamp': stepEnd.toIso8601String(),
      'durationMs': stepEnd.difference(stepStart).inMilliseconds,
      if (error != null) 'error': error,
      if (step.allScreenshots.isNotEmpty) 'screenshots': step.allScreenshots,
      if (_mergeDetails(step.details, recordedDetails).isNotEmpty)
        'details': _mergeDetails(step.details, recordedDetails),
    };

    final goldenEntries = <Map<String, dynamic>>[];

    final screenshotNames = step.allScreenshots;
    for (final screenshot in screenshotNames) {
      final candidate = ScreenshotHelper.consumeGoldenMetadata(screenshot);
      if (candidate != null && candidate.isNotEmpty) {
        goldenEntries.add(candidate);
      }
    }

    if (goldenEntries.isEmpty) {
      final fallback = ScreenshotHelper.consumeGoldenMetadata(step.name);
      if (fallback != null && fallback.isNotEmpty) {
        goldenEntries.add(fallback);
      }
    }

    if (goldenEntries.isNotEmpty) {
      result['golden'] =
          goldenEntries.length == 1 ? goldenEntries.first : goldenEntries;
    }

    if (!useLocalStorage) {
      await _sendRemoteResult(result);
    }

    return result;
  }

  static Future<void> _sendRemoteResult(Map<String, dynamic> result) async {
    try {
      await Dio().post(
        'https://api.example.com/test-report',
        data: {
          'name': result['name'],
          'status': result['status'],
          if (result['error'] != null) 'error': result['error'],
        },
      );
    } catch (error) {
      debugPrint('⚠️ Failed to send remote result: $error');
    }
  }

  static Future<void> _writeScenarioResults(
    List<Map<String, dynamic>> scenarios,
  ) async {
    final file = await _getResultsFile();
    await file.writeAsString(jsonEncode(scenarios), flush: true);
    debugPrint('📝 Saved ${scenarios.length} scenario(s) to ${file.path}');
  }

  static Future<void> _showReportToast() async {
    final navigatorKey = SelfTesting.maybeNavigatorKey;
    if (navigatorKey == null) {
      debugPrint('⚠️ Unable to show report toast: navigator key not set.');
      return;
    }

    final navigatorContext = navigatorKey.currentContext;
    if (navigatorContext == null) {
      debugPrint('⚠️ Unable to show report toast: no navigator context.');
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(navigatorContext);
    if (messenger == null) {
      debugPrint('⚠️ Unable to show report toast: no ScaffoldMessenger found.');
      return;
    }

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Visual report ready: report/test_report.html'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

Future<void> _waitForUiIdle() async {
  final scheduler = SchedulerBinding.instance;
  final timeout = RobotConfig.uiSettleTimeout;
  const pollInterval = Duration(milliseconds: 50);

  bool uiIsBusy() {
    return scheduler.hasScheduledFrame || scheduler.transientCallbackCount > 0;
  }

  final start = DateTime.now();
  var consecutiveIdleTicks = 0;

  while (DateTime.now().difference(start) < timeout) {
    await Future.delayed(pollInterval);
    if (uiIsBusy()) {
      consecutiveIdleTicks = 0;
      continue;
    }

    consecutiveIdleTicks += 1;
    if (consecutiveIdleTicks >= 2) {
      return;
    }
  }

  await Future.delayed(RobotConfig.defaultPostTestDelay);
}

List<String> _mergeDetails(List<String>? staticDetails, List<String> recorded) {
  final combined = <String>[];

  if (staticDetails != null) {
    combined.addAll(
      staticDetails
          .map((detail) => detail.trim())
          .where((detail) => detail.isNotEmpty),
    );
  }

  combined.addAll(recorded.where((detail) => detail.trim().isNotEmpty));

  return combined;
}

class TestScenario {
  final String name;
  final List<TestStep> steps;

  TestScenario({required this.name, required this.steps});
}

class TestStep {
  final String name;
  final Future<void> Function(TestStep) action;
  final List<String>? screenshots;
  final List<String>? details;

  final List<String> _capturedScreenshots = [];

  TestStep({
    required this.name,
    required this.action,
    this.screenshots,
    this.details,
  });

  void registerScreenshot(String filename) {
    final trimmed = filename.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _capturedScreenshots.add(trimmed);
  }

  List<String> get capturedScreenshots =>
      List.unmodifiable(_capturedScreenshots);

  List<String> get allScreenshots {
    final combined = <String>[];
    final seen = <String>{};

    void addAll(Iterable<String>? source) {
      if (source == null) {
        return;
      }
      for (final value in source) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) {
          continue;
        }
        if (seen.add(trimmed)) {
          combined.add(trimmed);
        }
      }
    }

    addAll(screenshots);
    addAll(_capturedScreenshots);

    return combined;
  }
}
