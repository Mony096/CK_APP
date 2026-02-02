// import Flutter
// import UIKit
// import FirebaseCore

// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     FirebaseApp.configure()
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }
import Flutter
import UIKit
import FirebaseCore
// import GoogleMaps
import flutter_background_service_ios
import AVFoundation
import AudioToolbox
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  private var audioPlayer: AVAudioPlayer?
  private var vibrationTimer: Timer?
  private var soundTimer: Timer?
  private var isRinging: Bool = false

//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {

//     FirebaseApp.configure()
//     // GMSServices.provideAPIKey("AIzaSyCJWN78P_Vj5L5zrBEqQ57oVxeQCVHsneY")
//     SwiftFlutterBackgroundServicePlugin.taskIdentifier = "com.bizd.ckservice.background"

//     // 🔥 Stop any leftover ringing
//     stopRingtone()

//     let controller = window?.rootViewController as! FlutterViewController
//     let ringtoneChannel = FlutterMethodChannel(
//       name: "com.example.ckservice/ringtone",
//       binaryMessenger: controller.binaryMessenger
//     )

//     ringtoneChannel.setMethodCallHandler { call, result in
//       switch call.method {
//       case "startRingtone":
//         self.startRingtone()
//         result(nil)
//       case "stopRingtone":
//         self.stopRingtone()
//         result(nil)
//       default:
//         result(FlutterMethodNotImplemented)
//       }
//     }

//     if #available(iOS 10.0, *) {
//       UNUserNotificationCenter.current().delegate = self
//     }

//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }

//   // 🔔 Notification arrives while app is FOREGROUND
//   override func userNotificationCenter(
//     _ center: UNUserNotificationCenter,
//     willPresent notification: UNNotification,
//     withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
//   ) {
//     if !isRinging {
//       startRingtone()
//     }
//     // Only play sound, let AwesomeNotifications show the Alert UI to avoid "2 messages"
//     completionHandler([.sound])
//   }

//   // 🔥 Notification TAPPED (MOST IMPORTANT FIX)
//   override func userNotificationCenter(
//     _ center: UNUserNotificationCenter,
//     didReceive response: UNNotificationResponse,
//     withCompletionHandler completionHandler: @escaping () -> Void
//   ) {
//     stopRingtone()
//     completionHandler()
//   }

//   // 🔔 Background notification
//   override func application(
//     _ application: UIApplication,
//     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
//     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
//   ) {
//     if !isRinging {
//       startRingtone()
//     }
//     completionHandler(.newData)
//   }

//   override func applicationDidBecomeActive(_ application: UIApplication) {
//     stopRingtone()
//     super.applicationDidBecomeActive(application)
//   }

//   // =====================
//   // 🔊 RINGTONE FUNCTIONS
//   // =====================

//   private func startRingtone() {
//     if isRinging { return }
//     isRinging = true

//     do {
//       try AVAudioSession.sharedInstance().setCategory(
//         .playback,
//         mode: .default,
//         options: [.duckOthers]
//       )
//       try AVAudioSession.sharedInstance().setActive(true)
//     } catch {
//       print("Audio session error")
//     }

//     if let path = Bundle.main.path(forResource: "ringtone", ofType: "mp3") {
//       let url = URL(fileURLWithPath: path)
//       audioPlayer = try? AVAudioPlayer(contentsOf: url)
//       audioPlayer?.numberOfLoops = -1
//       audioPlayer?.play()
//     } else {
//       let systemSoundID: SystemSoundID = 1005
//       AudioServicesPlaySystemSound(systemSoundID)
//       soundTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
//         AudioServicesPlaySystemSound(systemSoundID)
//       }
//     }

//     vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//       AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//     }
//   }

//   private func stopRingtone() {
//     if !isRinging { return }
//     isRinging = false

//     audioPlayer?.stop()
//     audioPlayer = nil
//     vibrationTimer?.invalidate()
//     vibrationTimer = nil
//     soundTimer?.invalidate()
//     soundTimer = nil

//     try? AVAudioSession.sharedInstance()
//       .setActive(false, options: .notifyOthersOnDeactivation)
//   }
// }
override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()
    // GMSServices.provideAPIKey("AIzaSyCJWN78P_Vj5L5zrBEqQ57oVxeQCVHsneY")
    SwiftFlutterBackgroundServicePlugin.taskIdentifier = "com.bizd.ckservice.background"

    // 🔥 Stop any leftover ringing
    stopRingtone()

    let controller = window?.rootViewController as! FlutterViewController
    let ringtoneChannel = FlutterMethodChannel(
      name: "com.example.ckservice/ringtone",
      binaryMessenger: controller.binaryMessenger
    )

    ringtoneChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "startRingtone":
        self.startRingtone()
        result(nil)
      case "stopRingtone":
        self.stopRingtone()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 🔔 Notification arrives while app is FOREGROUND
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if !isRinging {
      startRingtone()
    }
    // Only play sound, let AwesomeNotifications show the Alert UI to avoid "2 messages"
    completionHandler([.sound])
  }

  // 🔥 Notification TAPPED (MOST IMPORTANT FIX)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    stopRingtone()
    completionHandler()
  }

  // 🔔 Background notification
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    if !isRinging {
      startRingtone()
    }
    completionHandler(.newData)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    stopRingtone()
    super.applicationDidBecomeActive(application)
  }

  // =====================
  // 🔊 RINGTONE FUNCTIONS
  // =====================

  private func startRingtone() {
    if isRinging { return }
    isRinging = true

    do {
      try AVAudioSession.sharedInstance().setCategory(
        .playback,
        mode: .default,
        options: [.duckOthers]
      )
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Audio session error")
    }

    if let path = Bundle.main.path(forResource: "ringtone", ofType: "mp3") {
      let url = URL(fileURLWithPath: path)
      audioPlayer = try? AVAudioPlayer(contentsOf: url)
      audioPlayer?.numberOfLoops = -1
      audioPlayer?.play()
    } else {
      let systemSoundID: SystemSoundID = 1005
      AudioServicesPlaySystemSound(systemSoundID)
      soundTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
        AudioServicesPlaySystemSound(systemSoundID)
      }
    }

    vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
  }

  private func stopRingtone() {
    if !isRinging { return }
    isRinging = false

    audioPlayer?.stop()
    audioPlayer = nil
    vibrationTimer?.invalidate()
    vibrationTimer = nil
    soundTimer?.invalidate()
    soundTimer = nil

    try? AVAudioSession.sharedInstance()
      .setActive(false, options: .notifyOthersOnDeactivation)
  }
}