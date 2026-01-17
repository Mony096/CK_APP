import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/main/screens/wrapper_screen.dart';
import 'package:provider/provider.dart';

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    // Initialize AwesomeNotifications
    await AwesomeNotifications().initialize(
      'resource://drawable/ic_launcher', // Ensure you have this icon or use null for default
      [
        NotificationChannel(
          channelKey: 'call_channel',
          channelName: 'Call Channel',
          channelDescription: 'Channel for incoming call notifications',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true, // Prevents dismissing without action
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
          criticalAlerts: true, // Requires special permission on iOS
        ),
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        )
      ],
    );

    // Request permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Set listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // If the payload contains 'call' type, show call notification
        // For now, assuming all notifications are call-style as per previous logic
      _showIncomingCallNotification(message);
      _startVibrationLoop();
    });
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> _onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> _onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> _onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
      Vibration.cancel();
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> _onActionReceivedMethod(ReceivedAction action) async {
    Vibration.cancel();
    if (action.buttonKeyPressed == 'ACCEPT') {
      final context = navigatorKey.currentContext;
       if (context != null) {
          Provider.of<AuthProvider>(context, listen: false).checkSession();
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WrapperScreen()),
            (route) => false,
          );
       } else {
         debugPrint("Context is null, cannot navigate");
       }
    } else if (action.buttonKeyPressed == 'IGNORE') {
      debugPrint("❌ User ignored the call");
    } else {
       // Default action (tap on body)
        final context = navigatorKey.currentContext;
       if (context != null) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WrapperScreen()),
            (route) => false,
          );
       }
    }
  }

  @pragma("vm:entry-point")
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    _showIncomingCallNotification(message);
    _startVibrationLoop();
  }

  static Future<void> _showIncomingCallNotification(RemoteMessage message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.messageId.hashCode, // Unique ID
        channelKey: 'call_channel',
        title: message.notification?.title ?? '🛠️ Technicon Service Alert',
        body: message.notification?.body ?? 'A new Service has been assigned to you. Open now!',
        // category: NotificationCategory.Call, // Important for iOS Call style
        fullScreenIntent: true, // Android 
        autoDismissible: true, // Keep it true so it dismisses on action
        locked: true, // Prevent swiping away easily
        wakeUpScreen: true,
        notificationLayout: NotificationLayout.Default, // Call layout is better if supported
        payload: {"type": "call"},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'ACCEPT',
          label: 'Open App',
          color: Colors.green,
          autoDismissible: true,
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'IGNORE',
          label: 'Ignore',
          color: Colors.red,
          autoDismissible: true,
          actionType: ActionType.SilentAction, 
        ),
      ],
    );
  }

  static void _startVibrationLoop() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(
        pattern: [500, 1000, 500, 1000, 500, 1000],
        repeat: 0, // No repeat, or use -1 for no repeat? 0 repeats from start. 
        // Logic in previous main.dart was repeat: 0. 
        // 0 means repeat indefinitely in some libs, or repeat from index 0. 
        // Vibration package doc: "index of the pattern array from which to repeat, or -1 for no repeat".
        // If we want it to ring for a while, we can repeat.
        // But let's stick to what was there or make it safe. 
      );
    }
  }
}
