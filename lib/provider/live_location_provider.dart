// lib/providers/location_provider.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

// Your custom dependencies. Ensure their paths are correct.
import '../utilities/dio_client.dart';
import '../utilities/storage/locale_storage.dart';

// Your custom Dio client instance.
// Ensure it's initialized in a way that's safe for a background isolate.
final DioClient dio = DioClient();

// =======================================================================
// BACKGROUND SERVICE ENTRY POINT
// This code is executed in a separate isolate when the service starts.
// =======================================================================
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // We need to re-initialize DioClient here because it's a new isolate.
  if (service is AndroidServiceInstance) {
    // service.on('setAsForeground').listen((event) {
    //   service.setAsForegroundService();
    // });
    // service.on('setAsBackground').listen((event) {
    //   service.setAsBackgroundService();
    // });
    // ✅ Call immediately to prevent crash
    service.setAsForegroundService();

    // Optional: still keep event listeners if needed
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  // Listen for the stop command from the main app
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Get the ID that was passed from the UI
  // You might want to get other data here as well, like a token
  dynamic id = await LocalStorageManger.getString('UserId');
  if (id == null) {
    print('No delivery ID found. Stopping service.');
    service.stopSelf();
    return;
  }

  DateTime? lastUpdateTime;

  final locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 1,
    // Add this to make sure Android knows this is a foreground service
    // that needs to run for a long time.
    foregroundNotificationConfig: const ForegroundNotificationConfig(
      notificationTitle: "Live Delivery Tracking",
      notificationText: "Your delivery is being tracked.",
      // You can also provide an icon if you have one
      // You may need to create a resource for this in your Android project.
      // notificationIcon: 'ic_stat_icon',
    ),
  );

  // Start listening to the position stream
  // Use a StreamSubscription to keep a reference.
  final positionSubscription =
      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((position) async {
    final now = DateTime.now();

    // Throttle the SAP update to every 10 seconds
    if (lastUpdateTime == null ||
        now.difference(lastUpdateTime!).inSeconds >= 4) {
      lastUpdateTime = now;

      // Call your SAP update functions
      // await _insertLocationToSAPLive(position, id);
      await _alertToLatLng(position.latitude, position.longitude);
    } else {
      print("📌 Skipped update - too soon");
    }
  });

  // Make sure to cancel the subscription when the service stops.
  service.on('stopService').listen((event) {
    positionSubscription.cancel();
    service.stopSelf();
  });
}

// Your existing _insertLocationToSAPLive logic
// Future<void> _insertLocationToSAPLive(Position position, dynamic id) async {
//   final now = DateTime.now();
//   final data = {
//     'U_Lat': position.latitude,
//     'U_Long': position.longitude,
//     'U_Time': DateFormat('HH:mm:ss').format(now),
//     'U_Date': DateFormat('yyyy-MM-dd').format(now),
//   };
//   try {
//     final updatedList = [data];
//     final payload = {
//       "LK_DELIVERYROUTESCollection": updatedList,
//     };
//     print("📡 Sending to SAP: ${jsonEncode(payload)}");
//     final res = await dio.get(
//         "/LK_DELIVERYSTATUS?\$filter=U_lk_DeliveryEntry eq $id &\$select=DocEntry");
//     if (res.statusCode == 200 && res.data["value"]?.isNotEmpty == true) {
//       final Map<String, dynamic> data = res.data["value"][0];
//       await dio.patch(
//         "/LK_DELIVERYSTATUS(${data['DocEntry']})",
//         false,
//         false,
//         data: payload,
//       );
//     } else {
//       print("❌ Failed to fetch LK_DELIVERYSTATUS");
//     }
//     print("✅ Location inserted to SAP: $data");
//   } catch (e) {
//     print("❌ Error sending to SAP: $e");
//   }
// }

// Your existing alertToLatLng logic
Future<bool> _alertToLatLng(dynamic lat, dynamic lng) async {
  try {
    final userId = await LocalStorageManger.getString('UserId');
    final data = {
      "ReceiveType": 'Route',
      // "DocEntry": docEntry,
      "Lat": lat,
      "Lng": lng,
      "UserId": userId,
    };
    await dio.postNotification("", data: data);
    print("📄 lat lng alerted ");
    return true;
  } catch (e) {
    print("❌ Failed to alert web: $e");
    return false;
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

// =======================================================================
// LOCATION PROVIDER
// This class manages the state and controls the background service.
// =======================================================================
class LocationProvider with ChangeNotifier {
  final FlutterBackgroundService _backgroundService =
      FlutterBackgroundService();

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  // A helper function to initialize the background service
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  Future<void> startTracking() async {
    if (_isTracking) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    // Store the ID in local storage for the background service to read
    // await LocalStorageManger.setString('currentDeliveryId', id.toString());

    // Start the background service
    await _backgroundService.startService();

    _isTracking = true;
    notifyListeners();
    debugPrint("📡 Live tracking started from UI.");
  }

  Future<void> stopTracking() async {
    // Send a command to stop the background service
    _backgroundService.invoke('stopService');

    _isTracking = false;
    notifyListeners();
    debugPrint("🛑 Live tracking stopped from UI.");
  }

  @override
  void dispose() {
    // It's generally better to let the user control stopping the service.
    // If you need to stop it when the provider is disposed, uncomment the line below.
    // stopTracking();
    super.dispose();
  }
}
// import 'dart:async';
// import 'package:bizd_tech_service/utilities/dio_client.dart';
// import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class LocationProvider with ChangeNotifier {
//   StreamSubscription<Position>? _positionSubscription;
//   bool _isTracking = false;
//   final DioClient dio = DioClient();
//   bool get isTracking => _isTracking;
//   DateTime? _lastUpdateTime;
//   Stopwatch stopwatch = Stopwatch();
//   Timer? saveTimer;

//   Future<void> _insertLocationToSQLite(Position position) async {
//     final db = await LocationDBHelper.db;
//     await db.insert('locations', {
//       'latitude': position.latitude,
//       'longitude': position.longitude,
//       'timestamp': DateTime.now().toIso8601String(),
//     });
//   }

//   Future<void> _sendSQLiteDataToSAP(dynamic id) async {
//     final db = await LocationDBHelper.db;
//     final locations = await db.query('locations');

//     final data = locations
//         .map((loc) => {
//               'U_Lat': loc['latitude'],
//               'U_Long': loc['longitude'],
//               'U_Time': DateFormat('HH:mm:ss')
//                   .format(DateTime.parse(loc['timestamp'] as String)),
//               'U_Date': DateFormat('yyyy-MM-dd')
//                   .format(DateTime.parse(loc['timestamp'] as String)),
//             })
//         .toList();

//     final payload = {
//       "LK_DELIVERYROUTESCollection": data,
//     };

//     try {
//       final res = await dio.get(
//           "/LK_DELIVERYSTATUS?\$filter=U_lk_DeliveryEntry eq $id &\$select=DocEntry");
//       if (res.statusCode == 200) {
//         final Map<String, dynamic> data = res.data["value"][0] ?? {};
//         await dio.patch(
//           "/LK_DELIVERYSTATUS(${data['DocEntry']})",
//           false,
//           false,
//           data: payload,
//         );
//         await db.delete('locations');
//         debugPrint("✅ Sent SQLite data to SAP.");
//       }
//     } catch (e) {
//       debugPrint("❌ Failed to send SQLite data to SAP: $e");
//     }
//   }

//   Future<bool> alertToLatLng(dynamic docEntry, dynamic lat, dynamic lng) async {
//     try {
//       final userId = await LocalStorageManger.getString('UserId');
//       final data = {
//         "ReceiveType": 'Route',
//         "DocEntry": docEntry,
//         "Lat": lat,
//         "Lng": lng,
//         "UserId": userId,
//       };
//       await dio.postNotification("", data: data);
//       debugPrint("📄 lat lng alerted $docEntry");
//       return true;
//     } catch (e) {
//       debugPrint("❌ Failed to alert web: $e");
//       return false;
//     }
//   }

//   Future<void> startTracking(dynamic id) async {
//     if (_isTracking) return;

//     final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//       return;
//     }

//     var permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) return;
//     }

//     stopwatch.start();

//     saveTimer = Timer.periodic(Duration(minutes: 10), (_) async {
//       await _sendSQLiteDataToSAP(id);
//     });

//     _positionSubscription = Geolocator.getPositionStream(
//       locationSettings: LocationSettings(
//         accuracy: LocationAccuracy.bestForNavigation,
//         distanceFilter: 0,
//       ),
//     ).listen((position) async {
//       final now = DateTime.now();
//       if (_lastUpdateTime == null ||
//           now.difference(_lastUpdateTime!).inSeconds >= 4) {
//         _lastUpdateTime = now;
//         await _insertLocationToSQLite(position);
//         await alertToLatLng(id, position.latitude, position.longitude);
//       } else {
//         debugPrint("📌 Skipped update - too soon");
//       }
//     });

//     _isTracking = true;
//     notifyListeners();
//     debugPrint("📡 Live tracking started.");
//   }

//   Future<void> stopTracking({required dynamic id}) async {
//     await _positionSubscription?.cancel();
//     _positionSubscription = null;
//     saveTimer?.cancel();
//     stopwatch.stop();
//     await _sendSQLiteDataToSAP(id);
//     _isTracking = false;
//     notifyListeners();
//     debugPrint("🛑 Live tracking stopped and data sent to SAP.");
//   }

//   @override
//   void dispose() {
//     _positionSubscription?.cancel();
//     saveTimer?.cancel();
//     super.dispose();
//   }
// }

// class LocationDBHelper {
//   static Database? _db;

//   static Future<Database> get db async {
//     if (_db != null) return _db!;
//     final dbPath = await getDatabasesPath();
//     _db = await openDatabase(
//       join(dbPath, 'location_log.db'),
//       version: 1,
//       onCreate: (db, version) {
//         return db.execute('''
//           CREATE TABLE locations(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             latitude REAL,
//             longitude REAL,
//             timestamp TEXT
//           )
//         ''');
//       },
//     );
//     return _db!;
//   }
// }
