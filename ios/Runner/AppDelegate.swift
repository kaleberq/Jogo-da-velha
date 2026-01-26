import Flutter
import UIKit

private let kPending = "pending_deeplink_route"

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let url = launchOptions?[.url] as? URL { save(url) }
    let c = window?.rootViewController as! FlutterViewController
    FlutterMethodChannel(name: "br.com.kalebemisael.jogodavelha/deeplink", binaryMessenger: c.binaryMessenger)
      .setMethodCallHandler { call, result in
        if call.method == "getPendingRoute" {
          let r = UserDefaults.standard.string(forKey: kPending)
          UserDefaults.standard.removeObject(forKey: kPending)
          result(r)
        } else { result(FlutterMethodNotImplemented) }
      }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    save(url)
    return true
  }

  private func save(_ url: URL) {
    if url.scheme == "jogodavelha", url.host == "local-options" {
      UserDefaults.standard.set("/local-options", forKey: kPending)
    }
  }
}
