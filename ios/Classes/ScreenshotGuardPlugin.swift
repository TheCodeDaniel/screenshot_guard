import Flutter
import UIKit

public class ScreenshotGuardPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "screenshot_guard", binaryMessenger: registrar.messenger())
        let instance = ScreenshotGuardPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    private var isEnabled = false
    private var overlayView: UIView?

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "enableSecureFlag":
            guard let args = call.arguments as? [String: Any],
                  let enable = args["enable"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing 'enable' argument", details: nil))
                return
            }
            toggleScreenshotPrevention(enable: enable)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func toggleScreenshotPrevention(enable: Bool) {
        if enable && !isEnabled {
            isEnabled = true
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didTakeScreenshot),
                name: UIApplication.userDidTakeScreenshotNotification,
                object: nil
            )
        } else if !enable && isEnabled {
            isEnabled = false
            NotificationCenter.default.removeObserver(
                self,
                name: UIApplication.userDidTakeScreenshotNotification,
                object: nil
            )
            removeOverlay()
        }
    }

    @objc private func didTakeScreenshot() {
        guard overlayView == nil else { return }

        // Create a black overlay to display momentarily
        guard let window = getKeyWindow() else { return }
        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = .black
        overlay.isUserInteractionEnabled = false
        overlay.alpha = 0
        window.addSubview(overlay)
        overlayView = overlay

        // Animate the black overlay to appear and disappear
        UIView.animate(withDuration: 0.3, animations: {
            overlay.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.5, animations: {
                overlay.alpha = 0
            }) { _ in
                self.removeOverlay()
            }
        }
    }

    private func removeOverlay() {
        overlayView?.removeFromSuperview()
        overlayView = nil
    }

    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            // Use connectedScenes for iOS 13 and above
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first { $0.isKeyWindow }
        } else {
            // Fallback to UIApplication.shared.windows for iOS 12 and below
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        }
    }
}
