// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:vibration/vibration.dart';
// import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
// import 'package:bizd_tech_service/features/main/screens/wrapper_screen.dart';
// import 'package:provider/provider.dart';

// class NotificationService {
//   static final GlobalKey<NavigatorState> navigatorKey =
//       GlobalKey<NavigatorState>();

//   static Future<void> initialize() async {
//     // Initialize AwesomeNotifications
//     await AwesomeNotifications().initialize(
//       'resource://drawable/ic_launcher', // Ensure you have this icon or use null for default
//       [
//         NotificationChannel(
//           channelKey: 'call_channel',
//           channelName: 'Call Channel',
//           channelDescription: 'Channel for incoming call notifications',
//           defaultColor: const Color(0xFF9D50DD),
//           ledColor: Colors.white,
//           importance: NotificationImportance.Max,
//           channelShowBadge: true,
//           locked: true, // Prevents dismissing without action
//           defaultRingtoneType: DefaultRingtoneType.Ringtone,
//           criticalAlerts: true, // Requires special permission on iOS
//         ),
//         NotificationChannel(
//           channelKey: 'basic_channel',
//           channelName: 'Basic Notifications',
//           channelDescription: 'Notification channel for basic tests',
//           defaultColor: const Color(0xFF9D50DD),
//           ledColor: Colors.white,
//           importance: NotificationImportance.High,
//         )
//       ],
//     );

//     // Request permissions
//     await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
//       if (!isAllowed) {
//         AwesomeNotifications().requestPermissionToSendNotifications();
//       }
//     });

//     // Set listeners
//     AwesomeNotifications().setListeners(
//       onActionReceivedMethod: _onActionReceivedMethod,
//       onNotificationCreatedMethod: _onNotificationCreatedMethod,
//       onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
//       onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
//     );

//     // Background handler
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     // Foreground handler
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         // If the payload contains 'call' type, show call notification
//         // For now, assuming all notifications are call-style as per previous logic
//       _showIncomingCallNotification(message);
//       _startVibrationLoop();
//     });
//   }

//   /// Use this method to detect when a new notification or a schedule is created
//   @pragma("vm:entry-point")
//   static Future<void> _onNotificationCreatedMethod(
//       ReceivedNotification receivedNotification) async {
//     // Your code goes here
//   }

//   /// Use this method to detect every time that a new notification is displayed
//   @pragma("vm:entry-point")
//   static Future<void> _onNotificationDisplayedMethod(
//       ReceivedNotification receivedNotification) async {
//     // Your code goes here
//   }

//   /// Use this method to detect if the user dismissed a notification
//   @pragma("vm:entry-point")
//   static Future<void> _onDismissActionReceivedMethod(
//       ReceivedAction receivedAction) async {
//       Vibration.cancel();
//   }

//   /// Use this method to detect when the user taps on a notification or action button
//   @pragma("vm:entry-point")
//   static Future<void> _onActionReceivedMethod(ReceivedAction action) async {
//     Vibration.cancel();
//     if (action.buttonKeyPressed == 'ACCEPT') {
//       final context = navigatorKey.currentContext;
//        if (context != null) {
//           Provider.of<AuthProvider>(context, listen: false).checkSession();
//           navigatorKey.currentState?.pushAndRemoveUntil(
//             MaterialPageRoute(builder: (_) => const WrapperScreen()),
//             (route) => false,
//           );
//        } else {
//          debugPrint("Context is null, cannot navigate");
//        }
//     } else if (action.buttonKeyPressed == 'IGNORE') {
//       debugPrint("❌ User ignored the call");
//     } else {
//        // Default action (tap on body)
//         final context = navigatorKey.currentContext;
//        if (context != null) {
//           navigatorKey.currentState?.pushAndRemoveUntil(
//             MaterialPageRoute(builder: (_) => const WrapperScreen()),
//             (route) => false,
//           );
//        }
//     }
//   }

//   @pragma("vm:entry-point")
//   static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//     await Firebase.initializeApp();
//     _showIncomingCallNotification(message);
//     _startVibrationLoop();
//   }

//   static Future<void> _showIncomingCallNotification(RemoteMessage message) async {
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: message.messageId.hashCode, // Unique ID
//         channelKey: 'call_channel',
//         title: message.notification?.title ?? '🛠️ Technicon Service Alert',
//         body: message.notification?.body ?? 'A new Service has been assigned to you. Open now!',
//         // category: NotificationCategory.Call, // Important for iOS Call style
//         fullScreenIntent: true, // Android
//         autoDismissible: true, // Keep it true so it dismisses on action
//         locked: true, // Prevent swiping away easily
//         wakeUpScreen: true,
//         notificationLayout: NotificationLayout.Default, // Call layout is better if supported
//         payload: {"type": "call"},
//       ),
//       actionButtons: [
//         NotificationActionButton(
//           key: 'ACCEPT',
//           label: 'Open App',
//           color: Colors.green,
//           autoDismissible: true,
//           actionType: ActionType.Default,
//         ),
//         NotificationActionButton(
//           key: 'IGNORE',
//           label: 'Ignore',
//           color: Colors.red,
//           autoDismissible: true,
//           actionType: ActionType.SilentAction,
//         ),
//       ],
//     );
//   }

//   static void _startVibrationLoop() async {
//     if (await Vibration.hasVibrator()) {
//       Vibration.vibrate(
//         pattern: [500, 1000, 500, 1000, 500, 1000],
//         repeat: 0, // No repeat, or use -1 for no repeat? 0 repeats from start.
//         // Logic in previous main.dart was repeat: 0.
//         // 0 means repeat indefinitely in some libs, or repeat from index 0.
//         // Vibration package doc: "index of the pattern array from which to repeat, or -1 for no repeat".
//         // If we want it to ring for a while, we can repeat.
//         // But let's stick to what was there or make it safe.
//       );
//     }
//   }
// }
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/main/screens/wrapper_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:provider/provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final AwesomeNotifications _awesomeNotifications = AwesomeNotifications();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool _isVibrating = false;

  Future<void> initialize() async {
    // 1. Initialize Awesome Notifications
    await _awesomeNotifications.initialize(
      null, // default icon
      [
        NotificationChannel(
          channelKey: 'service_channel',
          channelName: 'Service Notifications',
          channelDescription: 'Notifications for new service requests',
          importance: NotificationImportance.Max,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Download Progress',
          channelDescription: 'Notifications for download progress',
          importance: NotificationImportance.Low,
          playSound: false,
          enableVibration: false,
        ),
      ],
      debug: false,
    );

    // 2. Request Permissions
    await _requestPermissions();

    // 3. Set Listeners for Awesome Notifications
    _awesomeNotifications.setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    // 4. FCM Foreground Listener
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 6. FCM Click Listener (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 7. Get FCM Token
    try {
      String? token = await _fcm.getToken();
      debugPrint("FCM Token: $token");
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      // FCM Permissions
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true, // Explicitly request critical alerts for FCM
      );
    }

    // Awesome Notifications Permissions
    bool isAllowed = await _awesomeNotifications.isNotificationAllowed();
    if (!isAllowed) {
      await _awesomeNotifications.requestPermissionToSendNotifications(
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
          NotificationPermission.CriticalAlert,
          NotificationPermission
              .FullScreenIntent, // 👈 Required for lock screen
        ],
      );
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint("Received Foreground Message: ${message.notification?.title}");
    await _showNotification(message);
    await startVibration();
  }

  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint("FCM Message opened app: ${message.data}");
    // Force refresh app state
    final context = navigatorKey.currentContext;
    if (context != null) {
      Provider.of<AuthProvider>(context, listen: false).checkSession();
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    // Ensure Firebase is initialized in background isolate
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    debugPrint("Handling background message: ${message.messageId}");
    await _showNotification(message);
    await startVibration();
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);
    String title = message.notification?.title ?? '🛠️ Technicon Service Alert';
    String body = message.notification?.body ??
        'A new Service has been assigned to you. Open now!';

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'service_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Call, // Triggers Call behavior on iOS
        wakeUpScreen: true,
        fullScreenIntent: false,
        autoDismissible: false,
        locked: true,
        criticalAlert: true,
        payload: Map<String, String>.from(
            message.data.map((key, value) => MapEntry(key, value.toString()))),
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'ACCEPT',
          label: 'Open App',
          actionType: ActionType.Default,
          color: Colors.green,
        ),
        NotificationActionButton(
          key: 'REJECT',
          label: 'Ignore',
          actionType: ActionType.DismissAction,
          color: Colors.red,
        ),
      ],
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    await stopVibration();

    if (action.buttonKeyPressed == 'ACCEPT') {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Refresh session to show ViewNotification screen
        await Provider.of<AuthProvider>(context, listen: false).checkSession();

        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WrapperScreen()),
          (route) => false,
        );
      }
    } else {
      await AwesomeNotifications().cancelAll();
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Optional: start vibration when notification is actually displayed
    await startVibration();
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    await stopVibration();
  }

  static Future<void> startVibration() async {
    if (_isVibrating) return;

    if (await Vibration.hasVibrator()) {
      _isVibrating = true;
      Vibration.vibrate(
        pattern: [500, 1000, 500, 1000],
        repeat: -1, // 👈 Loop until user answers
      );
    }
  }

  static Future<void> stopVibration() async {
    _isVibrating = false;
    Vibration.cancel();
  }
}
