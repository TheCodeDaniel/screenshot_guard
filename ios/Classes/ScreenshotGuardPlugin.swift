import Flutter
import UIKit
import ScreenProtectorKit

public class ScreenshotGuardPlugin: NSObject, FlutterPlugin {

    private var screenProtectorKit: ScreenProtectorKit?
    private var isScreenshotPreventionActive = false // Track the current state
    private var blackOverlay: UIView? // Black overlay for recent apps protection

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "screenshot_guard", binaryMessenger: registrar.messenger())
        let instance = ScreenshotGuardPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance) // Register lifecycle events
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "enableSecureFlag":
            guard let args = call.arguments as? [String: Any],
                  let enable = args["enable"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected 'enable' boolean argument", details: nil))
                return
            }
            toggleScreenshotPrevention(enable)
            result(nil)
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)    
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func toggleScreenshotPrevention(_ enable: Bool) {
        isScreenshotPreventionActive = enable
        if enable {
            // Initialize and enable screenshot prevention
            if screenProtectorKit == nil {
                guard let window = UIApplication.shared.windows.first else {
                    print("Failed to retrieve the main window")
                    return
                }
                screenProtectorKit = ScreenProtectorKit(window: window)
                screenProtectorKit?.configurePreventionScreenshot()
            }
            screenProtectorKit?.enabledPreventScreenshot()
        } else {
            // Disable screenshot prevention
            screenProtectorKit?.disablePreventScreenshot()
        }
    }

    // MARK: - App Lifecycle Management

    public func applicationWillResignActive(_ application: UIApplication) {
        // App is about to move to the background
        if isScreenshotPreventionActive {
            addBlackOverlay() // Protect app content in "Recent Apps"
            screenProtectorKit?.disablePreventScreenshot() // Avoid black screen
        }
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        // App has moved to the foreground
        if isScreenshotPreventionActive {
            removeBlackOverlay() // Restore visibility
            screenProtectorKit?.enabledPreventScreenshot() // Re-enable prevention
        }
    }

    // MARK: - Black Overlay for "Recent Apps"

    private func addBlackOverlay() {
        guard let window = UIApplication.shared.windows.first else { return }
        if blackOverlay == nil {
            blackOverlay = UIView(frame: window.bounds)
            blackOverlay?.backgroundColor = UIColor.black
            blackOverlay?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        if let blackOverlay = blackOverlay, blackOverlay.superview == nil {
            window.addSubview(blackOverlay)
        }
    }

    private func removeBlackOverlay() {
        blackOverlay?.removeFromSuperview()
    }
}
