import 'package:self_testing_example/app_keys.dart';
import 'package:self_testing_example/screens/screen1/screen1_robot.dart';
import 'package:self_testing_example/screens/screen2/screen2_robot.dart';
import 'package:self_testing/self_testing.dart';

class InputFieldScenario {
  TestScenario build() => TestScenario(
    name: 'Screen 2 Input Field',
    steps: [
      TestStep(
        name: 'Navigate to Screen 2',
        action: (step) async {
          final screen1Robot = Screen1Robot(testStep: step);
          await screen1Robot.verifyAndNavigate();
        },
      ),
      TestStep(
        name: 'Enter and Verify Text',
        action: (step) async {
          final screen2Robot = Screen2Robot(testStep: step);
          await screen2Robot.waitForLoad(readyKey: AppKeys.screen2Title.currentKey);
          screen2Robot.verifyPreview('Nothing typed yet');

          await screen2Robot.enterMessage('Hello Flutter');

          screen2Robot.verifyPreview('You typed: Hello Flutter');
          
          await screen2Robot.captureScreenshot('Enter and Verify Text');

          await screen2Robot.enterMessage('Hello Flutter2');
          await screen2Robot.captureScreenshot('Enter and Verify Text2');

          await screen2Robot.enterMessage('Hello Flutter3');
          await screen2Robot.captureScreenshot('Enter and Verify Text3');

          await screen2Robot.navigateBack(
            waitForKey: AppKeys.screen2Title.currentKey,
            waitForDisappear: true,
          );
          final screen1Robot = Screen1Robot(testStep: step);
          await screen1Robot.waitForLoad(readyKey: AppKeys.screen1Title.currentKey);
        },
      ),
    ],
  );
}
