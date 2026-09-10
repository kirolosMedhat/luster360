import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let cameraChannel = FlutterMethodChannel(
      name: "com.luster.booth360/avfoundation",
      binaryMessenger: controller.binaryMessenger
    )

    cameraChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getHardwareCapabilities" {
        let discoverySession = AVCaptureDevice.DiscoverySession(
          deviceTypes: [.builtInWideAngleCamera],
          mediaType: .video,
          position: .back
        )
        var maxFps = 30
        if let device = discoverySession.devices.first {
          for format in device.formats {
            for range in format.videoSupportedFrameRateRanges {
              if Int(range.maxFrameRate) > maxFps {
                maxFps = Int(range.maxFrameRate)
              }
            }
          }
        }
        result(["maxFps": maxFps, "hasTorch": true])
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
