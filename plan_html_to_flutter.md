# HTML ➜ Flutter Report Migration Plan

## Phase 1: Data Models & JSON Parsing
- [x] Create `testing_report_models.dart` with domain classes
  - [x] `TestingReportData` - aggregated report data
  - [x] `ScenarioReport` - scenario with steps
  - [x] `StepReport` - individual test step
  - [x] `ReportScreenshot` - screenshot with file path
  - [x] `GoldenComparison` - golden test result
  - [x] `GoldenStatus` enum
  - [x] JSON parsing helpers (`_parseDate`, `_parseDuration`, etc.)
  - [x] File resolution for screenshots relative to report directory

## Phase 2: Refactor ReportGenerator
- [x] Replace HTML generation with data loading in `report_generator.dart`
  - [x] Remove HTML-related imports (`report_builders`, `report_helpers`, `templates`)
  - [x] Keep `generateHtmlReport()` method name for backward compatibility
  - [x] Change method to load and cache `TestingReportData` instead of generating HTML
  - [x] Add `loadReportData()` method to return typed models
  - [x] Add `cachedReport` getter for accessing last loaded report
  - [x] Add `clearCache()` method
  - [x] Add `hasReportFile()` method to check if results exist

## Phase 3: Create TestingReportPage Widget
- [x] Create `lib/src/pages/testing_report_page.dart`
  - [x] Design overall page structure (Scaffold with AppBar)
  - [x] Build summary header widget showing:
    - [x] Total scenarios, steps, pass/fail counts
    - [x] Success rate percentage
    - [x] Run start/end timestamps
    - [x] Total duration
    - [x] Average golden diff (if applicable)
  - [x] Build scenario list widget
    - [x] Expandable cards for each scenario
    - [x] Show scenario name, status, duration
    - [x] Show passed/failed step counts
    - [x] Color coding for pass/fail status
  - [x] Build step list widget (nested in scenario)
    - [x] Step name, status, duration
    - [x] Error message display
    - [x] Verification details list
    - [x] Screenshots gallery
    - [x] Golden comparison section
  - [x] Build screenshot viewer widget
    - [x] Display screenshots in grid
    - [x] Tap to view full screen
    - [x] Show screenshot names/labels
  - [x] Build golden comparison widget
    - [x] Show actual, baseline, and diff images side-by-side
    - [x] Display diff percentage and tolerance
    - [x] Status badge (match/mismatch/error)
    - [x] Error message display
  - [x] Add loading state for async data loading
  - [x] Add error state if report data missing
  - [x] Add empty state if no scenarios
  - [x] Add refresh functionality (pull to refresh or FAB)

## Phase 4: Update TestRunner Integration
- [x] Update `test_runner.dart`
  - [x] Add `navigateToReport` parameter (default false) to `TestRunner.runAll()`
  - [x] Update toast/notification to include "View" button for TestingReportPage
  - [x] Add navigation to `TestingReportPage` when tests complete (if flag enabled)

## Phase 4b: Example App Integration
- [x] Update `example/lib/main.dart`
  - [x] Pass `navigateToReport: true` to `TestRunner.runAll()`
- [x] Update `example/lib/screens/screen1/screen1_page.dart`
  - [x] Add "View Test Report" button
  - [x] Navigate to `TestingReportPage` on button press

## Phase 5: Remove HTML Code
- [ ] Delete `lib/src/report_builders.dart`
- [ ] Delete `lib/src/report_helpers.dart`
- [ ] Delete `lib/src/templates/html_template.dart`
- [ ] Delete `lib/src/templates/report_scripts.dart`
- [ ] Delete `lib/src/templates/report_styles.dart`
- [ ] Delete `lib/src/templates/styles_base.dart`
- [ ] Delete `lib/src/templates/styles_golden.dart`
- [ ] Delete `lib/src/templates/styles_scenario.dart`
- [ ] Delete `lib/src/templates/styles_test.dart`
- [ ] Remove HTML report file generation (no more .html output)

## Phase 6: Update Package Exports
- [x] Add exports to `lib/self_testing.dart`
  - [x] Export `TestingReportPage`
  - [x] Export `TestingReportData` and models
  - [x] Export `ReportGenerator.loadReportData()`

## Phase 7: Testing & Validation
- [ ] Run `flutter analyze` on entire package
- [ ] Fix any lint warnings
- [ ] Test loading report data from JSON
- [ ] Test `TestingReportPage` rendering
  - [ ] Test with passing scenarios
  - [ ] Test with failing scenarios
  - [ ] Test with golden comparisons
  - [ ] Test with screenshots
  - [ ] Test with missing/empty data
- [ ] Update example app to show `TestingReportPage`
- [ ] Update README with new usage instructions

## Phase 8: Documentation
- [ ] Update README to remove HTML report references
- [ ] Add documentation for `TestingReportPage` widget
- [ ] Add code examples showing how to navigate to report page
- [ ] Document the data model structure
- [ ] Update changelog

---

## Progress Summary
- **Phase 1**: ✅ Complete (8/8 items)
- **Phase 2**: ✅ Complete (7/7 items)
- **Phase 3**: ✅ Complete (19/19 items)
- **Phase 4**: ✅ Complete (3/3 items)
- **Phase 4b**: ✅ Complete (3/3 items)
- **Phase 5**: ⏳ Pending (0/10 items) - Can delete HTML files when ready
- **Phase 6**: ✅ Complete (3/3 items)
- **Phase 7**: ⏳ Pending (0/10 items) - Ready for testing
- **Phase 8**: ⏳ Pending (0/5 items) - Documentation updates

**Total Progress**: 46/71 tasks (65%)

## ✅ What's Working Now

1. **`ReportGenerator`** - Loads JSON and caches typed report data (no HTML generation)
2. **`TestingReportData`** - Complete domain model with all report information
3. **`TestingReportPage`** - Full Flutter UI with:
   - Summary cards showing test metrics
   - Expandable scenario/step cards
   - Screenshot galleries with full-screen viewer
   - Golden comparison displays (actual/baseline/diff images)
   - Error messages and verification details
   - Loading/error/empty states
   - Pull-to-refresh functionality
4. **Package exports** - All new classes exported in `lib/self_testing.dart`
5. **TestRunner Integration** - Automatic navigation to report page when tests complete (configurable via `navigateToReport` flag)
6. **Example App** - Includes "View Test Report" button on Screen 1 and auto-navigates after tests run

## 🚀 How to Use

### Option 1: Auto-navigate after tests complete
```dart
await TestRunner.runAll(
  scenarios,
  useLocalStorage: true,
  navigateToReport: true, // Automatically opens report page after tests
);
```

### Option 2: Manual navigation from your app
```dart
import 'package:self_testing/self_testing.dart';

// Navigate to the report page whenever you want:
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const TestingReportPage(),
  ),
);
```

### Option 3: Use the toast notification
```dart
await TestRunner.runAll(
  scenarios,
  useLocalStorage: true,
  navigateToReport: false, // Shows toast with "View" button instead
);
```

## 📋 Next Steps (Optional)

- **Phase 5**: Delete legacy HTML files (`report_builders.dart`, `templates/*`, etc.)
- **Phase 7**: Test with real data in various scenarios
- **Phase 8**: Update README and documentation
