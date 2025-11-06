import 'package:flutter/material.dart';
import 'package:self_testing/self_testing.dart';

class AppKeys {
  AppKeys._();

  static final GlobalAppKey screenshot = GlobalAppKey(debugLabel: 'screenshot');
  static final GlobalAppKey<NavigatorState> navigator =
      GlobalAppKey<NavigatorState>(debugLabel: 'navigator');
  static final GlobalAppKey navigateButton =
      GlobalAppKey(debugLabel: 'navigateButton');
  static final GlobalAppKey screen1Title =
      GlobalAppKey(debugLabel: 'screen1Title');
  static final GlobalAppKey screen1Greeting =
      GlobalAppKey(debugLabel: 'screen1Greeting');
  static final GlobalAppKey screen2Title =
      GlobalAppKey(debugLabel: 'screen2Title');
  static final GlobalAppKey screen2Greeting =
      GlobalAppKey(debugLabel: 'screen2Greeting');
  static final GlobalAppKey screen2InputField =
      GlobalAppKey(debugLabel: 'screen2InputField');
  static final GlobalAppKey screen2InputPreview =
      GlobalAppKey(debugLabel: 'screen2InputPreview');

  /// Regenerates all Screen 2 keys so fresh widgets get unique [GlobalKey]s.
  static void regenerateScreen2Keys() {
    screen2Title.regenerate();
    screen2Greeting.regenerate();
    screen2InputField.regenerate();
    screen2InputPreview.regenerate();
  }
}
