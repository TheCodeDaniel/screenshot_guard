# Screenshot Guard

`Screenshot Guard` is a Flutter plugin that provides platform-specific functionality to detect and restrict screenshots or screen recording in your Flutter applications.

## Features

- 🚫 Prevent users from taking screenshots.
- 📹 Detect and react to screen recording activity.
- 📱 Supports both Android and iOS platforms.

---

## Installation

1. Add the package to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     screenshot_guard: ^<latest>
   ```

2. Run the `flutter pub get` to fetch the package.

## Usage

### Import the Package

Add the following import statement at the top of your Dart file:

```dart
import 'package:screenshot_guard/screenshot_guard.dart';


import 'package:flutter/material.dart';
import 'package:screenshot_guard/screenshot_guard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScreenshotGuardExample(),
    );
  }
}

class ScreenshotGuardExample extends StatefulWidget {
  @override
  _ScreenshotGuardExampleState createState() => _ScreenshotGuardExampleState();
}

class _ScreenshotGuardExampleState extends State<ScreenshotGuardExample> {
  bool isProtected = false;
  final _screenshotGuardPlugin = ScreenshotGuard();

  void toggleProtection() async {
    if (isProtected) {
      _screenshotGuardPlugin.enableSecureFlag(false);
    } else {
      _screenshotGuardPlugin.enableSecureFlag(true);
    }
    setState(() {
      isProtected = !isProtected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screenshot Guard Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: toggleProtection,
          child: Text(isProtected ? 'Disable Protection' : 'Enable Protection'),
        ),
      ),
    );
  }
}
```

## Platform Specific Details

### Android

- The plugin uses Android's `FLAG_SECURE` to prevent screenshots and screen recordings
- Ensure you have the necessary permissions in your `AndroidManifest.xml`.

### IOS

- The plugin uses iOS system notifications to detect screenshot and screen recording activities.

## API Reference

### Methods

`enableSecureFlag(bool enable)`

- Description: Enables or disables the secure flag to control screenshot and screen recording
- Parameters:
  `enable`: A boolean (`true` to enable protection, `false` to disable it).
- Returns: A `Future<void>`

# Contributions

Contributions are welcome! Feel free to create issues or submit pull requests to improve this plugin.
