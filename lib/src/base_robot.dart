import 'package:flutter/material.dart';
import 'package:self_testing/src/robot_config.dart';
import 'package:self_testing/src/test_runner.dart';
import 'package:self_testing/src/screenshot_helper.dart';
import 'package:self_testing/src/test_detail_recorder.dart';
import 'package:self_testing/src/testing_manager.dart';

/// Abstract base class for all Robot implementations.
///
/// Robots follow the Robot Pattern for testing UI:
/// - Each robot represents a specific screen or component
/// - Methods return the robot instance for method chaining
/// - Include verification methods to assert UI state
/// - Handle async operations with proper wait mechanisms
abstract class BaseRobot<T extends BaseRobot<T>> {
  BaseRobot({this.testStep});

  /// Context reference for widget tree access
  BuildContext? get context;

  /// Reference to the currently executing test step, when provided.
  final TestStep? testStep;

  /// Returns the concrete robot instance for method chaining
  T get self => this as T;

  /// Finds a widget by its GlobalKey and returns it as the expected type.
  ///
  /// Generic type parameter renamed to [W] to avoid confusion with the
  /// class-level generic [T] used for the robot instance.
  ///
  /// Throws an [Exception] if the widget is not found or wrong type.
  W findWidgetByKey<W extends Widget>(GlobalKey key) {
    final widget = key.currentWidget;
    if (widget == null || widget is! W) {
      throw Exception(
        'Widget with key ${key.toString()} not found or has wrong type. Expected ${W.toString()}',
      );
    }
    return widget;
  }

  /// Finds a widget context by its GlobalKey
  ///
  /// Throws an exception if the context is not found.
  BuildContext findContextByKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) {
      throw Exception('Context for key ${key.toString()} not found');
    }
    return ctx;
  }

  /// Waits for a specified duration
  ///
  /// Useful for animations or loading states.
  Future<void> wait([Duration duration = RobotConfig.defaultWait]) {
    return Future.delayed(duration);
  }

  /// Waits for a condition to be true.
  ///
  /// Polls the condition every [interval] until it returns true
  /// or [timeout] is reached.
  ///
  /// Throws [RobotTimeoutException] if the condition is not met within the timeout.
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

  /// Waits until a widget identified by [key] becomes available in the tree.
  Future<void> waitForWidget(
    GlobalKey key, {
    Duration timeout = RobotConfig.uiSettleTimeout,
    Duration interval = const Duration(milliseconds: 60),
  }) {
    return waitUntil(
      () => key.currentWidget != null,
      timeout: timeout,
      interval: interval,
    );
  }

  /// Waits until a widget identified by [key] is removed from the tree.
  Future<void> waitForWidgetToDisappear(
    GlobalKey key, {
    Duration timeout = RobotConfig.uiSettleTimeout,
    Duration interval = const Duration(milliseconds: 60),
  }) {
    return waitUntil(
      () => key.currentWidget == null,
      timeout: timeout,
      interval: interval,
    );
  }

  /// Verifies that a condition is true
  ///
  /// Throws an assertion error with [message] if condition is false.
  void verify(bool condition, String message) {
    if (!condition) {
      throw AssertionError('Verification failed: $message');
    }
  }

  /// Verifies that a widget exists by GlobalKey
  void verifyWidgetExists(GlobalKey key, {String? label}) {
    final exists = key.currentWidget != null;
    verify(
      exists,
      '${label ?? key.toString()} should exist in the widget tree',
    );
  }

  /// Verifies that a widget identified by [key] exposes the [expectedText] value.
  ///
  /// Supports [Text] widgets, keyed subtrees wrapping text, and button-style
  /// widgets whose child resolves to a text node.
  void verifyTextEquals(GlobalKey key, String expectedText, {String? label}) {
    verifyWidgetExists(key, label: label);

    final widget = key.currentWidget;
    final resolved = widget != null ? _extractText(widget) : null;

    if (resolved == null) {
      throw Exception(
        'Widget ${label ?? key.toString()} does not expose a readable text value.',
      );
    }

    verify(
      resolved == expectedText,
      '${label ?? key.toString()} expected "$expectedText" but found "$resolved"',
    );

    debugPrint('✅ ${label ?? key.toString()} text matches "$expectedText"');
    TestDetailRecorder.add('${label ?? key.toString()} → "$resolved"');
  }

  /// Recursively extracts a text value from supported widget types.
  String? _extractText(Widget widget) {
    if (widget is Text) {
      return widget.data ?? widget.textSpan?.toPlainText();
    }

    if (widget is KeyedSubtree) {
      return _extractText(widget.child);
    }

    if (widget is ButtonStyleButton) {
      final child = widget.child;
      return child != null ? _extractText(child) : null;
    }

    return null;
  }

  /// Captures a screenshot with golden comparison
  ///
  /// [name] - The identifier for the screenshot/golden baseline
  /// [tolerance] - Optional custom diff tolerance (defaults to global setting)
  ///
  /// Returns the robot instance for method chaining.
  Future<T> captureScreenshot(String name, {double? tolerance}) async {
    final resolvedName = _composeScreenshotName(name);
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
    debugPrint('📸 Captured screenshot: $resolvedName');
    return self;
  }

  /// Waits for screen to be fully loaded
  ///
  /// Useful after navigation or when expecting async operations.
  /// Returns the robot instance for method chaining.
  Future<T> waitForLoad({
    GlobalKey? readyKey,
    Duration? fallback,
    Duration timeout = RobotConfig.uiSettleTimeout,
    Duration interval = const Duration(milliseconds: 60),
  }) async {
    if (readyKey != null) {
      await waitForWidget(readyKey, timeout: timeout, interval: interval);
    } else {
      await wait(fallback ?? RobotConfig.defaultWait);
    }
    debugPrint('⏳ Waited for screen to load');
    return self;
  }

  /// Navigates back to the previous screen
  ///
  /// Uses the navigator to pop the current route.
  /// Returns the robot instance for method chaining.
  Future<T> navigateBack({
    GlobalKey? waitForKey,
    bool waitForDisappear = false,
    Duration? timeout,
    Duration interval = const Duration(milliseconds: 60),
  }) async {
    NavigatorState? navigatorState;

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

    debugPrint('⬅️ Navigated back');
    return self;
  }

  /// Taps a widget identified by its [GlobalKey].
  ///
  /// Returns the robot instance for method chaining.
  Future<T> tapByKey(GlobalKey key, {String? label}) async {
    final widget = key.currentWidget;
    final ctx = key.currentContext;

    if (widget == null || ctx == null) {
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
      callback();
      debugPrint('👆 Tapped ${label ?? key.toString()}');
      return self;
    }

    throw Exception('Widget ${label ?? key.toString()} is not tappable');
  }

  /// Taps a button by key and waits for animation/transition
  ///
  /// This is a common pattern for tapping buttons that trigger navigation.
  /// Returns the robot instance for method chaining.
  Future<T> tapAndWait(
    GlobalKey key, {
    String? label,
    Duration waitDuration = RobotConfig.defaultTapWait,
    GlobalKey? waitForKey,
    bool waitForDisappear = false,
    Duration? timeout,
    Duration interval = const Duration(milliseconds: 60),
  }) async {
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
    return self;
  }

  /// Sets the value of a text input widget identified by [key].
  ///
  /// Supports [TextField], [TextFormField], and [EditableText] instances that
  /// expose a [TextEditingController].
  Future<T> enterText(GlobalKey key, String text, {String? label}) async {
    final widget = key.currentWidget;

    if (widget == null) {
      throw Exception(
        'Text input ${label ?? key.toString()} not found via global key',
      );
    }

    final editable = _resolveEditable(widget);
    if (editable == null) {
      throw Exception(
        'Widget ${label ?? key.toString()} is not a supported text input',
      );
    }

    editable.controller
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
    editable.onChanged?.call(text);

    debugPrint('⌨️ Entered "$text" into ${label ?? key.toString()}');
    await wait(RobotConfig.defaultTapWait);
    return self;
  }

  /// Reads the current value from a text input identified by [key].
  String readText(GlobalKey key, {String? label}) {
    final widget = key.currentWidget;

    if (widget == null) {
      throw Exception(
        'Text input ${label ?? key.toString()} not found via global key',
      );
    }

    final editable = _resolveEditable(widget);
    if (editable == null) {
      throw Exception(
        'Widget ${label ?? key.toString()} is not a supported text input',
      );
    }

    return editable.controller.text;
  }

  _EditableInput? _resolveEditable(Widget widget) {
    if (widget is TextField) {
      final controller = widget.controller;
      if (controller == null) {
        throw Exception(
          'TextField ${widget.key?.toString() ?? ''} requires a controller',
        );
      }
      return _EditableInput(controller, widget.onChanged);
    }

    if (widget is TextFormField) {
      final controller = widget.controller;
      if (controller == null) {
        throw Exception(
          'TextFormField ${widget.key?.toString() ?? ''} requires a controller',
        );
      }
      return _EditableInput(controller, widget.onChanged);
    }

    if (widget is EditableText) {
      return _EditableInput(widget.controller, widget.onChanged);
    }

    if (widget is KeyedSubtree) {
      return _resolveEditable(widget.child);
    }

    return null;
  }

  String _composeScreenshotName(String name) {
    final sanitizedBase = _sanitizeForFileName(name);
    if (testStep == null) {
      return sanitizedBase;
    }

    final stepSlug = _sanitizeForFileName(testStep!.name);
    if (stepSlug.isEmpty || stepSlug == sanitizedBase) {
      return sanitizedBase;
    }

    if (sanitizedBase.startsWith('${stepSlug}_')) {
      return sanitizedBase;
    }

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

/// Custom timeout exception specific to Robot wait utilities.
/// Named distinctly to avoid shadowing dart:async's [TimeoutException].
class RobotTimeoutException implements Exception {
  RobotTimeoutException(this.message);

  final String message;

  @override
  String toString() => 'RobotTimeoutException: $message';
}

class _EditableInput {
  _EditableInput(this.controller, this.onChanged);

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
}
