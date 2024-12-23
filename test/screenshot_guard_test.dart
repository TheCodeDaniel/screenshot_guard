import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot_guard/screenshot_guard.dart';
import 'package:screenshot_guard/screenshot_guard_platform_interface.dart';
import 'package:screenshot_guard/screenshot_guard_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockScreenshotGuardPlatform
    with MockPlatformInterfaceMixin
    implements ScreenshotGuardPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ScreenshotGuardPlatform initialPlatform =
      ScreenshotGuardPlatform.instance;

  test('$MethodChannelScreenshotGuard is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelScreenshotGuard>());
  });

  test('getPlatformVersion', () async {
    ScreenshotGuard screenshotGuardPlugin = ScreenshotGuard();
    MockScreenshotGuardPlatform fakePlatform = MockScreenshotGuardPlatform();
    ScreenshotGuardPlatform.instance = fakePlatform;

    expect(await screenshotGuardPlugin.getPlatformVersion(), '42');
  });
}
