// // import 'package:bizd_tech_service/dashboard/dashboard.dart';
// // import 'package:bizd_tech_service/helper/helper.dart';
// // import 'package:bizd_tech_service/provider/helper_provider.dart';
// // import 'package:bizd_tech_service/provider/update_status_provider.dart';
// // import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
// // import 'package:bizd_tech_service/utilities/dio_client.dart';
// // import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
// // import 'package:bizd_tech_service/wrapper_screen.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_spinkit/flutter_spinkit.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:provider/provider.dart';
// // import 'package:url_launcher/url_launcher.dart';

// // class ViewNotification extends StatefulWidget {
// //   const ViewNotification({super.key});

// //   @override
// //   _ViewNotificationState createState() => _ViewNotificationState();
// // }

// // class _ViewNotificationState extends State<ViewNotification> {
// //   final DioClient dio = DioClient(); // Your custom Dio client

// //   List<dynamic> documents = [];
// //   List<dynamic> warehouses = [];
// //   List<dynamic> customers = [];

// //   int currentIndex = 0;
// //   bool isLoading = true;
// //   bool hasAccept = false;
// //   @override
// //   void initState() {
// //     super.initState();
// //     Future.microtask(() async {
// //       final whProvider = Provider.of<HelperProvider>(context, listen: false);
// //       final customerProvider =
// //           Provider.of<HelperProvider>(context, listen: false);

// //       if (whProvider.warehouses.isEmpty) {
// //         await whProvider.fetchWarehouse(); // Wait until data is fetched
// //       }
// //       if (customerProvider.customer.isEmpty) {
// //         await customerProvider.fetchCustomer(); // Wait until data is fetched
// //       }
// //       if (mounted) {
// //         setState(() {
// //           warehouses = whProvider.warehouses;
// //           customers = customerProvider.customer;
// //         });
// //       }
// //     });

// //     fetchDocuments();
// //   }

// //   late GoogleMapController mapController;

// //   final LatLng _center = const LatLng(11.5564, 104.9282); // Phnom Penh

// //   void _openInGoogleMaps(BuildContext context) {
// //     _showConfirmationDialog(
// //       context: context,
// //       title: "Open Maps ?",
// //       content: "Open this location in Google Maps ?",
// //       onConfirm: () async {
// //         final url =
// //             'https://www.google.com/maps/search/?api=1&query=${_center.latitude},${_center.longitude}';
// //         if (await canLaunchUrl(Uri.parse(url))) {
// //           await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
// //         } else {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //                 content: Text('Cannot open Google Maps on this device.')),
// //           );
// //         }
// //       },
// //     );
// //   }

// //   void makePhoneCall(BuildContext context, String phoneNumber) {
// //     _showConfirmationDialog(
// //       context: context,
// //       title: "Call $phoneNumber ?",
// //       content: "Are you want to call this number ?",
// //       onConfirm: () async {
// //         final Uri phoneUri = Uri.parse("tel:$phoneNumber");

// //         try {
// //           await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
// //         } catch (e) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //                 content: Text('Cannot make phone call on this device')),
// //           );
// //         }
// //       },
// //     );
// //   }

// //   void _onMapCreated(GoogleMapController controller) {
// //     mapController = controller;
// //     // Move camera to specific location
// //     mapController.animateCamera(
// //       CameraUpdate.newCameraPosition(
// //         CameraPosition(
// //           target: _center,
// //           zoom: 16,
// //         ),
// //       ),
// //     );
// //   }

// //   Future<void> fetchDocuments() async {
// //     final userId = await LocalStorageManger.getString('UserId');

// //     try {
// //       final response = await dio.get(
// //           "/DeliveryNotes?\$filter=U_lk_delstat eq 'Pending' and U_lk_driver eq $userId & \$select=DocumentLines,DocNum,U_lk_delstat,U_lk_driver,CardName,CardCode,DocDate,DocTime");
// //       if (response.statusCode == 200) {
// //         // print(response.data["value"]);
// //         // print(response.data["value"].length);
// //         final List<dynamic> data = response.data["value"];
// //         setState(() {
// //           documents = data;
// //           isLoading = false;
// //         });
// //       } else {
// //         throw Exception("Failed to load documents");
// //       }
// //     } catch (e) {
// //       // print(e);
// //       setState(() => isLoading = false);
// //     }
// //   }

// //   Future<void> updateDocumentStatus(int docEntry, String status) async {
// //     try {
// //       await dio.patch(
// //         "/DeliveryNotes($docEntry)",
// //         false,
// //         data: {"U_lk_delstat": status},
// //       );
// //     } catch (e) {
// //       rethrow; // Let the caller handle the error
// //     }
// //   }

// //   Future<void> handleAction(BuildContext context, String status) async {
// //     final currentDoc = documents[currentIndex];
// //     final docEntry = currentDoc["DocNum"];

// //     MaterialDialog.loading(context);

// //     try {
// //       await Provider.of<UpdateStatusProvider>(context, listen: false)
// //           .updateDocumentAndStatus(
// //               docEntry: docEntry, status: status, remarks: "");
// //       if (status == "Started") {
// //         hasAccept = true;
// //       }

// //       setState(() {
// //         currentIndex++;
// //       });
// //       // Show SnackBar
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           backgroundColor: const Color.fromARGB(255, 71, 73, 75),
// //           behavior: SnackBarBehavior.floating,
// //           elevation: 10,
// //           margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// //           content: Row(
// //             children: [
// //               const Icon(Icons.local_shipping, color: Colors.white, size: 28),
// //               const SizedBox(width: 16),
// //               Expanded(
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       "Delivery: $status",
// //                       style: const TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       "Delivery Code: ${currentDoc["DocNum"]}",
// //                       style: const TextStyle(
// //                         fontSize: 14,
// //                         color: Colors.white70,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //           duration: const Duration(seconds: 2),
// //         ),
// //       );

// //       if (currentIndex >= documents.length) {
// //         MaterialDialog.close(context); // Close loading
// //         if (hasAccept) {
// //           Navigator.pushAndRemoveUntil(
// //             context,
// //             MaterialPageRoute(builder: (context) => const Dashboard()),
// //             (route) => false,
// //           );
// //         } else {
// //           debugPrint("🚪 Exiting app after going to WrapperScreen");

// //           Navigator.pushAndRemoveUntil(
// //             context,
// //             MaterialPageRoute(builder: (context) => const Dashboard()),
// //             (route) => false,
// //           );

// //           // Give time for navigation to settle
// //           await Future.delayed(const Duration(milliseconds: 300));
// //           SystemNavigator.pop(); // or SystemNavigator.exit() on newer versions
// //         }
// //       }

// //       MaterialDialog.close(context);
// //     } catch (e) {
// //       MaterialDialog.close(context);
// //       MaterialDialog.warning(context, title: "Error", body: e.toString());
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SingleChildScrollView(
// //         child: isLoading
// //             ? SizedBox(
// //                 width: MediaQuery.of(context).size.width,
// //                 height: MediaQuery.of(context).size.height,
// //                 child: const Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       SpinKitFadingCircle(
// //                         color: Colors.blue,
// //                         size: 60.0,
// //                       ),
// //                       SizedBox(
// //                         height: 15,
// //                       ),
// //                       Text(
// //                         "Loading",
// //                         style: TextStyle(
// //                             fontSize: 15,
// //                             color: Color.fromARGB(255, 94, 96, 97)),
// //                       )
// //                     ],
// //                   ),
// //                 ),
// //               )
// //             : Column(
// //                 children: [
// //                   // Map Section
// //                   Container(
// //                     height: 400,
// //                     width: double.infinity,
// //                     color: Colors.grey[300],
// //                     child: GoogleMap(
// //                       onMapCreated: _onMapCreated,
// //                       initialCameraPosition: CameraPosition(
// //                         target: _center,
// //                         zoom: 14,
// //                       ),
// //                       markers: {
// //                         Marker(
// //                           markerId: const MarkerId("target_location"),
// //                           position: _center,
// //                           infoWindow:
// //                               const InfoWindow(title: "Selected Location"),
// //                         ),
// //                       },
// //                       myLocationEnabled: true,
// //                       myLocationButtonEnabled: true,
// //                       zoomControlsEnabled: true,
// //                     ),
// //                   ),

// //                   // Detail Route View Section
// //                   Container(
// //                     height: 290,
// //                     width: double.infinity,
// //                     padding: const EdgeInsets.all(16),
// //                     margin: const EdgeInsets.all(10),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(7),
// //                       border: const Border(
// //                           top: BorderSide(
// //                               color: Color.fromARGB(255, 177, 207, 240))),
// //                       boxShadow: const [
// //                         BoxShadow(
// //                           color: Colors.black12,
// //                           blurRadius: 10,
// //                         ),
// //                       ],
// //                     ),
// //                     child: Stack(
// //                       children: [
// //                         Positioned(
// //                             top: 100,
// //                             left: 10,
// //                             child: Container(
// //                               height: 32,
// //                               width: 1,
// //                               color: const Color.fromARGB(255, 160, 161, 161),
// //                             )),
// //                         Column(
// //                           children: [
// //                             // Distance & Delivery Code
// //                             Row(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 const Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     Text(
// //                                       'Distance',
// //                                       style: TextStyle(color: Colors.grey),
// //                                     ),
// //                                     SizedBox(
// //                                       height: 7,
// //                                     ),
// //                                     Text(
// //                                       '2.5 Km',
// //                                       style: TextStyle(
// //                                         fontWeight: FontWeight.bold,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     const Text(
// //                                       'Delivery',
// //                                       style: TextStyle(color: Colors.grey),
// //                                     ),
// //                                     const SizedBox(
// //                                       height: 7,
// //                                     ),
// //                                     Text(
// //                                       (documents.isNotEmpty &&
// //                                               currentIndex >= 0 &&
// //                                               currentIndex < documents.length)
// //                                           ? '${documents[currentIndex]["DocNum"]}'
// //                                           : 'No Document Found',
// //                                       style: const TextStyle(
// //                                         color: Colors.blue,
// //                                         fontWeight: FontWeight.bold,
// //                                         decoration: TextDecoration.underline,
// //                                       ),
// //                                     )
// //                                   ],
// //                                 ),
// //                                 const SizedBox(
// //                                   width: 50,
// //                                 ),
// //                                 Row(
// //                                   children: [
// //                                     GestureDetector(
// //                                       onTap: () => _openInGoogleMaps(context),
// //                                       child: Container(
// //                                         width:
// //                                             27, // Set width & height equal for perfect circle
// //                                         height: 27,
// //                                         decoration: BoxDecoration(
// //                                           color: Colors
// //                                               .white, // background color (optional)
// //                                           shape: BoxShape.circle,
// //                                           border: Border.all(
// //                                             color: const Color.fromARGB(255,
// //                                                 205, 208, 212), // border color
// //                                             width: 1, // border width
// //                                           ),
// //                                         ),
// //                                         child: const Center(
// //                                           child: Icon(
// //                                             Icons.directions,
// //                                             size: 18,
// //                                             color: Colors.black,
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     const SizedBox(
// //                                       width: 15,
// //                                     ),
// //                                     GestureDetector(
// //                                       onTap: () => makePhoneCall(
// //                                           context,
// //                                           customers
// //                                                       .firstWhere(
// //                                                         (e) =>
// //                                                             e["CardCode"]
// //                                                                 .toString() ==
// //                                                             documents[
// //                                                                     currentIndex]
// //                                                                 ["CardCode"],
// //                                                         orElse: () =>
// //                                                             {"Phone1": "N/A"},
// //                                                       )["Phone1"]
// //                                                       .toString() ==
// //                                                   "null"
// //                                               ? "Unknow Number"
// //                                               : customers
// //                                                   .firstWhere(
// //                                                     (e) =>
// //                                                         e["CardCode"]
// //                                                             .toString() ==
// //                                                         documents[currentIndex]
// //                                                             ["CardCode"],
// //                                                     orElse: () =>
// //                                                         {"Phone1": "N/A"},
// //                                                   )["Phone1"]
// //                                                   .toString()),
// //                                       child: Container(
// //                                         width:
// //                                             27, // Set width & height equal for perfect circle
// //                                         height: 27,
// //                                         decoration: BoxDecoration(
// //                                           color: Colors
// //                                               .white, // background color (optional)
// //                                           shape: BoxShape.circle,
// //                                           border: Border.all(
// //                                             color: const Color.fromARGB(
// //                                                 255, 205, 208, 212),
// //                                             width: 1, // border width
// //                                           ),
// //                                         ),
// //                                         child: const Center(
// //                                           child: Icon(
// //                                             Icons.call,
// //                                             size: 18,
// //                                             color: Colors.black,
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     )
// //                                   ],
// //                                 )
// //                               ],
// //                             ),
// //                             const SizedBox(height: 7),
// //                             const Divider(),

// //                             // Locations
// //                             Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 const SizedBox(
// //                                   height: 5,
// //                                 ),
// //                                 Row(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     const Icon(Icons.store,
// //                                         size: 20, color: Colors.black),
// //                                     const SizedBox(width: 8),
// //                                     Expanded(
// //                                       child: Column(
// //                                         crossAxisAlignment:
// //                                             CrossAxisAlignment.start,
// //                                         children: [
// //                                           Text(
// //                                             (documents.isNotEmpty &&
// //                                                     currentIndex >= 0 &&
// //                                                     currentIndex <
// //                                                         documents.length &&
// //                                                     documents[currentIndex]
// //                                                             ["DocumentLines"] !=
// //                                                         null &&
// //                                                     documents[currentIndex]
// //                                                             ["DocumentLines"]
// //                                                         .isNotEmpty)
// //                                                 ? (warehouses.firstWhere(
// //                                                         (e) =>
// //                                                             e["WarehouseCode"] ==
// //                                                             documents[currentIndex]
// //                                                                     ["DocumentLines"][0]
// //                                                                 [
// //                                                                 "WarehouseCode"],
// //                                                         orElse: () => {
// //                                                               "WarehouseName":
// //                                                                   "N/A"
// //                                                             })["WarehouseName"] ??
// //                                                     "N/A")
// //                                                 : "No Warehouse",
// //                                             style: const TextStyle(
// //                                                 fontWeight: FontWeight.bold),
// //                                           ),
// //                                           const SizedBox(
// //                                             height: 7,
// //                                           ),
// //                                           const Text(
// //                                               "102 St New Road, Chron Changva,",
// //                                               style: TextStyle(
// //                                                   color: Colors.grey)),
// //                                         ],
// //                                       ),
// //                                     ),
// //                                     Column(
// //                                       children: (documents.isNotEmpty &&
// //                                               currentIndex >= 0 &&
// //                                               currentIndex < documents.length)
// //                                           ? [
// //                                               Text(
// //                                                 "${formatCustomShortDate(documents[currentIndex]["DocDate"])},",
// //                                                 style: const TextStyle(
// //                                                     fontWeight:
// //                                                         FontWeight.bold),
// //                                               ),
// //                                               Text(
// //                                                 formatCustomTime(
// //                                                     documents[currentIndex]
// //                                                         ["DocTime"]),
// //                                                 style: const TextStyle(
// //                                                     color: Colors.grey),
// //                                               ),
// //                                             ]
// //                                           : [
// //                                               const Text("No Date",
// //                                                   style: TextStyle(
// //                                                       color: Colors.red)),
// //                                               const Text("No Time",
// //                                                   style: TextStyle(
// //                                                       color: Colors.red)),
// //                                             ],
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 const SizedBox(height: 15),
// //                                 Row(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     const Icon(Icons.location_on,
// //                                         size: 20, color: Colors.black),
// //                                     const SizedBox(width: 8),
// //                                     Expanded(
// //                                       child: Column(
// //                                         crossAxisAlignment:
// //                                             CrossAxisAlignment.start,
// //                                         children: (documents.isNotEmpty &&
// //                                                 currentIndex >= 0 &&
// //                                                 currentIndex <
// //                                                     documents.length &&
// //                                                 documents[currentIndex]
// //                                                         ["DocumentLines"] !=
// //                                                     null &&
// //                                                 documents[currentIndex]
// //                                                         ["DocumentLines"]
// //                                                     .isNotEmpty)
// //                                             ? [
// //                                                 Text(
// //                                                   "To: ${documents[currentIndex]["CardName"]}",
// //                                                   style: const TextStyle(
// //                                                       fontWeight:
// //                                                           FontWeight.bold),
// //                                                 ),
// //                                                 const SizedBox(height: 7),
// //                                                 Text(
// //                                                   documents[currentIndex][
// //                                                                   "DocumentLines"][0]
// //                                                               [
// //                                                               "ShipToDescription"]
// //                                                           .isEmpty
// //                                                       ? "N/A"
// //                                                       : documents[currentIndex][
// //                                                               "DocumentLines"][0]
// //                                                           ["ShipToDescription"],
// //                                                   style: const TextStyle(
// //                                                       color: Colors.grey),
// //                                                 ),
// //                                               ]
// //                                             : [
// //                                                 const Text("No CardName",
// //                                                     style: TextStyle(
// //                                                         color: Colors.red)),
// //                                                 const SizedBox(height: 7),
// //                                                 const Text(
// //                                                     "No ShipToDescription",
// //                                                     style: TextStyle(
// //                                                         color: Colors.red)),
// //                                               ],
// //                                       ),
// //                                     ),
// //                                     Column(
// //                                       children: (documents.isNotEmpty &&
// //                                               currentIndex >= 0 &&
// //                                               currentIndex < documents.length)
// //                                           ? [
// //                                               Text(
// //                                                 "${formatCustomShortDate(documents[currentIndex]["DocDate"])},",
// //                                                 style: const TextStyle(
// //                                                     fontWeight:
// //                                                         FontWeight.bold),
// //                                               ),
// //                                               Text(
// //                                                 formatCustomTime(
// //                                                     documents[currentIndex]
// //                                                         ["DocTime"]),
// //                                                 style: const TextStyle(
// //                                                     color: Colors.grey),
// //                                               ),
// //                                             ]
// //                                           : [
// //                                               const Text("No Date",
// //                                                   style: TextStyle(
// //                                                       color: Colors.red)),
// //                                               const Text("No Time",
// //                                                   style: TextStyle(
// //                                                       color: Colors.red)),
// //                                             ],
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ],
// //                             ),
// //                             // Spacer(),
// //                             const SizedBox(
// //                               height: 20,
// //                             ),
// //                             // Accept & Reject Buttons
// //                             Row(
// //                               children: [
// //                                 Expanded(
// //                                   child: ElevatedButton(
// //                                     onPressed: () =>
// //                                         handleAction(context, "Open"),
// //                                     style: ElevatedButton.styleFrom(
// //                                       backgroundColor: Colors.red,
// //                                     ),
// //                                     child: const Text("Reject",
// //                                         style: TextStyle(color: Colors.white)),
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 16),
// //                                 Expanded(
// //                                   child: ElevatedButton(
// //                                     onPressed: () =>
// //                                         handleAction(context, "Started"),
// //                                     style: ElevatedButton.styleFrom(
// //                                       backgroundColor: Colors.green,
// //                                     ),
// //                                     child: const Text(
// //                                       "Accept",
// //                                       style: TextStyle(color: Colors.white),
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   const SizedBox(
// //                     height: 4,
// //                   ),
// //                   Container(
// //                     child: const Column(
// //                       children: [
// //                         Center(
// //                           child: SpinKitFadingCircle(
// //                             color: Colors.blue,
// //                             size: 50.0,
// //                           ),
// //                         ),
// //                         SizedBox(
// //                           height: 7,
// //                         ),
// //                         Text(
// //                           "Would you like to proceed with accepting or rejecting?",
// //                           style:
// //                               TextStyle(color: Colors.blueGrey, fontSize: 13),
// //                         )
// //                       ],
// //                     ),
// //                   )
// //                 ],
// //               ),
// //       ),
// //     );
// //   }
// // }

// // Future<void> _showConfirmationDialog({
// //   required BuildContext context,
// //   required String title,
// //   required String content,
// //   required VoidCallback onConfirm,
// // }) async {
// //   final result = await showDialog<bool>(
// //     context: context,
// //     builder: (context) {
// //       return AlertDialog(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //         title: Text(
// //           title,
// //           style: const TextStyle(fontSize: 22),
// //         ),
// //         content: Text(
// //           content,
// //           style: const TextStyle(fontSize: 14.5),
// //         ),
// //         actions: [
// //           TextButton(
// //             child: const Text("Cancel"),
// //             onPressed: () => Navigator.of(context).pop(false),
// //           ),
// //           const SizedBox(
// //             width: 5,
// //           ),
// //           ElevatedButton(
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: Colors.green,
// //               foregroundColor: Colors.white,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(7),
// //               ),
// //               minimumSize: const Size(
// //                   70, 35), // width, height (height smaller than default)
// //               padding: const EdgeInsets.symmetric(
// //                   horizontal: 16), // optional: adjust padding
// //             ),
// //             onPressed: () => Navigator.of(context).pop(true),
// //             child: const Text("Go"),
// //           ),
// //         ],
// //       );
// //     },
// //   );

// //   if (result == true) {
// //     onConfirm();
// //   }
// // }
// import 'dart:async';

// import 'package:bizd_tech_service/dashboard/dashboard.dart';
// import 'package:bizd_tech_service/helper/helper.dart';
// import 'package:bizd_tech_service/provider/auth_provider.dart';
// import 'package:bizd_tech_service/provider/helper_provider.dart';
// import 'package:bizd_tech_service/provider/live_location_provider.dart';
// import 'package:bizd_tech_service/provider/update_status_provider.dart';
// import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
// import 'package:bizd_tech_service/utilities/dio_client.dart';
// import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:permission_handler/permission_handler.dart';

// class ViewNotification extends StatefulWidget {
//   const ViewNotification({super.key});

//   @override
//   _ViewNotificationState createState() => _ViewNotificationState();
// }

// class _ViewNotificationState extends State<ViewNotification> {
//   final DioClient dio = DioClient(); // Your custom Dio client

//   List<dynamic> documents = [];
//   List<dynamic> warehouses = [];
//   List<dynamic> customers = [];

//   int currentIndex = 0;
//   bool isLoading = true;
//   bool isLoadingInit = false;

//   // bool hasAccept = false;
//   @override
//   void initState() {
//     super.initState();

//     Future.microtask(() async {
//       // 🔒 Request location permission first
//       final status = await Permission.location.request();
//       setState(() {
//         isLoadingInit = true;
//       });
//       if (status.isGranted) {
//         // 📦 Fetch data after permission is granted
//         final whProvider = Provider.of<HelperProvider>(context, listen: false);
//         final customerProvider =
//             Provider.of<HelperProvider>(context, listen: false);

//         if (whProvider.warehouses.isEmpty) {
//           await whProvider.fetchWarehouse();
//         }
//         if (customerProvider.customer.isEmpty) {
//           await customerProvider.fetchCustomer();
//         }

//         if (mounted) {
//           setState(() {
//             warehouses = whProvider.warehouses;
//             customers = customerProvider.customer;
//           });
//         }

//         fetchDocuments(); // Your custom method
//         setState(() {
//           isLoadingInit = false;
//         });
//       } else {
//         setState(() {
//           isLoadingInit = false;
//         });
//         // ❌ Permission denied
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location permission denied')),
//         );
//       }
//       if (status.isGranted) {
//         // 📦 Fetch data after permission is granted
//         final whProvider = Provider.of<HelperProvider>(context, listen: false);
//         final customerProvider =
//             Provider.of<HelperProvider>(context, listen: false);

//         if (whProvider.warehouses.isEmpty) {
//           await whProvider.fetchWarehouse();
//         }
//         if (customerProvider.customer.isEmpty) {
//           await customerProvider.fetchCustomer();
//         }

//         if (mounted) {
//           setState(() {
//             warehouses = whProvider.warehouses;
//             customers = customerProvider.customer;
//           });
//         }

//         fetchDocuments(); // Your custom method
//       } else {
//         // ❌ Permission denied
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location permission denied')),
//         );
//       }
//     });
//   }

//   LatLng? _parseLatLng(String? latLngStr) {
//     if (latLngStr == null || !latLngStr.contains(",")) return null;

//     final parts = latLngStr.split(",");
//     if (parts.length != 2) return null;

//     final lat = double.tryParse(parts[0].trim());
//     final lng = double.tryParse(parts[1].trim());

//     if (lat == null || lng == null) return null;

//     return LatLng(lat, lng);
//   }

//   late GoogleMapController mapController;
//   void _openInGoogleMaps(BuildContext context) {
//     try {
//       final doc = documents[currentIndex];
//       final warehouseCode = doc["DocumentLines"][0]["WarehouseCode"];
//       final customerCode = doc["CardCode"];
//       final warehouse = warehouses.firstWhere(
//         (e) => e["WarehouseCode"] == warehouseCode,
//         orElse: () => null,
//       );

//       final customer = customers.firstWhere(
//         (e) => e["CardCode"] == customerCode,
//         orElse: () => null,
//       );

//       if (warehouse == null || customer == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Warehouse or customer location not found.')),
//         );
//         return;
//       }

//       final fromCoords = _parseLatLng(warehouse["U_LK_LatLong"]);
//       final toCoords = _parseLatLng(customer["BPAddresses"][0]["U_LK_LatLong"]);
//       print("From: $fromCoords, To: $toCoords");

//       if (fromCoords == null || toCoords == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Invalid coordinates format.')),
//         );
//         return;
//       }

//       _showConfirmationDialog(
//         context: context,
//         title: "Open Maps?",
//         content: "Open this location in Google Maps?",
//         onConfirm: () async {
//           final url = Uri.parse(
//             'https://www.google.com/maps/dir/?api=1&origin=${fromCoords.latitude},${fromCoords.longitude}&destination=${toCoords.latitude},${toCoords.longitude}&travelmode=driving',
//           );

//           if (await canLaunchUrl(url)) {
//             await launchUrl(url, mode: LaunchMode.externalApplication);
//           } else {
//             if (context.mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Cannot open Google Maps on this device.'),
//                 ),
//               );
//             }
//           }
//         },
//       );
//     } catch (e) {
//       debugPrint('Error opening Google Maps: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Something went wrong.')),
//       );
//     }
//   }

//   void makePhoneCall(BuildContext context, String phoneNumber) {
//     _showConfirmationDialog(
//       context: context,
//       title: "Call $phoneNumber ?",
//       content: "Are you want to call this number ?",
//       onConfirm: () async {
//         final Uri phoneUri = Uri.parse("tel:$phoneNumber");

//         try {
//           await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text('Cannot make phone call on this device')),
//           );
//         }
//       },
//     );
//   }

//   late LatLng _center = const LatLng(11.5564, 104.9282); // Phnom Penh

//   Future<void> fetchDocuments() async {
//     final userId = await LocalStorageManger.getString('UserId');

//     try {
//       final response = await dio.get(
//           "/DeliveryNotes?\$filter=U_lk_delstat eq 'Pending' and U_lk_driver eq $userId & \$select=DocumentLines,DocNum,U_lk_distance,DocEntry,U_lk_delstat,U_lk_driver,CardName,CardCode,DocDate,DocTime,U_lk_reqdeltim,U_lk_duration");
//       if (response.statusCode == 200) {
//         // print(response.data["value"]);
//         // print(response.data["value"].length);
//         final List<dynamic> data = response.data["value"];
//         setState(() {
//           documents = data;
//           isLoading = false;
//         });
//       } else {
//         throw Exception("Failed to load documents");
//       }
//     } catch (e) {
//       // print(e);
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> updateDocumentStatus(int docEntry, String status) async {
//     try {
//       await dio.patch(
//         "/DeliveryNotes($docEntry)",
//         false,
//         false,
//         data: {"U_lk_delstat": status},
//       );
//     } catch (e) {
//       rethrow; // Let the caller handle the error
//     }
//   }

//   // StreamSubscription<Position>? _positionSubscription;
//   // final bool _locationStarted = false;

//   Future<void> startLocationUpdates() async {
//     // final locationProvider =
//     //     Provider.of<LocationProvider>(context, listen: false);
//     // locationProvider.startTracking();
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     final doc = documents[currentIndex];

//     final customerCode = doc["CardCode"];

//     final customer = customers.firstWhere(
//       (e) => e["CardCode"] == customerCode,
//       orElse: () => null,
//     );
//     final toCoords = _parseLatLng(customer["BPAddresses"][0]["U_LK_LatLong"]);
//     mapController = controller;
//     print(toCoords);
//     // Move camera to specific location
//     print("This Is $toCoords");
//     mapController.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: toCoords as LatLng,
//           zoom: 16,
//         ),
//       ),
//     );
//   }

//   Future<void> handleAction(BuildContext context, String status) async {
//     final currentDoc = documents[currentIndex];
//     final docEntry = currentDoc["DocNum"];
//     MaterialDialog.loading(context);

//     try {
//       await Provider.of<UpdateStatusProvider>(context, listen: false)
//           .updateDocumentAndStatus(
//               docEntry: docEntry,
//               status: status,
//               remarks: "",
//               context: context);
//       // if (status == "Started") {
//       //   hasAccept = true;
//       // }
//       setState(() {
//         currentIndex++;
//       });
//       // Show SnackBar
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: const Color.fromARGB(255, 71, 73, 75),
//           behavior: SnackBarBehavior.floating,
//           elevation: 10,
//           margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           content: Row(
//             children: [
//               const Icon(Icons.local_shipping, color: Colors.white, size: 28),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Delivery: $status",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "Delivery Code: ${currentDoc["DocNum"]}",
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//       if (currentIndex >= documents.length) {
//         MaterialDialog.close(context); // Close loading

//         await startLocationUpdates();
//         await Future.delayed(const Duration(milliseconds: 300));
//         await Future.delayed(const Duration(milliseconds: 300));
//         // SystemNavigator.pop(); // or SystemNavigator.exit() on newer versions
//         if (!mounted) return; // Check if widget is still mounted
//         await Provider.of<AuthProvider>(context, listen: false).checkSession();
//       }
//       Provider.of<AuthProvider>(context, listen: false).checkSession();

//       MaterialDialog.close(context);
//     } catch (e) {
//       MaterialDialog.close(context);
//       MaterialDialog.warning(context, title: "Error", body: e.toString());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (documents.isEmpty)
//       return Scaffold(
//         body: SizedBox(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           child: const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SpinKitFadingCircle(
//                   color: Colors.blue,
//                   size: 60.0,
//                 ),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 Text(
//                   "Loading",
//                   style: TextStyle(
//                       fontSize: 15, color: Color.fromARGB(255, 94, 96, 97)),
//                 )
//               ],
//             ),
//           ),
//         ),
//       );

//     final doc = documents[0];

//     final customerCode = doc["CardCode"];

//     final customer = customers.firstWhere(
//       (e) => e["CardCode"] == customerCode,
//       orElse: () => null,
//     );
//     final toCoords = _parseLatLng(customer["BPAddresses"][0]["U_LK_LatLong"]);
//     print(toCoords);

//     return Scaffold(
//       body: SingleChildScrollView(
//         child: isLoading || isLoadingInit
//             ? SizedBox(
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height,
//                 child: const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SpinKitFadingCircle(
//                         color: Colors.blue,
//                         size: 60.0,
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       Text(
//                         "Loading",
//                         style: TextStyle(
//                             fontSize: 15,
//                             color: Color.fromARGB(255, 94, 96, 97)),
//                       )
//                     ],
//                   ),
//                 ),
//               )
//             : Column(
//                 children: [
//                   // Map Section
//                   Container(
//                     height: 400,
//                     width: double.infinity,
//                     color: Colors.grey[300],
//                     child: GoogleMap(
//                       onMapCreated: _onMapCreated,
//                       initialCameraPosition: CameraPosition(
//                         target: toCoords as LatLng,
//                         zoom: 14,
//                       ),
//                       markers: {
//                         Marker(
//                           markerId: const MarkerId("target_location"),
//                           position: toCoords,
//                           infoWindow:
//                               const InfoWindow(title: "Selected Location"),
//                         ),
//                       },
//                       myLocationEnabled: true,
//                       myLocationButtonEnabled: true,
//                       zoomControlsEnabled: true,
//                     ),
//                   ),

//                   // Detail Route View Section
//                   Container(
//                     height: 290,
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(16),
//                     margin: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(7),
//                       border: const Border(
//                           top: BorderSide(
//                               color: Color.fromARGB(255, 177, 207, 240))),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                         ),
//                       ],
//                     ),
//                     child: Stack(
//                       children: [
//                         Positioned(
//                             top: 100,
//                             left: 10,
//                             child: Container(
//                               height: 32,
//                               width: 1,
//                               color: const Color.fromARGB(255, 160, 161, 161),
//                             )),
//                         Column(
//                           children: [
//                             // Distance & Delivery Code
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Distance',
//                                       style: TextStyle(color: Colors.grey),
//                                     ),
//                                     SizedBox(
//                                       height: 7,
//                                     ),
//                                     Text(
//                                       (documents.isNotEmpty &&
//                                               currentIndex >= 0 &&
//                                               currentIndex < documents.length)
//                                           ? '${documents[currentIndex]["U_lk_distance"]?.split(" ")[0]} km'
//                                           : '...',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       'Delivery',
//                                       style: TextStyle(color: Colors.grey),
//                                     ),
//                                     const SizedBox(
//                                       height: 7,
//                                     ),
//                                     Text(
//                                       (documents.isNotEmpty &&
//                                               currentIndex >= 0 &&
//                                               currentIndex < documents.length)
//                                           ? '${documents[currentIndex]["DocNum"]}'
//                                           : '...',
//                                       style: const TextStyle(
//                                         color: Colors.blue,
//                                         fontWeight: FontWeight.bold,
//                                         decoration: TextDecoration.underline,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   width: 50,
//                                 ),
//                                 Row(
//                                   children: [
//                                     GestureDetector(
//                                       onTap: () => _openInGoogleMaps(context),
//                                       child: Container(
//                                         width:
//                                             27, // Set width & height equal for perfect circle
//                                         height: 27,
//                                         decoration: BoxDecoration(
//                                           color: Colors
//                                               .white, // background color (optional)
//                                           shape: BoxShape.circle,
//                                           border: Border.all(
//                                             color: const Color.fromARGB(255,
//                                                 205, 208, 212), // border color
//                                             width: 1, // border width
//                                           ),
//                                         ),
//                                         child: const Center(
//                                           child: Icon(
//                                             Icons.directions,
//                                             size: 18,
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       width: 15,
//                                     ),
//                                     GestureDetector(
//                                       onTap: () => makePhoneCall(
//                                           context,
//                                           customers
//                                                       .firstWhere(
//                                                         (e) =>
//                                                             e["CardCode"]
//                                                                 .toString() ==
//                                                             documents[
//                                                                     currentIndex]
//                                                                 ["CardCode"],
//                                                         orElse: () =>
//                                                             {"Phone1": "N/A"},
//                                                       )["Phone1"]
//                                                       .toString() ==
//                                                   "null"
//                                               ? "Unknow Number"
//                                               : customers
//                                                   .firstWhere(
//                                                     (e) =>
//                                                         e["CardCode"]
//                                                             .toString() ==
//                                                         documents[currentIndex]
//                                                             ["CardCode"],
//                                                     orElse: () =>
//                                                         {"Phone1": "N/A"},
//                                                   )["Phone1"]
//                                                   .toString()),
//                                       child: Container(
//                                         width:
//                                             27, // Set width & height equal for perfect circle
//                                         height: 27,
//                                         decoration: BoxDecoration(
//                                           color: Colors
//                                               .white, // background color (optional)
//                                           shape: BoxShape.circle,
//                                           border: Border.all(
//                                             color: const Color.fromARGB(
//                                                 255, 205, 208, 212),
//                                             width: 1, // border width
//                                           ),
//                                         ),
//                                         child: const Center(
//                                           child: Icon(
//                                             Icons.call,
//                                             size: 18,
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                       ),
//                                     )
//                                   ],
//                                 )
//                               ],
//                             ),
//                             const SizedBox(height: 7),
//                             const Divider(),

//                             // Locations
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(
//                                   height: 5,
//                                 ),
//                                 Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Icon(Icons.store,
//                                         size: 20, color: Colors.black),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           SizedBox(
//                                             width: 240,
//                                             child: Text(
//                                               (documents.isNotEmpty &&
//                                                       currentIndex >= 0 &&
//                                                       currentIndex <
//                                                           documents.length &&
//                                                       documents[currentIndex][
//                                                               "DocumentLines"] !=
//                                                           null &&
//                                                       documents[currentIndex]
//                                                               ["DocumentLines"]
//                                                           .isNotEmpty)
//                                                   ? (warehouses.firstWhere(
//                                                           (e) =>
//                                                               e["WarehouseCode"] ==
//                                                               documents[currentIndex]
//                                                                       ["DocumentLines"][0]
//                                                                   [
//                                                                   "WarehouseCode"],
//                                                           orElse: () => {
//                                                                 "WarehouseName":
//                                                                     "N/A"
//                                                               })["WarehouseName"] ??
//                                                       "N/A")
//                                                   : "No Warehouse",
//                                               style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 14,
//                                               ),
//                                               overflow: TextOverflow.ellipsis,
//                                               maxLines: 1,
//                                             ),
//                                           ),
//                                           const SizedBox(
//                                             height: 7,
//                                           ),
//                                           SizedBox(
//                                             width: 240,
//                                             child: Text(
//                                               "N/A",
//                                               overflow: TextOverflow.ellipsis,
//                                               maxLines: 1,
//                                               style: TextStyle(
//                                                   fontSize: 14,
//                                                   color: Colors
//                                                       .grey), // optional styling
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Column(
//                                       children: (documents.isNotEmpty &&
//                                               currentIndex >= 0 &&
//                                               currentIndex < documents.length)
//                                           ? [
//                                               Text(
//                                                 "${formatCustomShortDate(documents[currentIndex]["DocDate"])},",
//                                                 style: const TextStyle(
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               ),
//                                               Text(
//                                                 documents[currentIndex][
//                                                             "U_lk_reqdeltim"] !=
//                                                         "00:00:00"
//                                                     ? formatCustomTime(documents[
//                                                                 currentIndex][
//                                                             "U_lk_reqdeltim"] ??
//                                                         "00:00:00")
//                                                     : "N/A",
//                                                 style: const TextStyle(
//                                                     color: Colors.grey),
//                                               ),
//                                             ]
//                                           : [
//                                               const Text("Waiting",
//                                                   style: TextStyle(
//                                                       color: Colors.grey)),
//                                               const Text("Waiting",
//                                                   style: TextStyle(
//                                                       color: Colors.grey)),
//                                             ],
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 15),
//                                 Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Icon(Icons.location_on,
//                                         size: 20, color: Colors.black),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: (documents.isNotEmpty &&
//                                                 currentIndex >= 0 &&
//                                                 currentIndex <
//                                                     documents.length &&
//                                                 documents[currentIndex]
//                                                         ["DocumentLines"] !=
//                                                     null &&
//                                                 documents[currentIndex]
//                                                         ["DocumentLines"]
//                                                     .isNotEmpty)
//                                             ? [
//                                                 SizedBox(
//                                                   width: 240,
//                                                   child: Text(
//                                                     "To: ${documents[currentIndex]["CardName"]}",
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     maxLines: 1,
//                                                     style: TextStyle(
//                                                         fontSize: 14,
//                                                         fontWeight: FontWeight
//                                                             .bold), // optional styling
//                                                   ),
//                                                 ),
//                                                 // Text(
//                                                 //   "To: ${documents[currentIndex]["CardName"]}",
//                                                 //   style: const TextStyle(
//                                                 //       fontWeight:
//                                                 //           FontWeight.bold),
//                                                 // ),
//                                                 const SizedBox(height: 7),
//                                                 SizedBox(
//                                                   width: 240,
//                                                   child: Text(
//                                                     documents[currentIndex][
//                                                                     "DocumentLines"][0]
//                                                                 [
//                                                                 "ShipToDescription"]
//                                                             .isEmpty
//                                                         ? "N/A"
//                                                         : documents[currentIndex]
//                                                                 [
//                                                                 "DocumentLines"][0]
//                                                             [
//                                                             "ShipToDescription"],
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     maxLines: 1,
//                                                     style: TextStyle(
//                                                         fontSize: 14,
//                                                         color: Colors
//                                                             .grey), // optional styling
//                                                   ),
//                                                 ),

//                                                 // Text(
//                                                 //   documents[currentIndex][
//                                                 //                   "DocumentLines"][0]
//                                                 //               [
//                                                 //               "ShipToDescription"]
//                                                 //           .isEmpty
//                                                 //       ? "N/A"
//                                                 //       : documents[currentIndex][
//                                                 //               "DocumentLines"][0]
//                                                 //           ["ShipToDescription"],
//                                                 //   style: const TextStyle(
//                                                 //       color: Colors.grey),
//                                                 // ),
//                                               ]
//                                             : [
//                                                 const Text("Waiting",
//                                                     style: TextStyle(
//                                                         color: Colors.grey)),
//                                                 const SizedBox(height: 7),
//                                                 const Text("Waiting",
//                                                     style: TextStyle(
//                                                         color: Colors.grey)),
//                                               ],
//                                       ),
//                                     ),
//                                     Column(
//                                       children: (documents.isNotEmpty &&
//                                               currentIndex >= 0 &&
//                                               currentIndex < documents.length)
//                                           ? [
//                                               Text(
//                                                 "${formatCustomShortDate(documents[currentIndex]["DocDate"])},",
//                                                 style: const TextStyle(
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               ),
//                                               Text(
//                                                 documents[currentIndex][
//                                                                 "U_lk_reqdeltim"] !=
//                                                             "00:00:00" &&
//                                                         documents[currentIndex][
//                                                                 "U_lk_duration"] !=
//                                                             null
//                                                     ? formatCustomTimePlusMinutes(
//                                                         documents[currentIndex][
//                                                                 "U_lk_reqdeltim"] ??
//                                                             "00:00:00",
//                                                         int.parse(documents[
//                                                                     currentIndex]
//                                                                 [
//                                                                 "U_lk_duration"]
//                                                             .split(" ")[0]))
//                                                     : "N/A",
//                                                 style: const TextStyle(
//                                                     color: Colors.grey),
//                                               ),
//                                             ]
//                                           : [
//                                               const Text("Waiting",
//                                                   style: TextStyle(
//                                                       color: Colors.grey)),
//                                               const Text("Waiting",
//                                                   style: TextStyle(
//                                                       color: Colors.grey)),
//                                             ],
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             // Spacer(),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             // Accept & Reject Buttons
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: ElevatedButton(
//                                     onPressed: () =>
//                                         handleAction(context, "Open"),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.red,
//                                     ),
//                                     child: const Text("Reject",
//                                         style: TextStyle(color: Colors.white)),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: ElevatedButton(
//                                     onPressed: () =>
//                                         handleAction(context, "Started"),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.green,
//                                     ),
//                                     child: const Text(
//                                       "Accept",
//                                       style: TextStyle(color: Colors.white),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 4,
//                   ),
//                   Container(
//                     child: const Column(
//                       children: [
//                         Center(
//                           child: SpinKitFadingCircle(
//                             color: Colors.blue,
//                             size: 50.0,
//                           ),
//                         ),
//                         SizedBox(
//                           height: 7,
//                         ),
//                         Text(
//                           "Would you like to proceed with accepting or rejecting?",
//                           style:
//                               TextStyle(color: Colors.blueGrey, fontSize: 13),
//                         )
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//       ),
//     );
//   }
// }

// Future<void> _showConfirmationDialog({
//   required BuildContext context,
//   required String title,
//   required String content,
//   required VoidCallback onConfirm,
// }) async {
//   final result = await showDialog<bool>(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         title: Text(
//           title,
//           style: const TextStyle(fontSize: 22),
//         ),
//         content: Text(
//           content,
//           style: const TextStyle(fontSize: 14.5),
//         ),
//         actions: [
//           TextButton(
//             child: const Text("Cancel"),
//             onPressed: () => Navigator.of(context).pop(false),
//           ),
//           const SizedBox(
//             width: 5,
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(7),
//               ),
//               minimumSize: const Size(
//                   70, 35), // width, height (height smaller than default)
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 16), // optional: adjust padding
//             ),
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text("Go"),
//           ),
//         ],
//       );
//     },
//   );

//   if (result == true) {
//     onConfirm();
//   }
//   //   @override
//   // void dispose() {
//   //   stopLocationUpdates();
//   //   super.dispose();
//   // }
// }
