import 'dart:typed_data';

import 'package:bizd_tech_service/core/app_initializer.dart';
import 'package:bizd_tech_service/core/config/environment.dart';
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
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showIncomingCallNotification();
  _startVibrationLoop();
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
    Vibration.cancel();
  } else {
    debugPrint("❌ User ignored the call");
    Vibration.cancel();
  }
}

void main() async {
  // Initialize all app dependencies
  await AppInitializer.init(environment: Environment.dev);
  
  // Set up Firebase messaging handlers
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: _onActionReceivedMethod,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showIncomingCallNotification();
    _startVibrationLoop();
  });

  // Run the app with all providers
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
      ChangeNotifierProvider(create: (_) => HelperProvider()),
      ChangeNotifierProvider(create: (_) => ItemListProvider()),
      ChangeNotifierProvider(create: (_) => SiteListProvider()),
      ChangeNotifierProvider(create: (_) => ServiceListProviderOffline()),
      ChangeNotifierProvider(create: (_) => CustomerListProviderOffline()),
      ChangeNotifierProvider(create: (_) => ItemListProviderOffline()),
      ChangeNotifierProvider(create: (_) => EquipmentOfflineProvider()),
      ChangeNotifierProvider(create: (_) => SiteListProviderOffline()),
    ],
    child: const MyApp(),
  ));
}

void _showIncomingCallNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'call_channel',
      title: '🛠️ Technicon Service Alert',
      body: 'A new Service has been assigned to you. Open now!',
      fullScreenIntent: false,
      autoDismissible: true,
      locked: true,
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

/// Start vibration manually for longer duration
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
      title: 'BizD Tech Service',
      home: const WrapperScreen(),
    );
  }
}
