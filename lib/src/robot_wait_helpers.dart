import 'package:flutter/material.dart';
import 'package:self_testing/src/robot_config.dart';

class RobotTimeoutException implements Exception {
  RobotTimeoutException(this.message);
  final String message;

  @override
  String toString() => 'RobotTimeoutException: $message';
}

mixin RobotWaitHelpers {
  void logAction(
    String message, {
    bool recordDetail = true,
    bool forcePrint = false,
  });

  String describeTarget(GlobalKey key, {String? label});

  Future<void> wait([Duration duration = RobotConfig.defaultWait]) {
    return Future.delayed(duration);
  }

  Future<void> waitUntil(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final startTime = DateTime.now();
    while (!condition()) {
      if (DateTime.now().difference(startTime) > timeout) {
        throw RobotTimeoutException(
          'Condition not met within ${timeout.inSeconds}s',
        );
      }
      await Future.delayed(interval);
    }
  }

  Future<void> waitForWidget(
    GlobalKey key, {
    Duration timeout = RobotConfig.uiSettleTimeout,
    Duration interval = const Duration(milliseconds: 60),
  }) async {
    final target = describeTarget(key);
    logAction('Waiting for widget to appear → $target');
    await waitUntil(
      () => key.currentWidget != null,
      timeout: timeout,
      interval: interval,
    );
    logAction('Widget detected in tree → $target', recordDetail: false);
  }

  Future<void> waitForWidgetToDisappear(
    GlobalKey key, {
    Duration timeout = RobotConfig.uiSettleTimeout,
    Duration interval = const Duration(milliseconds: 60),
  }) async {
    final target = describeTarget(key);
    logAction('Waiting for widget to disappear → $target');
    await waitUntil(
      () => key.currentWidget == null,
      timeout: timeout,
      interval: interval,
    );
    logAction('Widget removed from tree → $target', recordDetail: false);
  }
}
