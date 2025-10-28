import 'package:flutter/material.dart';

class AppKeys {
  AppKeys._();

  static final GlobalKey screenshot = GlobalKey();
  static final GlobalKey<NavigatorState> navigator =
      GlobalKey<NavigatorState>();
  static final GlobalKey navigateButton = GlobalKey();
  static final GlobalKey screen1Title = GlobalKey();
  static final GlobalKey screen1Greeting = GlobalKey();
  static final GlobalKey screen2Title = GlobalKey();
  static final GlobalKey screen2Greeting = GlobalKey();
  static final GlobalKey screen2InputField = GlobalKey();
  static final GlobalKey screen2InputPreview = GlobalKey();
}
