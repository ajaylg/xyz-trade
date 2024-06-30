import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var dataReceiver: SimulateData?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
            let realTimeChannel = FlutterMethodChannel(name: "com.example.trading_app/realtime", binaryMessenger: controller.binaryMessenger)
            
            dataReceiver = SimulateData()
            
            realTimeChannel.setMethodCallHandler { [weak self] (call, result) in
                if call.method == "startReceivingData" {
                    self?.dataReceiver?.startReceivingData(with: controller)
                    result(nil)
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
        }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
