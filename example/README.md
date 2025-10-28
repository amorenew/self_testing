# Self Testing Example

This example demonstrates how to use the `self_testing` package in a Flutter application.

## Getting Started

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Platform Support

This example supports multiple platforms:

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

### Web
First, enable web support:
```bash
flutter config --enable-web
```

Then run on web:
```bash
flutter run -d chrome
```

### macOS
First, enable macOS support:
```bash
flutter config --enable-macos
```

Then run on macOS:
```bash
flutter run -d macos
```

## What it does

This example app shows:
- How to import and use the `Calculator` class from the `self_testing` package
- Using the `addOne` method to increment a counter
- A simple Flutter UI that demonstrates the package functionality

The app displays a counter that increments when you press the floating action button, using the `Calculator.addOne()` method from the package.