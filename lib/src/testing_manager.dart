import 'dart:io';

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

  /// Initializes the testing environment with keys and configuration.
  static void initialize({
    required GlobalKey<NavigatorState> navigatorKey,
    required GlobalKey screenshotKey,
    Directory? projectRoot,
    bool useLocalStorage = false,
    bool updateGoldenBaselines = false,
    double goldenDiffTolerance = 0.1,
  }) {
    _navigatorKey = navigatorKey;
    _screenshotKey = screenshotKey;
    _projectRootOverride = projectRoot ?? _defaultProjectRoot;
    _useLocalStorage = useLocalStorage;
    _updateGoldenBaselines = updateGoldenBaselines;
    _goldenDiffTolerance = goldenDiffTolerance;
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
}
