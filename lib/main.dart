import 'dart:io';
import 'dart:typed_data';

import 'package:bizd_tech_service/core/disble_ssl.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/provider/customer_list_provider.dart';
import 'package:bizd_tech_service/provider/customer_list_provider_offline.dart';
import 'package:bizd_tech_service/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/provider/equipment_create_provider.dart';
import 'package:bizd_tech_service/provider/equipment_list_provider.dart';
import 'package:bizd_tech_service/provider/helper_provider.dart';
import 'package:bizd_tech_service/provider/item_list_provider.dart';
import 'package:bizd_tech_service/provider/item_list_provider_offline.dart';
import 'package:bizd_tech_service/provider/service_list_provider.dart';
import 'package:bizd_tech_service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/provider/service_provider.dart';
import 'package:bizd_tech_service/provider/site_list_provider.dart';
import 'package:bizd_tech_service/provider/site_list_provider_offline.dart';
import 'package:bizd_tech_service/provider/update_status_provider.dart';
import 'package:bizd_tech_service/wrapper_screen.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showIncomingCallNotification();
  _startVibrationLoop(); // Optional: long vibration when background
}

@pragma('vm:entry-point')
Future<void> _onActionReceivedMethod(ReceivedAction action) async {
  if (action.buttonKeyPressed == 'ACCEPT') {
    final context = navigatorKey.currentContext!;
    Provider.of<AuthProvider>(context, listen: false).checkSession();

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WrapperScreen()),
      (route) => false,
    );
    // Stop vibration when accepted
    Vibration.cancel();
  } else {
    print("❌ User ignored the call");
    Vibration.cancel();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  HttpOverrides.global = DisableSSL();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'call_channel',
        channelName: 'Incoming Call',
        channelDescription: 'Call notifications',
        importance: NotificationImportance.Max,
        playSound: true,
        enableVibration: true,
        vibrationPattern:
            Int64List.fromList([0, 1000, 500, 1000, 500, 1000, 500, 1000]),
        defaultRingtoneType: DefaultRingtoneType.Ringtone,
        locked: true,
        criticalAlerts: true,
      ),
    ],
  );

  AwesomeNotifications().setListeners(
    onActionReceivedMethod: _onActionReceivedMethod,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showIncomingCallNotification();
    _startVibrationLoop(); // Optional: long vibration when foreground
  });
  await Hive.initFlutter();
  await Hive.openBox('service_lists');
  await Hive.openBox('equipment_box');
  await Hive.openBox('customer_lists');
  await Hive.openBox('item_lists');
  await Hive.openBox('site_lists');
  await FirebaseMessaging.instance.requestPermission();

  // // 🔹 Get token
  // await initFCM();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => DeliveryNoteProvider()),
      ChangeNotifierProvider(create: (_) => CustomerListProvider()),
      ChangeNotifierProvider(create: (_) => UpdateStatusProvider()),
      ChangeNotifierProvider(create: (_) => EquipmentListProvider()),
      ChangeNotifierProvider(create: (_) => EquipmentCreateProvider()),
      ChangeNotifierProvider(create: (_) => ServiceListProvider()),
      ChangeNotifierProvider(create: (_) => CompletedServiceProvider()),
      ChangeNotifierProvider(create: (_) => HelperProvider()), // <-- Added
      ChangeNotifierProvider(
          create: (_) =>
              ItemListProvider()), // <-- AddedServiceListProviderOffline
      ChangeNotifierProvider(create: (_) => SiteListProvider()), // <-- Added
      ChangeNotifierProvider(
          create: (_) => ServiceListProviderOffline()), // <-- Added
      // ChangeNotifierProvider(create: (_) => ServiceTicketListProviderOffline()), // <-- Added
      ChangeNotifierProvider(create: (_) => CustomerListProviderOffline()),
      ChangeNotifierProvider(create: (_) => ItemListProviderOffline()),
      ChangeNotifierProvider(create: (_) => EquipmentOfflineProvider()),
      ChangeNotifierProvider(create: (_) => SiteListProviderOffline()),

      // ChangeNotifierProvider(create: (_) => LocationProvider()),
    ],
    child: const MyApp(),
  ));
}

// Future<void> initFCM() async {
//   // 🔹 Delete existing token (forces a new token)
//   await FirebaseMessaging.instance.deleteToken();
//   print("🗑 Old token deleted");

//   // 🔹 Get a new token
//   String? token = await FirebaseMessaging.instance.getToken();
//   print("✅ New FCM Token: $token");

//   // 🔹 Listen for token refresh (optional)
//   FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//     print("🔄 Refreshed Token: $newToken");
//     // send newToken to your backend if needed
//   });
// }

void _showIncomingCallNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'call_channel_1',
      title: '🛠️ Technicon Service Alert',
      body: 'A new Service has been assigned to you. Open now!',
      fullScreenIntent: false, // ❌ Turn off full screen intent
      autoDismissible: true, // ✅ Allow dismissing
      locked: true, // ✅ Let the user swipe it away
      notificationLayout: NotificationLayout.Default,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'ACCEPT',
        label: 'Open App',
        actionType: ActionType.Default,
      ),
      NotificationActionButton(
        key: 'IGNORE',
        label: 'Ignore',
        actionType: ActionType.SilentAction,
      ),
    ],
  );
}

/// 🔁 Optional: Start vibration manually for longer duration
void _startVibrationLoop() async {
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(
      pattern: [500, 1000, 500, 1000, 500, 1000],
      repeat: 0,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Demo',
      home: const WrapperScreen(),
      // home: DownloadScreen(),
    );
  }
}
