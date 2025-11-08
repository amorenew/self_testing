# 500-Line Limit Refactoring Plan

## Current Status

### ✅ All Files Now Under 500 Lines!

**Previously exceeding 500 lines:**
- [x] `lib/src/html_template.dart` - **1,212 lines** → Split into 7 files (all under 280 lines)
- [x] `lib/src/report_generator.dart` - **678 lines** → Split into 3 files (112, 141, 384 lines)
- [x] `lib/src/base_robot.dart` - **567 lines** → Split into 4 files (149, 91, 70, 227 lines)

**Largest files now:**
1. `lib/src/report_builders.dart` - 384 lines (23% under limit)
2. `lib/src/screenshot_helper.dart` - 338 lines (32% under limit)
3. `lib/src/test_runner.dart` - 324 lines (35% under limit)

---

## Refactoring Tasks

### 1. html_template.dart (1,212 → ~300 lines per file)
- [x] Extract CSS styles into `lib/src/templates/report_styles.dart`
- [x] Extract JavaScript code into `lib/src/templates/report_scripts.dart`
- [x] Keep HTML structure in `lib/src/templates/html_template.dart` and make it modular:
  - [x] Extract header section into function/component
  - [x] Extract stats/metrics section into function/component
  - [x] Extract scenario card section into function/component
  - [x] Extract test card section into function/component
  - [x] Extract golden comparison section into function/component
  - [x] Keep main template as composition of sections
- [x] Update imports in `report_generator.dart`
- [ ] Test HTML report generation

### 2. report_generator.dart (678 → ~350 lines per file)
- [x] Extract JSON serialization logic into `lib/src/report_json_serializer.dart`
- [x] Extract helper methods into `lib/src/report_helpers.dart`
- [x] Extract HTML builders into `lib/src/report_builders.dart`
- [x] Keep main report generation orchestration in `lib/src/report_generator.dart`
- [x] Update imports and exports
- [ ] Test report generation end-to-end

### 3. base_robot.dart (567 → ~250 lines per file)
- [x] Extract verification methods into `lib/src/robot_verifications.dart`
- [x] Extract wait/timing utilities into `lib/src/robot_wait_helpers.dart`
- [x] Extract action methods into `lib/src/robot_actions.dart`
- [x] Keep core robot functionality in `lib/src/base_robot.dart`
- [ ] Update all robot implementations that extend BaseRobot
- [ ] Test all robot functionality

---

## Validation & Documentation

### 4. Create Validation Script
- [x] Create `scripts/check_line_limits.dart` to enforce 500-line limit
- [ ] Add script to CI/CD pipeline (if applicable)
- [x] Document how to run the validation script

### 5. Update Documentation
- [ ] Add 500-line limit rule to project README
- [ ] Update contributing guidelines (if exists)
- [ ] Document refactoring patterns for future reference

---

## Verification
- [ ] Run all tests to ensure no regressions
- [ ] Verify HTML report generation works correctly
- [ ] Verify all robot functionality works as expected
- [x] Run line limit validation script
- [x] Confirm all files are under 500 lines

---

## Notes
- Keep related functionality together when splitting files
- Maintain clear separation of concerns
- Preserve existing public APIs
- Update exports in `lib/self_testing.dart` if needed

## How to Run Validation

To check that all Dart files are under 500 lines:

```bash
dart scripts/check_line_limits.dart
```

This script will:
- Scan all `.dart` files in the `lib/` directory
- Report any files exceeding 500 lines
- Show the 5 largest files
- Exit with code 0 if all files pass, 1 if any violations found
