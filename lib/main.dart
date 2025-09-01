import 'dart:io';

import 'package:bizd_tech_service/core/disble_ssl.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/provider/customer_list_provider.dart';
import 'package:bizd_tech_service/provider/equipment_create_provider.dart';
import 'package:bizd_tech_service/provider/equipment_list_provider.dart';
import 'package:bizd_tech_service/provider/service_list_provider.dart';
import 'package:bizd_tech_service/provider/service_provider.dart';
import 'package:bizd_tech_service/provider/update_status_provider.dart';
import 'package:bizd_tech_service/wrapper_screen.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// @pragma("vm:entry-point")
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   _showIncomingCallNotification();
//   _startVibrationLoop(); // Optional: long vibration when background
// }

// @pragma('vm:entry-point')
// Future<void> _onActionReceivedMethod(ReceivedAction action) async {
//   if (action.buttonKeyPressed == 'ACCEPT') {
//     final context = navigatorKey.currentContext!;
//     Provider.of<AuthProvider>(context, listen: false).checkSession();

//     navigatorKey.currentState?.pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => const WrapperScreen()),
//       (route) => false,
//     );
//     // Stop vibration when accepted
//     Vibration.cancel();
//   } else {
//     print("❌ User ignored the call");
//     Vibration.cancel();
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = DisableSSL();

  // await Firebase.initializeApp();
  // await LocationProvider.initializeService();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // AwesomeNotifications().initialize(
  //   null,
  //   [
  //     NotificationChannel(
  //       channelKey: 'call_channel',
  //       channelName: 'Incoming Call',
  //       channelDescription: 'Call notifications',
  //       importance: NotificationImportance.Max,
  //       playSound: true,
  //       enableVibration: true,
  //       vibrationPattern:
  //           Int64List.fromList([0, 1000, 500, 1000, 500, 1000, 500, 1000]),
  //       defaultRingtoneType: DefaultRingtoneType.Ringtone,
  //       locked: true,
  //       criticalAlerts: true,
  //     ),
  //   ],
  // );

  // AwesomeNotifications().setListeners(
  //   onActionReceivedMethod: _onActionReceivedMethod,
  // );

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   _showIncomingCallNotification();
  //   _startVibrationLoop(); // Optional: long vibration when foreground
  // });
  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //   final context = navigatorKey.currentContext!;
  //   Provider.of<AuthProvider>(context, listen: false).checkSession();
  //   print("plokkkkkkkkkkkkkkkkkkkkkkk");
  // });
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

      // ChangeNotifierProvider(create: (_) => LocationProvider()),
    ],
    child: const MyApp(),
  ));
}

// void _showIncomingCallNotification() async {
//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: 1,
//       channelKey: 'call_channel',
//       title: '🚚 Urgent Delivery Request',
//       body: 'A new delivery has been assigned to you. Respond now!',
//       fullScreenIntent: false, // ❌ Turn off full screen intent
//       autoDismissible: true, // ✅ Allow dismissing
//       locked: true, // ✅ Let the user swipe it away
//       notificationLayout: NotificationLayout.Default,
//     ),
//     actionButtons: [
//       NotificationActionButton(
//         key: 'ACCEPT',
//         label: 'Open App',
//         actionType: ActionType.Default,
//       ),
//       NotificationActionButton(
//         key: 'IGNORE',
//         label: 'Ignore',
//         actionType: ActionType.SilentAction,
//       ),
//     ],
//   );
// }

// /// 🔁 Optional: Start vibration manually for longer duration
// void _startVibrationLoop() async {
//   if (await Vibration.hasVibrator() ?? false) {
//     Vibration.vibrate(
//       pattern: [500, 1000, 500, 1000, 500, 1000],
//       repeat: 0,
//     );
//   }
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // ✅ App returned to foreground
//       print("📱 App resumed");
//       Provider.of<AuthProvider>(context, listen: false).checkSession();
//     } else if (state == AppLifecycleState.paused) {
//       // ✅ App went to background
//       print("📴 App paused");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       debugShowCheckedModeBanner: false,
//       title: 'Demo',
//       home: const WrapperScreen(),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Demo',
      home: const WrapperScreen(),
    );
  }
}
