import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Central place for configuring shared testing resources such as global keys
/// and filesystem locations.
class SelfTesting {
  SelfTesting._();

  static GlobalKey? _screenshotKey;
  static GlobalKey<NavigatorState>? _navigatorKey;
  static Directory? _projectRootOverride;

  static final Directory _defaultProjectRoot = Directory(
    '/Users/amr/Desktop/private/programming/ment/sources/self_testing',
  );

  static bool _useLocalStorage = false;
  static bool _updateGoldenBaselines = false;
  static double _goldenDiffTolerance = 0.1;
  static bool _logRobotActions = false;

  /// Initializes the testing environment with keys and configuration.
  static void initialize({
    required GlobalKey<NavigatorState> navigatorKey,
    required GlobalKey screenshotKey,
    Directory? projectRoot,
    bool useLocalStorage = false,
    bool updateGoldenBaselines = false,
    double goldenDiffTolerance = 0.1,
    bool logRobotActions = false,
  }) {
    _navigatorKey = navigatorKey;
    _screenshotKey = screenshotKey;
    _projectRootOverride = projectRoot ?? _defaultProjectRoot;
    _useLocalStorage = useLocalStorage;
    _updateGoldenBaselines = updateGoldenBaselines;
    _goldenDiffTolerance = goldenDiffTolerance;
    _logRobotActions = logRobotActions;

    TestingDiagnostics.ensureInitialized();
  }

  /// Updates the navigator key at runtime.
  static void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Updates the screenshot key at runtime.
  static void setScreenshotKey(GlobalKey screenshotKey) {
    _screenshotKey = screenshotKey;
  }

  /// Returns the registered navigator key or throws if it is missing.
  static GlobalKey<NavigatorState> get navigatorKey {
    final key = _navigatorKey;
    if (key == null) {
      throw StateError(
        'Navigator key not registered. Call SelfTesting.initialize first.',
      );
    }
    return key;
  }

  /// Returns the registered screenshot key or throws if it is missing.
  static GlobalKey get screenshotKey {
    final key = _screenshotKey;
    if (key == null) {
      throw StateError(
        'Screenshot key not registered. Call SelfTesting.initialize first.',
      );
    }
    return key;
  }

  /// Returns the navigator key when available.
  static GlobalKey<NavigatorState>? get maybeNavigatorKey => _navigatorKey;

  /// Returns the screenshot key when available.
  static GlobalKey? get maybeScreenshotKey => _screenshotKey;

  /// Indicates whether both keys have been registered.
  static bool get isConfigured =>
      _navigatorKey != null && _screenshotKey != null;

  /// Whether screenshots should be stored locally.
  static bool get useLocalStorage => _useLocalStorage;

  /// Whether golden baselines should be updated automatically.
  static bool get updateGoldenBaselines => _updateGoldenBaselines;

  /// The tolerance value to use during golden comparisons.
  static double get goldenDiffTolerance => _goldenDiffTolerance;

  /// Whether robot helper methods should emit verbose debug logs.
  static bool get logRobotActions => _logRobotActions;

  /// Overrides the default project root directory used for reports.
  static void setProjectRootDirectory(Directory directory) {
    _projectRootOverride = directory;
  }

  /// Overrides the default project root directory using a file system path.
  static void setProjectRootPath(String path) {
    setProjectRootDirectory(Directory(path));
  }

  /// Returns the active project root directory (override or default).
  static Directory get projectRootDirectory =>
      _projectRootOverride ?? _defaultProjectRoot;

  /// Returns the custom project root directory when present.
  static Directory? get maybeProjectRootDirectory => _projectRootOverride;

  /// Returns the active project root path as a string.
  static String get projectRootPath => projectRootDirectory.path;

  /// Enables or disables verbose robot logging at runtime.
  static void setLogRobotActions(bool value) {
    _logRobotActions = value;
  }
}

/// Tracks the currently running scenario, step, and last robot action to aid
/// in debugging failures that surface through the Flutter error pipeline.
class TestingDiagnostics {
  TestingDiagnostics._();

  static String? _activeScenario;
  static String? _activeStep;
  static String? _lastAction;
  static bool _initialized = false;
  static FlutterExceptionHandler? _previousErrorHandler;

  /// Captures Flutter errors and augments the log with testing context.
  static void ensureInitialized() {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _previousErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      _emitContextBanner();
      _previousErrorHandler?.call(details);
    };
  }

  /// Marks the currently executing scenario by name.
  static void setActiveScenario(String? scenarioName) {
    _activeScenario = scenarioName;
    if (scenarioName != null && scenarioName.trim().isNotEmpty) {
      debugPrint('🧭 Active scenario → $scenarioName');
    }
  }

  /// Marks the currently executing step by name.
  static void setActiveStep(String? stepName) {
    _activeStep = stepName;
    if (stepName != null && stepName.trim().isNotEmpty) {
      debugPrint('🧪 Active step → $stepName');
    }
  }

  /// Records the last robot action message.
  static void recordAction(String actionDescription) {
    _lastAction = actionDescription;
  }

  /// Emits the current testing context to the debug console.
  static void emitContextSnapshot({String prefix = '🔍'}) {
    _emitContextBanner(prefix: prefix);
  }

  static void _emitContextBanner({String prefix = '⛔'}) {
    final lines = <String>[];
    lines.add('$prefix Flutter error captured during self-testing context:');
    if (_activeScenario != null) {
      lines.add('   • Scenario: $_activeScenario');
    }
    if (_activeStep != null) {
      lines.add('   • Step: $_activeStep');
    }
    if (_lastAction != null) {
      lines.add('   • Last robot action: $_lastAction');
    }
    debugPrint(lines.join('\n'));
  }
}
