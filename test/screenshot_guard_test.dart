import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot_guard/screenshot_guard.dart';
import 'package:screenshot_guard/screenshot_guard_platform_interface.dart';
import 'package:screenshot_guard/screenshot_guard_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockScreenshotGuardPlatform with MockPlatformInterfaceMixin implements ScreenshotGuardPlatform {
  // Mock for enableSecureFlag method
  @override
  Future<void> enableSecureFlag(bool enable) async {
    // Implement the mock logic if necessary (no-op for now)
    return;
  }

  // Mock for getPlatformVersion method
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ScreenshotGuardPlatform initialPlatform = ScreenshotGuardPlatform.instance;

  test('$MethodChannelScreenshotGuard is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelScreenshotGuard>());
  });

  test('getPlatformVersion', () async {
    ScreenshotGuard screenshotGuardPlugin = ScreenshotGuard();
    MockScreenshotGuardPlatform fakePlatform = MockScreenshotGuardPlatform();
    ScreenshotGuardPlatform.instance = fakePlatform;

    // Test getPlatformVersion
    expect(await screenshotGuardPlugin.getPlatformVersion(), '42');
  });

  test('enableSecureFlag', () async {
    ScreenshotGuard screenshotGuardPlugin = ScreenshotGuard();
    MockScreenshotGuardPlatform fakePlatform = MockScreenshotGuardPlatform();
    ScreenshotGuardPlatform.instance = fakePlatform;

    // Test enableSecureFlag method
    await screenshotGuardPlugin.enableSecureFlag(enable: true);
    // Add any necessary verification or assertions if needed
  });
}
