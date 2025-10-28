import 'package:flutter/material.dart';

class ActionHelper {
  static Future<void> tapButtonByKey(GlobalKey key, {String? name}) async {
    final widget = key.currentWidget;
    final context = key.currentContext;

    if (widget == null || context == null) {
      final error = Exception(
        'Widget ${name ?? key.toString()} not found via global key',
      );
      debugPrint('❌ Failed to tap widget: $error');
      throw error;
    }

    VoidCallback? callback;

    if (widget is ButtonStyleButton) {
      callback = widget.onPressed;
    } else if (widget is GestureDetector) {
      callback = widget.onTap;
    }

    if (callback != null) {
      callback();
      debugPrint('👆 Tapped widget ${name ?? key.toString()} via global key');
      return;
    }

    final element = context as Element;
    final inheritedWidget = element.widget;

    if (inheritedWidget is ButtonStyleButton &&
        inheritedWidget.onPressed != null) {
      inheritedWidget.onPressed!();
      debugPrint(
        '👆 Tapped widget ${name ?? key.toString()} via element widget',
      );
      return;
    }

    final error = Exception(
      'Widget ${name ?? key.toString()} is not tappable via global key',
    );
    debugPrint('❌ Failed to tap widget: $error');
    throw error;
  }
}
