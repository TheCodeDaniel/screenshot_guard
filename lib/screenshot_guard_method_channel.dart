import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'screenshot_guard_platform_interface.dart';

/// An implementation of [ScreenshotGuardPlatform] that uses method channels.
class MethodChannelScreenshotGuard extends ScreenshotGuardPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('screenshot_guard');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> enableSecureFlag(bool enable) async {
    try {
      await methodChannel.invokeMethod('enableSecureFlag', {'enable': enable});
    } on PlatformException catch (e) {
      throw Exception("Error enabling secure flag: $e");
    }
  }
}
