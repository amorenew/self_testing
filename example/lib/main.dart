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
    navigatorKey: AppKeys.navigator,
    screenshotKey: AppKeys.screenshot,
    useLocalStorage: true,
    updateGoldenBaselines: updateGoldens,
    goldenDiffTolerance: goldenDiffTolerance,
    projectRoot: Directory(
      '/Users/amr/Desktop/private/programming/ment/sources/self_testing/example',
    ),
  );

  runApp(const MyApp());

  // Start tests after first frame to ensure widget tree built
  WidgetsBinding.instance.addPostFrameCallback((_) {
    TestRunner.runAll([
      InputFieldScenario().build(),
      TextVerificationScenario().build(),
      NavigationFlowScenario().build(),
    ], useLocalStorage: SelfTesting.useLocalStorage);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: AppKeys.screenshot,
      child: MaterialApp(
        navigatorKey: AppKeys.navigator,
        home: const Screen1Page(),
      ),
    );
  }
}
