import 'package:flutter/material.dart';
import 'package:self_testing_example/app_keys.dart';
import 'package:self_testing/self_testing.dart';

class Screen2Robot extends BaseRobot<Screen2Robot> {
  Screen2Robot({this.context, super.testStep});

  @override
  final BuildContext? context;

  Screen2Robot verifyScreen2Displayed() {
    verifyWidgetExists(AppKeys.screen2Title, label: 'Screen 2 title');
    verifyWidgetExists(AppKeys.screen2Greeting, label: 'Screen 2 greeting');
    verifyWidgetExists(
      AppKeys.screen2InputField,
      label: 'Screen 2 input field',
    );
    verifyWidgetExists(
      AppKeys.screen2InputPreview,
      label: 'Screen 2 input preview',
    );
    debugPrint('✅ Screen 2 is displayed correctly');
    return this;
  }

  Future<Screen2Robot> verifyAndCapture(String screenshotName) async {
    await waitForLoad(readyKey: AppKeys.screen2Title);
    verifyScreen2Displayed();
    await captureScreenshot(screenshotName);
    return this;
  }

  Future<Screen2Robot> enterMessage(String text) {
    return enterText(
      AppKeys.screen2InputField,
      text,
      label: 'Screen 2 input field',
    );
  }

  Screen2Robot verifyPreview(String expectedText) {
    verifyTextEquals(
      AppKeys.screen2InputPreview,
      expectedText,
      label: 'Screen 2 input preview text',
    );
    return this;
  }
}
