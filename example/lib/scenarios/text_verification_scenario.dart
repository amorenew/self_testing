import 'package:self_testing_example/app_keys.dart';
import 'package:self_testing_example/screens/screen1/screen1_robot.dart';
import 'package:self_testing_example/screens/screen2/screen2_robot.dart';
import 'package:self_testing/self_testing.dart';

class TextVerificationScenario {
  TestScenario build() => TestScenario(
    name: 'Text Verification',
    steps: [
      TestStep(
        name: 'Verify Screen 1 Texts',
        action: (step) async {
          final robot = Screen1Robot(testStep: step);
          robot.verifyTextEquals(
            AppKeys.screen1Title,
            'Screen 1',
            label: 'Screen 1 title text',
          );
          robot.verifyTextEquals(
            AppKeys.screen1Greeting,
            'Hello World',
            label: 'Screen 1 greeting text',
          );
          robot.verifyTextEquals(
            AppKeys.navigateButton,
            'Go to Screen 2',
            label: 'Navigate button label',
          );
        },
      ),
      TestStep(
        name: 'Verify Screen 2 Texts',
        action: (step) async {
          final screen1Robot = Screen1Robot(testStep: step);
          await screen1Robot.tapNavigateButton();

          final screen2Robot = Screen2Robot(testStep: step);
          await screen2Robot.waitForLoad(readyKey: AppKeys.screen2Title);
          screen2Robot.verifyTextEquals(
            AppKeys.screen2Title,
            'Screen 2',
            label: 'Screen 2 title text',
          );
          screen2Robot.verifyTextEquals(
            AppKeys.screen2Greeting,
            'Hello World 2',
            label: 'Screen 2 greeting text',
          );

          await screen2Robot.navigateBack(
            waitForKey: AppKeys.screen2Title,
            waitForDisappear: true,
          );
        },
      ),
    ],
  );
}
