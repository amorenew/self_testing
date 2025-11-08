import 'package:flutter/material.dart';
import 'package:self_testing/src/robot_config.dart';
import 'package:self_testing/src/robot_wait_helpers.dart';
import 'package:self_testing/src/test_runner.dart';
import 'package:self_testing/src/testing_manager.dart';

mixin RobotActions<T> on RobotWaitHelpers {
  BuildContext? get context;
  TestStep? get testStep;
  T get self;

  @override
  String describeTarget(GlobalKey key, {String? label});

  Future<T> navigateBack({
    GlobalKey? waitForKey,
    bool waitForDisappear = false,
    Duration? timeout,
    Duration interval = const Duration(milliseconds: 60),
  }) async {
    NavigatorState? navigatorState;
    logAction(
      'Navigating back'
      '${waitForKey != null ? ' (awaiting ${describeTarget(waitForKey)})' : ''}',
    );

    if (context != null) {
      navigatorState = Navigator.of(context!);
    } else {
      navigatorState = SelfTesting.maybeNavigatorKey?.currentState;
    }

    if (navigatorState == null) {
      throw Exception('Cannot navigate back: no navigator available');
    }

    navigatorState.pop();

    if (waitForKey != null) {
      if (waitForDisappear) {
        await waitForWidgetToDisappear(
          waitForKey,
          timeout: timeout ?? RobotConfig.uiSettleTimeout,
          interval: interval,
        );
      } else {
        await waitForWidget(
          waitForKey,
          timeout: timeout ?? RobotConfig.uiSettleTimeout,
          interval: interval,
        );
      }
    } else {
      await wait(RobotConfig.defaultTapWait);
    }

    logAction('Navigation back completed', recordDetail: false);
    return self;
  }

  Future<T> tapByKey(GlobalKey key, {String? label}) async {
    final target = describeTarget(key, label: label);
    final widget = key.currentWidget;
    final ctx = key.currentContext;

    if (widget == null || ctx == null) {
      logAction(
        'Cannot tap → $target (widget or context missing)',
        forcePrint: true,
      );
      throw Exception(
        'Widget ${label ?? key.toString()} not found via global key',
      );
    }

    VoidCallback? callback;

    if (widget is ButtonStyleButton) {
      callback = widget.onPressed;
    } else if (widget is GestureDetector) {
      callback = widget.onTap;
    }

    if (callback != null) {
      logAction('Tapping → $target');
      callback();
      logAction('Tapped → $target', recordDetail: false);
      return self;
    }

    logAction('Widget not tappable → $target', forcePrint: true);
    throw Exception('Widget ${label ?? key.toString()} is not tappable');
  }

  Future<T> tapAndWait(
    GlobalKey key, {
    String? label,
    Duration waitDuration = RobotConfig.defaultTapWait,
    GlobalKey? waitForKey,
    bool waitForDisappear = false,
    Duration? timeout,
    Duration interval = const Duration(milliseconds: 60),
  }) async {
    final target = describeTarget(key, label: label);
    logAction('Tap and wait → $target');
    await tapByKey(key, label: label);
    if (waitForKey != null) {
      if (waitForDisappear) {
        await waitForWidgetToDisappear(
          waitForKey,
          timeout: timeout ?? RobotConfig.uiSettleTimeout,
          interval: interval,
        );
      } else {
        await waitForWidget(
          waitForKey,
          timeout: timeout ?? RobotConfig.uiSettleTimeout,
          interval: interval,
        );
      }
    } else {
      await wait(waitDuration);
    }
    logAction('Tap and wait completed → $target', recordDetail: false);
    return self;
  }

  Future<T> enterText(GlobalKey key, String text, {String? label}) async {
    final target = describeTarget(key, label: label);
    final widget = key.currentWidget;

    if (widget == null) {
      logAction(
        'Cannot enter text → $target (widget not found)',
        forcePrint: true,
      );
      throw Exception(
        'Text input ${label ?? key.toString()} not found via global key',
      );
    }

    final editable = resolveEditable(widget);
    if (editable == null) {
      logAction(
        'Cannot enter text → $target (unsupported widget)',
        forcePrint: true,
      );
      throw Exception(
        'Widget ${label ?? key.toString()} is not a supported text input',
      );
    }

    editable.controller
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
    editable.onChanged?.call(text);

    logAction('Entered "$text" → $target');
    await wait(RobotConfig.defaultTapWait);
    return self;
  }

  String readText(GlobalKey key, {String? label}) {
    final target = describeTarget(key, label: label);
    final widget = key.currentWidget;

    if (widget == null) {
      logAction(
        'Cannot read text → $target (widget not found)',
        forcePrint: true,
      );
      throw Exception(
        'Text input ${label ?? key.toString()} not found via global key',
      );
    }

    final editable = resolveEditable(widget);
    if (editable == null) {
      logAction(
        'Cannot read text → $target (unsupported widget)',
        forcePrint: true,
      );
      throw Exception(
        'Widget ${label ?? key.toString()} is not a supported text input',
      );
    }

    return editable.controller.text;
  }

  EditableInput? resolveEditable(Widget widget) {
    if (widget is TextField) {
      final controller = widget.controller;
      if (controller == null) {
        throw Exception(
          'TextField ${widget.key?.toString() ?? ''} requires a controller',
        );
      }
      return EditableInput(controller, widget.onChanged);
    }

    if (widget is TextFormField) {
      final controller = widget.controller;
      if (controller == null) {
        throw Exception(
          'TextFormField ${widget.key?.toString() ?? ''} requires a controller',
        );
      }
      return EditableInput(controller, widget.onChanged);
    }

    if (widget is EditableText) {
      return EditableInput(widget.controller, widget.onChanged);
    }

    if (widget is KeyedSubtree) {
      return resolveEditable(widget.child);
    }

    return null;
  }
}

class EditableInput {
  EditableInput(this.controller, this.onChanged);
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
}
