import 'package:bizd_tech_service/AppLifecycleObserver.dart';
import 'package:bizd_tech_service/core/app_initializer.dart';
import 'package:bizd_tech_service/core/config/environment.dart';
import 'package:bizd_tech_service/core/theme/app_theme.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/main/provider/download_provider.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_create_provider.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_list_provider.dart';
import 'package:bizd_tech_service/core/providers/helper_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/provider/service_provider.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/provider/update_status_provider.dart';
import 'package:bizd_tech_service/features/main/screens/wrapper_screen.dart';
import 'package:bizd_tech_service/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:vibration/vibration.dart';

/// 🔥 REQUIRED for background FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.onBackgroundMessage(message);
}

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();

  // // Initialize all app dependencies
  // await AppInitializer.init(environment: Environment.dev);

  // // Initialize Firebase
  // await Firebase.initializeApp();

  // // Set background handler
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // // Initialize Notification Service
  // final notificationService = NotificationService();
  // await notificationService.initialize();

  // // Reset any previous state
  // Vibration.cancel();
  // // Run the app with all providers
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();
  // Initialize all app dependencies
  await AppInitializer.init(environment: Environment.dev);
  // Background notifications
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 🔥 App lifecycle observer (CRITICAL FOR iOS)
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());

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
      ChangeNotifierProvider(create: (_) => DownloadProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          navigatorKey: NotificationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'BizD Tech Service',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light, // Can be changed to ThemeMode.system
          home: const WrapperScreen(),
        );
      },
    );
  }
}
