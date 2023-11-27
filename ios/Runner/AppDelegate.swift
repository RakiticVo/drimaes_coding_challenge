import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

        let channel = FlutterMethodChannel(name: "demo", binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "getVersionInfo" {
                self?.getVersionInfo(result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func getVersionInfo(result: @escaping FlutterResult) {
        if let info = Bundle.main.infoDictionary,
            let versionCode = info["CFBundleVersion"] as? String,
            let versionName = info["CFBundleShortVersionString"] as? String {
            result(["versionCode": versionCode, "versionName": versionName])
        } else {
            result(FlutterError(code: "VERSION_ERROR", message: "Error getting version info", details: nil))
        }
    }
}
