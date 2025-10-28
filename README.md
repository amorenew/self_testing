# Visual Robot Testing Harness

This project demonstrates a Flutter application instrumented with the Robot Testing Pattern, automated screenshot capture, and golden-diff reporting. Robots encapsulate user flows for each screen, capture visual output, and write metadata that powers an HTML report under `report/`.

## Project Layout

- `lib/screens/<screen>/` - concrete screen widgets and their screen-specific robots.
- `lib/robots/` - shared robot utilities and robot configuration.
- `lib/scenarios/` - declarative `TestScenario` builders executed by the runner.
- `lib/screenshot_helper.dart` - handles screenshot capture, golden comparison, and diff image generation.
- `lib/test_runner.dart` - coordinates the test steps and produces `report/test_results.json`.
- `report/` - stores screenshots, goldens, diffs, and the generated HTML report.

## Running the Visual Tests

Launch the Flutter app (desktop or mobile). Tests run after the first frame thanks to `WidgetsBinding.instance.addPostFrameCallback`. Results are logged to the console and aggregated in `report/test_results.json`.

## Managing Golden Baselines

Two `--dart-define` flags control golden behavior:

| Flag | Default | Description |
| --- | --- | --- |
| `GOLDEN_TOLERANCE` | `0.1` | Maximum diff percentage allowed before marking a mismatch. |
| `UPDATE_GOLDENS` | `false` | When `true`, copies the latest screenshots into `report/goldens/` to refresh baselines. |

Update baselines when UI changes are intentional:

```bash
flutter run \
	--dart-define=UPDATE_GOLDENS=true \
	--dart-define=GOLDEN_TOLERANCE=0.1
```

After the run finishes, revert to a normal configuration (no env overrides) to enforce the refreshed baselines.

If you need a different tolerance temporarily (e.g., noisy animations), supply a new value when launching:

```bash
flutter run --dart-define=GOLDEN_TOLERANCE=0.15
```

## Viewing the HTML Report

When local storage is enabled (`ScreenshotHelper.useLocalStorage = true`), the test runner generates `report/test_results.json`. The HTML report is available at `report/test_report.html`, showing pass/fail status, diffs, and screenshots side-by-side.

### Grouping Scenarios

- Wrap related steps in a `TestScenario` to group user journeys.
- Each scenario collapses in the HTML report, with nested cards for individual steps.
- Scenario metadata (start/end/duration) rolls up in `test_results.json` alongside per-step details.

## Robot Pattern Overview

- **Keep robots focused.** Each robot targets one screen/component.
- **Expose verifications.** Robots assert UI state via `verifyWidgetExists`, etc.
- **Support method chaining.** All robot actions return the robot instance for fluent flows.
- **Handle async waits.** Use `waitForLoad`, `waitUntil`, and `tapAndWait` to cover transitions.

Refer to `lib/robots/base_robot.dart` for shared utilities and to `lib/screens/screen1/screen1_robot.dart` / `lib/screens/screen2/screen2_robot.dart` for concrete examples.
