import Cocoa
import FlutterMacOS

public class ScreenshotGuardPlugin: NSObject, FlutterPlugin, NSApplicationDelegate, NSWindowDelegate {

    private var isScreenshotPreventionActive = false
    private var blackOverlay: NSView?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "screenshot_guard", binaryMessenger: registrar.messenger)
        let instance = ScreenshotGuardPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        // No need to set the delegate here. It's done inside the handle method
        // which is a more reliable entry point after the window is created.
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // The type for 'call' must be FlutterMethodCall, not FlutterMethodChannel.
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
            result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func toggleScreenshotPrevention(_ enable: Bool) {
        isScreenshotPreventionActive = enable
        guard let window = NSApp.mainWindow else {
            print("Failed to retrieve the main window")
            return
        }

        // Set the delegate here. This is the most reliable place as it's
        // called from the Flutter side after the app and its window are ready.
        window.delegate = self
        
        if enable {
            // Set the sharingType to none to prevent all forms of screen capture.
            window.sharingType = .none
        } else {
            // Restore the default sharingType.
            window.sharingType = .readOnly
        }
    }

    // MARK: - App & Window Delegate Methods

    // This method handles when the app loses focus (e.g., user clicks away).
    public func applicationWillResignActive(_ notification: Notification) {
        if isScreenshotPreventionActive {
            addBlackOverlay()
        }
    }

    // This method handles when the app regains focus.
    public func applicationDidBecomeActive(_ notification: Notification) {
        if isScreenshotPreventionActive {
            removeBlackOverlay()
        }
    }
    
    // This method handles when the window is about to be minimized.
    // It must be marked @objc to be called by the Objective-C runtime.
    @objc public func windowWillMiniaturize(_ notification: Notification) {
        if isScreenshotPreventionActive {
            addBlackOverlay()
        }
    }
    
    // This method handles when the window is restored from a minimized state.
    // It must also be marked @objc.
    @objc public func windowDidDeminiaturize(_ notification: Notification) {
        if isScreenshotPreventionActive {
            removeBlackOverlay()
        }
    }

    // MARK: - Black Overlay

    private func addBlackOverlay() {
        guard let window = NSApp.mainWindow, blackOverlay == nil else { return }
        
        // Ensure we add the overlay to the window's content view.
        if let contentView = window.contentView {
            let overlay = NSView(frame: contentView.bounds)
            overlay.wantsLayer = true
            overlay.layer?.backgroundColor = NSColor.black.cgColor
            overlay.autoresizingMask = [.width, .height]
            contentView.addSubview(overlay)
            blackOverlay = overlay
        }
    }
    
    private func removeBlackOverlay() {
        blackOverlay?.removeFromSuperview()
        blackOverlay = nil
    }
}