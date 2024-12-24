import Flutter
import UIKit
import ScreenProtectorKit

public class ScreenshotGuardPlugin: NSObject, FlutterPlugin {

    private var screenProtectorKit: ScreenProtectorKit?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "screenshot_guard", binaryMessenger: registrar.messenger())
        let instance = ScreenshotGuardPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "enableSecureFlag":
            if let args = call.arguments as? [String: Any], let enable = args["enable"] as? Bool {
                toggleScreenshotProtection(enable)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected 'enable' boolean argument", details: nil))
            }
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func toggleScreenshotProtection(_ enable: Bool) {
        if enable {
            // Initialize screenProtectorKit only when needed
            if screenProtectorKit == nil {
                // Use the current window context to initialize ScreenProtectorKit
                screenProtectorKit = ScreenProtectorKit(window: UIApplication.shared.delegate?.window as? UIWindow)
            }
            screenProtectorKit?.configurePreventionScreenshot() // Configure prevention
            screenProtectorKit?.enabledPreventScreenshot() // Enable screenshot prevention
        } else {
            screenProtectorKit?.disablePreventScreenshot() // Disable screenshot protection
            screenProtectorKit = nil // Reset the screenProtectorKit instance
        }
    }
}

