import 'screenshot_guard_platform_interface.dart';

class ScreenshotGuard {
  Future<String?> getPlatformVersion() {
    return ScreenshotGuardPlatform.instance.getPlatformVersion();
  }

  /// Enables or disables the secure flag to prevent screenshots.
  Future<void> enableSecureFlag({required bool enable}) {
    return ScreenshotGuardPlatform.instance.enableSecureFlag(enable);
  }
}
