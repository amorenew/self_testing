import 'package:flutter/material.dart';
import 'package:self_testing_example/app_keys.dart';
import 'package:self_testing/self_testing.dart';

class Screen1Robot extends BaseRobot<Screen1Robot> {
  Screen1Robot({this.context, super.testStep});

  @override
  final BuildContext? context;

  Screen1Robot verifyScreen1Displayed() {
    verifyWidgetExists(AppKeys.screen1Title.currentKey, label: 'Screen 1 title');
    verifyWidgetExists(AppKeys.screen1Greeting.currentKey, label: 'Screen 1 greeting');
    verifyWidgetExists(AppKeys.navigateButton.currentKey, label: 'Navigate button');
    debugPrint('✅ Screen 1 is displayed correctly');
    return this;
  }

  Future<Screen1Robot> tapNavigateButton() async {
    AppKeys.regenerateScreen2Keys();
    final nextScreenTitleKey = AppKeys.screen2Title.currentKey;
    return tapAndWait(
      AppKeys.navigateButton.currentKey,
      label: 'Navigate button',
      waitForKey: nextScreenTitleKey,
    );
  }

  Future<Screen1Robot> verifyAndNavigate({String? screenshotName}) async {
    verifyScreen1Displayed();
    if (screenshotName != null) {
      await captureScreenshot(screenshotName);
    }
    await tapNavigateButton();
    return this;
  }
}
