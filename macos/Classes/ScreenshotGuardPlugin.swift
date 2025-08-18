import Cocoa
import FlutterMacOS

public class ScreenshotGuardPlugin: NSObject, FlutterPlugin, NSApplicationDelegate {


   private var isScreenshotPreventionActive = false
   private var blackOverlay: NSView?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "screenshot_guard", binaryMessenger: registrar.messenger)
    let instance = ScreenshotGuardPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
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
        
        if enable {
            // Block screenshots: hide window from screen capture
            window.sharingType = .none
            // window.level = NSWindow.Level(CGShieldingWindowLevel())
            window.level = NSWindow.Level(Int(CGShieldingWindowLevel()))
            // window.level = .screenSaver
        } else {
            // Restore defaults
            window.sharingType = .readOnly
            window.level = .normal
        }
  }


  // MARK: - App Lifecycle
    
  public func applicationWillResignActive(_ notification: Notification) {
      if isScreenshotPreventionActive {
          addBlackOverlay()
          // optionally relax capture here if you want
          NSApp.mainWindow?.sharingType = .readOnly
      }
  }


  public func applicationDidBecomeActive(_ notification: Notification) {
        if isScreenshotPreventionActive {
            removeBlackOverlay()
            // re-enable protection
            NSApp.mainWindow?.sharingType = .none
            // NSApp.mainWindow?.level = NSWindow.Level(CGShieldingWindowLevel())
            NSApp.mainWindow?.level = NSWindow.Level(Int(CGShieldingWindowLevel()))
            // NSApp.mainWindow?.level = .screenSaver
        }
  }


  // MARK: - Black Overlay (optional)
    
  private func addBlackOverlay() {
      guard let window = NSApp.mainWindow, blackOverlay == nil else { return }
      
      let overlay = NSView(frame: window.contentView?.bounds ?? .zero)
      overlay.wantsLayer = true
      overlay.layer?.backgroundColor = NSColor.black.cgColor
      overlay.autoresizingMask = [.width, .height]
      
      window.contentView?.addSubview(overlay)
      blackOverlay = overlay
  }
    
  private func removeBlackOverlay() {
      blackOverlay?.removeFromSuperview()
      blackOverlay = nil
  }


}
