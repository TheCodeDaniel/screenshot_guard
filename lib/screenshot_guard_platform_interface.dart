import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'screenshot_guard_method_channel.dart';

abstract class ScreenshotGuardPlatform extends PlatformInterface {
  /// Constructs a ScreenshotGuardPlatform.
  ScreenshotGuardPlatform() : super(token: _token);

  static final Object _token = Object();

  static ScreenshotGuardPlatform _instance = MethodChannelScreenshotGuard();

  /// The default instance of [ScreenshotGuardPlatform] to use.
  ///
  /// Defaults to [MethodChannelScreenshotGuard].
  static ScreenshotGuardPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ScreenshotGuardPlatform] when
  /// they register themselves.
  static set instance(ScreenshotGuardPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Abstract method to enable or disable the secure flag.
  Future<void> enableSecureFlag(bool enable) {
    throw UnimplementedError('enableSecureFlag() has not been implemented.');
  }
}
