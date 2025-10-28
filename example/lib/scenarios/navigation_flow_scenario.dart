import 'package:self_testing_example/screens/screen1/screen1_robot.dart';
import 'package:self_testing_example/screens/screen2/screen2_robot.dart';
import 'package:self_testing/self_testing.dart';

class NavigationFlowScenario {
  TestScenario build() => TestScenario(
    name: 'Navigation Flow',
    steps: [
      TestStep(
        name: 'Screen 1',
        action: (step) async {
          final robot = Screen1Robot(testStep: step);
          await robot.verifyScreen1Displayed().captureScreenshot('screen_1');
        },
        screenshots: const ['screen_1.png'],
      ),
      TestStep(
        name: 'Tap Button',
        action: (step) async {
          final robot = Screen1Robot(testStep: step);
          await robot.tapNavigateButton();
        },
      ),
      TestStep(
        name: 'Screen 2',
        action: (step) async {
          final robot = Screen2Robot(testStep: step);
          await robot.verifyAndCapture('screen_2');
        },
        screenshots: const ['screen_2.png'],
      ),
    ],
  );
}
