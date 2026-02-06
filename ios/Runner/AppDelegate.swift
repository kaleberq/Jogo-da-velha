import Flutter
import UIKit
import CoreImage

private let kPending = "pending_deeplink_route"
private let kPendingMaxRounds = "pending_deeplink_maxRounds"
private let kPendingTimeLimit = "pending_deeplink_timeLimit"

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        if let url = launchOptions?[.url] as? URL {
            save(url)
        }

        let c = window?.rootViewController as! FlutterViewController

        // ==============================
        // DEEPLINK CHANNEL (JÁ EXISTENTE)
        // ==============================
        FlutterMethodChannel(
            name: "br.com.kalebemisael.jogodavelha/deeplink",
            binaryMessenger: c.binaryMessenger
        ).setMethodCallHandler { call, result in
            if call.method == "getPendingRoute" {
                let r = UserDefaults.standard.string(forKey: kPending)
                let maxRounds = UserDefaults.standard.integer(forKey: kPendingMaxRounds)
                let timeLimit = UserDefaults.standard.integer(forKey: kPendingTimeLimit)

                UserDefaults.standard.removeObject(forKey: kPending)
                UserDefaults.standard.removeObject(forKey: kPendingMaxRounds)
                UserDefaults.standard.removeObject(forKey: kPendingTimeLimit)

                if let route = r {
                    result([
                        "route": route,
                        "maxRounds": maxRounds > 0 ? maxRounds : 5,
                        "timeLimitSeconds": timeLimit > 0 ? timeLimit : 10
                    ])
                } else {
                    result(nil)
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        // ==============================
        // QR CODE CHANNEL (NOVO)
        // ==============================
        FlutterMethodChannel(
            name: "br.com.kalebemisael.jogodavelha/qr",
            binaryMessenger: c.binaryMessenger
        ).setMethodCallHandler { [weak self] call, result in

            guard call.method == "generateQr" else {
                result(FlutterMethodNotImplemented)
                return
            }

            guard
                let args = call.arguments as? [String: Any],
                let data = args["data"] as? String
            else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "Missing data",
                    details: nil
                ))
                return
            }

            if let pngData = self?.generateQrPng(from: data) {
                result(FlutterStandardTypedData(bytes: pngData))
            } else {
                result(FlutterError(
                    code: "QR_FAILED",
                    message: "Could not generate QR",
                    details: nil
                ))
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        save(url)
        return true
    }

    // ==============================
    // DEEPLINK SAVE (JÁ EXISTENTE)
    // ==============================
    private func save(_ url: URL) {
        guard url.scheme == "jogodavelha" else { return }

        if url.host == "local-game" {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

            let maxRounds = Int(
                components?.queryItems?.first(where: { $0.name == "maxRounds" })?.value ?? "5"
            ) ?? 5

            let timeLimit = Int(
                components?.queryItems?.first(where: { $0.name == "timeLimitSeconds" })?.value ?? "10"
            ) ?? 10

            UserDefaults.standard.set("local-game", forKey: kPending)
            UserDefaults.standard.set(maxRounds, forKey: kPendingMaxRounds)
            UserDefaults.standard.set(timeLimit, forKey: kPendingTimeLimit)
        }
    }

    // ==============================
    // QR CODE NATIVE (NOVO)
    // ==============================
    private func generateQrPng(from string: String) -> Data? {
        guard
            let data = string.data(using: .utf8),
            let filter = CIFilter(name: "CIQRCodeGenerator")
        else { return nil }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")

        guard let ciImage = filter.outputImage else { return nil }

        let scaledImage = ciImage.transformed(
            by: CGAffineTransform(scaleX: 10, y: 10)
        )

        let context = CIContext()
        guard let cgImage = context.createCGImage(
            scaledImage,
            from: scaledImage.extent
        ) else { return nil }

        return UIImage(cgImage: cgImage).pngData()
    }
}
