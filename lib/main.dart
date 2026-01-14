import 'dart:io';
import 'dart:typed_data';

import 'package:bizd_tech_service/core/network/disable_ssl.dart';
import 'package:bizd_tech_service/features/auth/providers/auth_provider.dart';
import 'package:bizd_tech_service/features/service/providers/completed_service_provider.dart';
import 'package:bizd_tech_service/features/customer/providers/customer_list_provider.dart';
import 'package:bizd_tech_service/features/customer/providers/customer_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/providers/equipment_offline_provider.dart';
import 'package:bizd_tech_service/features/equipment/providers/equipment_create_provider.dart';
import 'package:bizd_tech_service/features/equipment/providers/equipment_list_provider.dart';
import 'package:bizd_tech_service/features/helper/providers/helper_provider.dart';
import 'package:bizd_tech_service/features/item/providers/item_list_provider.dart';
import 'package:bizd_tech_service/features/item/providers/item_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/providers/service_list_provider.dart';
import 'package:bizd_tech_service/features/service/providers/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/providers/service_provider.dart';
import 'package:bizd_tech_service/features/site/providers/site_list_provider.dart';
import 'package:bizd_tech_service/features/site/providers/site_list_provider_offline.dart';
import 'package:bizd_tech_service/features/status/providers/update_status_provider.dart';
import 'package:bizd_tech_service/app/wrapper_screen.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
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
    print("âŒ User ignored the call");
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
  var dir = await getApplicationDocumentsDirectory();
  print(dir);
  await Hive.initFlutter();
  await Hive.openBox('service_lists');
  await Hive.openBox('equipment_box');
  await Hive.openBox('customer_lists');
  await Hive.openBox('item_lists');
  await Hive.openBox('site_lists');
  await FirebaseMessaging.instance.requestPermission();

  // // ðŸ”¹ Get token
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
//   // ðŸ”¹ Delete existing token (forces a new token)
//   await FirebaseMessaging.instance.deleteToken();
//   print("ðŸ—‘ Old token deleted");

//   // ðŸ”¹ Get a new token
//   String? token = await FirebaseMessaging.instance.getToken();
//   print("âœ… New FCM Token: $token");

//   // ðŸ”¹ Listen for token refresh (optional)
//   FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//     print("ðŸ”„ Refreshed Token: $newToken");
//     // send newToken to your backend if needed
//   });
// }

void _showIncomingCallNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'call_channel_1',
      title: 'ðŸ› ï¸ Technicon Service Alert',
      body: 'A new Service has been assigned to you. Open now!',
      fullScreenIntent: false, // âŒ Turn off full screen intent
      autoDismissible: true, // âœ… Allow dismissing
      locked: true, // âœ… Let the user swipe it away
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

/// ðŸ” Optional: Start vibration manually for longer duration
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
