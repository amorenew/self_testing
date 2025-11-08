import 'package:flutter/material.dart';
import 'package:self_testing/src/robot_actions.dart';
import 'package:self_testing/src/robot_config.dart';
import 'package:self_testing/src/robot_verifications.dart';
import 'package:self_testing/src/robot_wait_helpers.dart';
import 'package:self_testing/src/screenshot_helper.dart';
import 'package:self_testing/src/test_detail_recorder.dart';
import 'package:self_testing/src/test_runner.dart';
import 'package:self_testing/src/testing_manager.dart';

/// Abstract base class for all Robot implementations.
///
/// Robots follow the Robot Pattern for testing UI:
/// - Each robot represents a specific screen or component
/// - Methods return the robot instance for method chaining
/// - Include verification methods to assert UI state
/// - Handle async operations with proper wait mechanisms
abstract class BaseRobot<T extends BaseRobot<T>>
    with RobotWaitHelpers, RobotVerifications, RobotActions<T> {
  BaseRobot({this.testStep});

  @override
  BuildContext? get context;

  @override
  final TestStep? testStep;

  @override
  T get self => this as T;

  @override
  void logAction(
    String message, {
    bool recordDetail = true,
    bool forcePrint = false,
  }) {
    final stepName = testStep?.name;
    final typeName = runtimeType.toString();
    final buffer = StringBuffer('🤖 [$typeName');
    if (stepName != null && stepName.isNotEmpty) {
      buffer.write(' | Step: $stepName');
    }
    buffer.write('] $message');
    final logMessage = buffer.toString();
    TestingDiagnostics.recordAction(logMessage);

    if (forcePrint || SelfTesting.logRobotActions) {
      debugPrint(logMessage);
    }

    if (recordDetail && TestDetailRecorder.isRecording) {
      if (stepName != null && stepName.isNotEmpty) {
        TestDetailRecorder.add('$stepName › $typeName → $message');
      } else {
        TestDetailRecorder.add('$typeName → $message');
      }
    }
  }

  @override
  String describeTarget(GlobalKey key, {String? label}) {
    if (label != null && label.trim().isNotEmpty) return label;
    final keyDescription = key.toString();
    if (keyDescription.isNotEmpty) return keyDescription;
    return key.runtimeType.toString();
  }

  Future<T> captureScreenshot(String name, {double? tolerance}) async {
    final resolvedName = _composeScreenshotName(name);
    logAction('Capturing screenshot "$resolvedName"');
    final fileName = '$resolvedName.png';

    final aliasSet = <String>{
      resolvedName,
      _aliasKeyFor(resolvedName),
      _aliasKeyFor(fileName),
    };

    if (testStep != null) {
      aliasSet.add(_aliasKeyFor(testStep!.name));
      for (final screenshot in testStep!.allScreenshots) {
        aliasSet.add(_aliasKeyFor(screenshot));
      }
    }

    aliasSet.removeWhere((value) => value.trim().isEmpty);

    await ScreenshotHelper.captureAndSend(
      resolvedName,
      tolerance: tolerance,
      aliases: aliasSet.toList(),
    );

    testStep?.registerScreenshot(fileName);
    logAction('Screenshot captured "$resolvedName"', recordDetail: false);
    return self;
  }

  Future<T> waitForLoad({
    GlobalKey? readyKey,
    Duration? fallback,
    Duration timeout = RobotConfig.uiSettleTimeout,
    Duration interval = const Duration(milliseconds: 60),
  }) async {
    if (readyKey != null) {
      logAction(
        'Waiting for screen load using key → ${describeTarget(readyKey)}',
      );
    } else {
      logAction(
        'Waiting for screen load for ${fallback ?? RobotConfig.defaultWait}',
      );
    }

    if (readyKey != null) {
      await waitForWidget(readyKey, timeout: timeout, interval: interval);
    } else {
      await wait(fallback ?? RobotConfig.defaultWait);
    }
    logAction('Screen load wait finished', recordDetail: false);
    return self;
  }

  String _composeScreenshotName(String name) {
    final sanitizedBase = _sanitizeForFileName(name);
    if (testStep == null) return sanitizedBase;

    final stepSlug = _sanitizeForFileName(testStep!.name);
    if (stepSlug.isEmpty || stepSlug == sanitizedBase) return sanitizedBase;
    if (sanitizedBase.startsWith('${stepSlug}_')) return sanitizedBase;

    return '${stepSlug}_$sanitizedBase';
  }

  String _sanitizeForFileName(String value) {
    final lowered = value.trim().toLowerCase();
    var sanitized = lowered.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    sanitized = sanitized.replaceAll(RegExp(r'_+'), '_');
    sanitized = sanitized.replaceAll(RegExp(r'^_+|_+$'), '');
    return sanitized.isEmpty ? 'screenshot' : sanitized;
  }

  String _aliasKeyFor(String value) {
    final base = value.toLowerCase().endsWith('.png')
        ? value.substring(0, value.length - 4)
        : value;
    return _sanitizeForFileName(base);
  }
}
