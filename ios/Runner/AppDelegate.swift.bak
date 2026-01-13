import Flutter
import UIKit
import FirebaseCore
import GoogleMaps
import flutter_background_service_ios
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
      GMSServices.provideAPIKey("AIzaSyBIQcpR-zBoAvJ7iVNe6AEUvQFrFS6Cuog")
      SwiftFlutterBackgroundServicePlugin.taskIdentifier = "com.example.ckservice.background"
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
// import Flutter
// import UIKit
// import FirebaseCore
// import GoogleMaps
// import flutter_background_service_ios // 1. Import the background service plugin

// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     FirebaseApp.configure()
//     GMSServices.provideAPIKey("AIzaSyBIQcpR-zBoAvJ7iVNe6AEUvQFrFS6Cuog")

//     // 2. Set the background task identifier.
//     // This must match the identifier you use in your Info.plist if you
//     // are using BGTaskScheduler.
//     SwiftFlutterBackgroundServicePlugin.taskIdentifier = "com.example.ckservice.background"

//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }