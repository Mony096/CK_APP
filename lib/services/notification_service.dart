import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/main/screens/wrapper_screen.dart';
import 'package:bizd_tech_service/services/ringtone_service.dart';
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

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool _isRinging = false;

  // ==========================
  // 🔥 INITIALIZATION
  // ==========================
  Future<void> initialize() async {
    await forceStop();

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'service_channel_v2',
          channelName: 'service Notifications',
          channelDescription: 'Incoming service request',
          importance: NotificationImportance.Max,
          playSound: true, // Enable native sound for lock screen
          enableVibration: true, // Enable native vibration
          criticalAlerts: true,
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
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

    // Set listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onActionReceivedMethod,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  // ==========================
  //  FCM HANDLERS
  // ==========================
  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    if (!Platform.isIOS) {
      await _showNotification(message);
    }
    await startRingtone();
  }

  static Future<void> _onMessageOpenedApp(RemoteMessage message) async {
    await forceStop();
    final context = navigatorKey.currentContext;
    if (context != null) {
      Provider.of<AuthProvider>(context, listen: false).checkSession();
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    // Always show custom Call UI on Android
    if (Platform.isAndroid || message.notification == null) {
      await _showNotification(message);
    }

    await startRingtone();
  }

  // ==========================
  // 🔔 NOTIFICATION UI
  // ==========================
  static Future<void> _showNotification(RemoteMessage message) async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'service_channel_v2',
        title: '🚚 New service Request',
        body: 'A new service has been assigned to you.',
        notificationLayout: NotificationLayout.Default,
        category: Platform.isIOS
            ? NotificationCategory.Call
            : NotificationCategory.Call,
        wakeUpScreen: true,
        fullScreenIntent: false, // Disable auto-open
        autoDismissible: false,
        locked: true,
        criticalAlert: true,
        payload: Map<String, String>.from(
          message.data.map((k, v) => MapEntry(k, v.toString())),
        ),
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

  // ==========================
  // 🧠 CALLBACKS
  // ==========================
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    await forceStop();
    if (action.buttonKeyPressed == 'ACCEPT') {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WrapperScreen()),
        (_) => false,
      );
    } else {
      await AwesomeNotifications().cancelAll();
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification notification) async {
    // Optional: ring again if UI is displayed
  }

  // ==========================
  // 🔊 RINGTONE CONTROL
  // ==========================
  static Future<void> startRingtone() async {
    // Prevent stuck state by ensuring any previous ringtone/vibration is stopped
    // This handles the case where the user ignored a previous notification
    await stopRingtone();
    _isRinging = true;
    // Start Ringtone (Works for both iOS and Android now)
    await RingtoneController.startRingtone();
    // Android specific vibration
    if (Platform.isAndroid) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(pattern: [500, 1000], repeat: 0);
      }
    }
  }

  static Future<void> stopRingtone() async {
    if (!_isRinging) return;
    _isRinging = false;
    if (Platform.isIOS) {
      await RingtoneController.stopRingtone();
    } else {
      Vibration.cancel();
    }
  }

  static Future<void> forceStop() async {
    _isRinging = false;
    Vibration.cancel();
    await RingtoneController.stopRingtone();
  }
}
