/// Centralized configuration values for Robot Pattern tests.
///
/// Keeping durations and other tunables here makes it easy to adjust
/// timings for animations or slower CI environments without touching
/// individual robot implementations.
class RobotConfig {
  /// Generic short wait used for screen loading or simple transitions.
  static const Duration defaultWait = Duration(milliseconds: 500);

  /// Wait used after tap actions that trigger navigation or animations.
  static const Duration defaultTapWait = Duration(milliseconds: 300);

  /// Fallback delay between test steps when sequencing through the runner.
  ///
  /// The runner now attempts to detect when the UI is idle and will only use
  /// this duration if it cannot determine the next frame readiness in time.
  static const Duration defaultPostTestDelay = Duration(milliseconds: 150);

  /// Maximum time to wait while polling the Flutter scheduler for the UI to
  /// settle before proceeding to the next test step.
  static const Duration uiSettleTimeout = Duration(seconds: 2);
}
