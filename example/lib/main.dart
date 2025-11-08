import 'dart:io';

import 'package:flutter/material.dart';
import 'package:self_testing_example/app_keys.dart';
import 'package:self_testing_example/scenarios/input_field_scenario.dart';
import 'package:self_testing_example/scenarios/navigation_flow_scenario.dart';
import 'package:self_testing_example/scenarios/text_verification_scenario.dart';
import 'package:self_testing_example/screens/screen1/screen1_page.dart';
import 'package:self_testing/self_testing.dart';

void main() {
  const toleranceEnv = String.fromEnvironment(
    'GOLDEN_TOLERANCE',
    defaultValue: '0.1',
  );
  final goldenDiffTolerance = double.tryParse(toleranceEnv) ?? 0.1;
  final updateGoldens = const bool.fromEnvironment('UPDATE_GOLDENS');

  SelfTesting.initialize(
    navigatorKey: AppKeys.navigator.key,
    screenshotKey: AppKeys.screenshot.key,
    useLocalStorage: true,
    updateGoldenBaselines: updateGoldens,
    goldenDiffTolerance: goldenDiffTolerance,
    projectRoot: Directory(
      '/Users/amr/Desktop/private/programming/ment/sources/self_testing/example',
    ),
  );

  runApp(const MyApp());

  // Start tests after first frame to ensure widget tree built
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await TestRunner.runAll(
      [
        InputFieldScenario().build(),
        TextVerificationScenario().build(),
        NavigationFlowScenario().build(),
      ],
      useLocalStorage: SelfTesting.useLocalStorage,
      navigateToReport: true,
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: AppKeys.screenshot.key,
      child: MaterialApp(
        navigatorKey: AppKeys.navigator.key,
        home: const Screen1Page(),
      ),
    );
  }
}
