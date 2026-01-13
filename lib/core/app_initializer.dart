import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bizd_tech_service/core/disble_ssl.dart';
import 'package:bizd_tech_service/core/config/environment.dart';

/// Centralized app initialization
/// 
/// Handles all setup tasks that need to run before the app starts:
/// - Firebase
/// - Hive (local database)
/// - Notifications
/// - SSL configuration
class AppInitializer {
  /// Initialize all app dependencies
  static Future<void> init({Environment environment = Environment.dev}) async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set environment
    AppConfig.setEnvironment(environment);
    
    // Initialize Firebase
    await Firebase.initializeApp();
    
    // SSL configuration (only in debug mode)
    if (kDebugMode && AppConfig.shouldDisableSSL) {
      HttpOverrides.global = DisableSSL();
    }
    
    // Initialize local storage
    await _initHive();
    
    // Initialize notifications
    await _initNotifications();
    
    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission();
  }
  
  /// Initialize Hive local database
  static Future<void> _initHive() async {
    final dir = await getApplicationDocumentsDirectory();
    debugPrint('Hive Directory: $dir');
    
    await Hive.initFlutter();
    
    // Open required boxes
    await Future.wait([
      Hive.openBox('service_lists'),
      Hive.openBox('equipment_box'),
      Hive.openBox('customer_lists'),
      Hive.openBox('item_lists'),
      Hive.openBox('site_lists'),
    ]);
  }
  
  /// Initialize Awesome Notifications
  static Future<void> _initNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'call_channel',
          channelName: 'Incoming Call',
          channelDescription: 'Call notifications',
          importance: NotificationImportance.Max,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000, 500, 1000]),
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
          locked: true,
          criticalAlerts: true,
        ),
      ],
    );
  }
  
  /// Clear all local data (for logout)
  static Future<void> clearAllData() async {
    await Hive.box('service_lists').clear();
    await Hive.box('equipment_box').clear();
    await Hive.box('customer_lists').clear();
    await Hive.box('item_lists').clear();
    await Hive.box('site_lists').clear();
  }
}
