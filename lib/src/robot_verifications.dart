import 'package:flutter/material.dart';
import 'package:self_testing/src/test_detail_recorder.dart';

mixin RobotVerifications {
  void logAction(
    String message, {
    bool recordDetail = true,
    bool forcePrint = false,
  });

  String describeTarget(GlobalKey key, {String? label}) {
    if (label != null && label.trim().isNotEmpty) return label;
    final keyDescription = key.toString();
    if (keyDescription.isNotEmpty) return keyDescription;
    return key.runtimeType.toString();
  }

  void verify(bool condition, String message) {
    if (!condition) {
      logAction('Verification failed → $message', forcePrint: true);
      throw AssertionError('Verification failed: $message');
    }
    logAction('Verification passed → $message', recordDetail: false);
  }

  void verifyWidgetExists(GlobalKey key, {String? label}) {
    final target = describeTarget(key, label: label);
    logAction('Verifying widget exists → $target');
    final exists = key.currentWidget != null;
    verify(
      exists,
      '${label ?? key.toString()} should exist in the widget tree',
    );
    logAction('Widget exists → $target', recordDetail: false);
  }

  void verifyTextEquals(GlobalKey key, String expectedText, {String? label}) {
    final target = describeTarget(key, label: label);
    logAction('Verifying text equals "$expectedText" → $target');
    verifyWidgetExists(key, label: label);

    final widget = key.currentWidget;
    final resolved = widget != null ? extractText(widget) : null;

    if (resolved == null) {
      throw Exception(
        'Widget ${label ?? key.toString()} does not expose a readable text value.',
      );
    }

    verify(
      resolved == expectedText,
      '${label ?? key.toString()} expected "$expectedText" but found "$resolved"',
    );

    logAction('Text matches "$expectedText" → $target', recordDetail: false);
    TestDetailRecorder.add('${label ?? key.toString()} → "$resolved"');
  }

  String? extractText(Widget widget) {
    if (widget is Text) {
      return widget.data ?? widget.textSpan?.toPlainText();
    }
    if (widget is KeyedSubtree) {
      return extractText(widget.child);
    }
    if (widget is ButtonStyleButton) {
      final child = widget.child;
      return child != null ? extractText(child) : null;
    }
    return null;
  }

  W findWidgetByKey<W extends Widget>(GlobalKey key) {
    final widget = key.currentWidget;
    if (widget == null || widget is! W) {
      throw Exception(
        'Widget with key ${key.toString()} not found or has wrong type. Expected ${W.toString()}',
      );
    }
    return widget;
  }

  BuildContext findContextByKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) {
      throw Exception('Context for key ${key.toString()} not found');
    }
    return ctx;
  }
}
