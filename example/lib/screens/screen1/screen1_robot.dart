import 'package:flutter/material.dart';
import 'package:self_testing_example/app_keys.dart';
import 'package:self_testing/self_testing.dart';

class Screen1Robot extends BaseRobot<Screen1Robot> {
  Screen1Robot({this.context, super.testStep});

  @override
  final BuildContext? context;

  Screen1Robot verifyScreen1Displayed() {
    verifyWidgetExists(AppKeys.screen1Title, label: 'Screen 1 title');
    verifyWidgetExists(AppKeys.screen1Greeting, label: 'Screen 1 greeting');
    verifyWidgetExists(AppKeys.navigateButton, label: 'Navigate button');
    debugPrint('✅ Screen 1 is displayed correctly');
    return this;
  }

  Future<Screen1Robot> tapNavigateButton() async {
    return tapAndWait(
      AppKeys.navigateButton,
      label: 'Navigate button',
      waitForKey: AppKeys.screen2Title,
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
