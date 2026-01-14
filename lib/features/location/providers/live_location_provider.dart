// // lib/providers/location_provider.dart
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:geolocator/geolocator.dart';

// // Your custom dependencies. Ensure their paths are correct.
// import 'package:bizd_tech_service/core/network/dio_client.dart';
// import 'package:bizd_tech_service/core/storage/local_storage.dart';

// // Your custom Dio client instance.
// // Ensure it's initialized in a way that's safe for a background isolate.
// final DioClient dio = DioClient();

// // =======================================================================
// // BACKGROUND SERVICE ENTRY POINT
// // This code is executed in a separate isolate when the service starts.
// // =======================================================================
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   // We need to re-initialize DioClient here because it's a new isolate.
//   if (service is AndroidServiceInstance) {
//     // service.on('setAsForeground').listen((event) {
//     //   service.setAsForegroundService();
//     // });
//     // service.on('setAsBackground').listen((event) {
//     //   service.setAsBackgroundService();
//     // });
//     // âœ… Call immediately to prevent crash
//     service.setAsForegroundService();

//     // Optional: still keep event listeners if needed
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });

//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });
//   }

//   // Listen for the stop command from the main app
//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });

//   // Get the ID that was passed from the UI
//   // You might want to get other data here as well, like a token
//   dynamic id = await LocalStorageManger.getString('UserId');
//   if (id == null) {
//     print('No delivery ID found. Stopping service.');
//     service.stopSelf();
//     return;
//   }

//   DateTime? lastUpdateTime;

//   final locationSettings = AndroidSettings(
//     accuracy: LocationAccuracy.bestForNavigation,
//     distanceFilter: 1,
//     // Add this to make sure Android knows this is a foreground service
//     // that needs to run for a long time.
//     foregroundNotificationConfig: const ForegroundNotificationConfig(
//       notificationTitle: "Live Delivery Tracking",
//       notificationText: "Your delivery is being tracked.",
//       // You can also provide an icon if you have one
//       // You may need to create a resource for this in your Android project.
//       // notificationIcon: 'ic_stat_icon',
//     ),
//   );

//   // Start listening to the position stream
//   // Use a StreamSubscription to keep a reference.
//   final positionSubscription =
//       Geolocator.getPositionStream(locationSettings: locationSettings)
//           .listen((position) async {
//     final now = DateTime.now();

//     // Throttle the SAP update to every 10 seconds
//     if (lastUpdateTime == null ||
//         now.difference(lastUpdateTime!).inSeconds >= 4) {
//       lastUpdateTime = now;

//       // Call your SAP update functions
//       // await _insertLocationToSAPLive(position, id);
//       await _alertToLatLng(position.latitude, position.longitude);
//     } else {
//       print("ðŸ“Œ Skipped update - too soon");
//     }
//   });

//   // Make sure to cancel the subscription when the service stops.
//   service.on('stopService').listen((event) {
//     positionSubscription.cancel();
//     service.stopSelf();
//   });
// }

// // Your existing _insertLocationToSAPLive logic
// // Future<void> _insertLocationToSAPLive(Position position, dynamic id) async {
// //   final now = DateTime.now();
// //   final data = {
// //     'U_Lat': position.latitude,
// //     'U_Long': position.longitude,
// //     'U_Time': DateFormat('HH:mm:ss').format(now),
// //     'U_Date': DateFormat('yyyy-MM-dd').format(now),
// //   };
// //   try {
// //     final updatedList = [data];
// //     final payload = {
// //       "LK_DELIVERYROUTESCollection": updatedList,
// //     };
// //     print("ðŸ“¡ Sending to SAP: ${jsonEncode(payload)}");
// //     final res = await dio.get(
// //         "/LK_DELIVERYSTATUS?\$filter=U_lk_DeliveryEntry eq $id &\$select=DocEntry");
// //     if (res.statusCode == 200 && res.data["value"]?.isNotEmpty == true) {
// //       final Map<String, dynamic> data = res.data["value"][0];
// //       await dio.patch(
// //         "/LK_DELIVERYSTATUS(${data['DocEntry']})",
// //         false,
// //         false,
// //         data: payload,
// //       );
// //     } else {
// //       print("âŒ Failed to fetch LK_DELIVERYSTATUS");
// //     }
// //     print("âœ… Location inserted to SAP: $data");
// //   } catch (e) {
// //     print("âŒ Error sending to SAP: $e");
// //   }
// // }

// // Your existing alertToLatLng logic
// Future<bool> _alertToLatLng(dynamic lat, dynamic lng) async {
//   try {
//     final userId = await LocalStorageManger.getString('UserId');
//     final data = {
//       "ReceiveType": 'Route',
//       // "DocEntry": docEntry,
//       "Lat": lat,
//       "Lng": lng,
//       "UserId": userId,
//     };
//     await dio.postNotification("", data: data);
//     print("ðŸ“„ lat lng alerted ");
//     return true;
//   } catch (e) {
//     print("âŒ Failed to alert web: $e");
//     return false;
//   }
// }

// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   return true;
// }

// // =======================================================================
// // LOCATION PROVIDER
// // This class manages the state and controls the background service.
// // =======================================================================
// class LocationProvider with ChangeNotifier {
//   final FlutterBackgroundService _backgroundService =
//       FlutterBackgroundService();

//   bool _isTracking = false;
//   bool get isTracking => _isTracking;

//   // A helper function to initialize the background service
//   static Future<void> initializeService() async {
//     final service = FlutterBackgroundService();
//     await service.configure(
//       androidConfiguration: AndroidConfiguration(
//         onStart: onStart,
//         isForegroundMode: true,
//         autoStart: false,
//       ),
//       iosConfiguration: IosConfiguration(
//         autoStart: false,
//         onForeground: onStart,
//         onBackground: onIosBackground,
//       ),
//     );
//   }

//   Future<void> startTracking() async {
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
//           permission == LocationPermission.deniedForever) {
//         return;
//       }
//     }

//     // Store the ID in local storage for the background service to read
//     // await LocalStorageManger.setString('currentDeliveryId', id.toString());

//     // Start the background service
//     await _backgroundService.startService();

//     _isTracking = true;
//     notifyListeners();
//     debugPrint("ðŸ“¡ Live tracking started from UI.");
//   }

//   Future<void> stopTracking() async {
//     // Send a command to stop the background service
//     _backgroundService.invoke('stopService');

//     _isTracking = false;
//     notifyListeners();
//     debugPrint("ðŸ›‘ Live tracking stopped from UI.");
//   }

//   @override
//   void dispose() {
//     // It's generally better to let the user control stopping the service.
//     // If you need to stop it when the provider is disposed, uncomment the line below.
//     // stopTracking();
//     super.dispose();
//   }
// }

