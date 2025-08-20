import 'dart:async';
import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/service_provider.dart';
import 'package:bizd_tech_service/provider/helper_provider.dart';
import 'package:bizd_tech_service/provider/update_status_provider.dart';
import 'package:bizd_tech_service/screens/service/serviceById.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceScreen extends StatefulWidget {
  ServiceScreen({super.key});
  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final DioClient dio = DioClient(); // Your custom Dio client

  bool _isLoading = false;
  List<dynamic> documents = [];
  List<dynamic> warehouses = [];
  List<dynamic> customers = [];
  String? userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init(); // this safely runs after first build
    });
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    await _loadUserName();
    final dnProvider =
        Provider.of<DeliveryNoteProvider>(context, listen: false);
    if (dnProvider.documents.isEmpty) {
      await dnProvider.fetchDocuments();
    }

    final whProvider = Provider.of<HelperProvider>(context, listen: false);
    if (whProvider.warehouses.isEmpty) {
      await whProvider.fetchWarehouse();
    }

    final customerProvider =
        Provider.of<HelperProvider>(context, listen: false);
    if (customerProvider.customer.isEmpty) {
      await customerProvider.fetchCustomer();
    }

    if (!mounted) return;
    setState(() {
      warehouses = whProvider.warehouses;
      customers = customerProvider.customer;

      _isLoading = false;
    });
  }

  Future<void> _loadUserName() async {
    final name = await getName();
    setState(() {
      userName = name;
    });
  }

  void makePhoneCall(BuildContext context, String phoneNumber) {
    _showConfirmationDialog(
      context: context,
      title: "Call $phoneNumber ?",
      content: "Are you want to call this number ?",
      onConfirm: () async {
        final Uri phoneUri = Uri.parse("tel:$phoneNumber");

        try {
          await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Cannot make phone call on this device')),
          );
        }
      },
    );
  }

  void onCompletedSkip(dynamic entry, List<dynamic> documents) async {
    MaterialDialog.loading(context); // Show loading dialog
    await Provider.of<UpdateStatusProvider>(context, listen: false)
        .updateDocumentAndStatus(
            docEntry: entry,
            status: "Delivered",
            remarks: "",
            context: context);
    await Future.microtask(() {
      final provider =
          Provider.of<DeliveryNoteProvider>(context, listen: false);
      provider.fetchDocuments();
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void onFailedDelivery(dynamic entry, List<dynamic> documents) async {
    MaterialDialog.loading(context); // Show loading dialog
    await Provider.of<UpdateStatusProvider>(context, listen: false)
        .updateDocumentAndStatus(
            docEntry: entry, status: "Failed", remarks: "", context: context);
    await Future.microtask(() {
      final provider =
          Provider.of<DeliveryNoteProvider>(context, listen: false);
      provider.fetchDocuments();
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<String?> getName() async {
    return await LocalStorageManger.getString('UserName');
  }

  dynamic numa = 0;
  void showPODDialog(BuildContext context, dynamic entry, dynamic doc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(255, 184, 186, 192),
                  width: 1.0,
                ),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.pin_drop,
                  size: 20,
                  color: Color.fromARGB(255, 81, 81, 84),
                ),
                SizedBox(
                  width: 7,
                ),
                Text(
                  'Proof of Delivery (POD)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color.fromARGB(255, 81, 81, 84)),
                ),
              ],
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () async {
                    // Get the provider BEFORE popping the context
                    final dnProvider = Provider.of<DeliveryNoteProvider>(
                        context,
                        listen: false);
                    Navigator.pop(context); // Dismiss the dialog
                    // await goTo(
                    //     context,
                    //     ProofOfServiceScreen(
                    //         entry: entry, documents: documents));
                    await dnProvider.fetchDocuments();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                    backgroundColor: const Color.fromARGB(255, 78, 178, 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Take Proof of Delivery",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    onFailedDelivery(entry, documents);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Failed Delivery",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: OutlinedButton(
                      onPressed: () {
                        onCompletedSkip(entry, documents);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 37), // ⬅️ height = 35
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Skip POD",
                        style: TextStyle(
                          color: Color.fromARGB(255, 82, 84, 85),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close dialog
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Close",
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryNoteProvider>(
      builder: (context, deliveryProvider, _) {
        final documents = deliveryProvider.documents;
        final isLoading = deliveryProvider.isLoading;

        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER (not scrollable)
              Container(
                height: 180,
                color: const Color.fromARGB(255, 33, 107, 243),
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 55,
                      left: 20,
                      right: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 25,
                                  )),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "${userName ?? 'Loading'}'s Delivery",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  Future.microtask(() {
                                    final provider =
                                        Provider.of<DeliveryNoteProvider>(
                                            context,
                                            listen: false);
                                    provider.fetchDocuments();
                                  });
                                },
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 27,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  MaterialDialog.loading(context);
                                  await Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .logout();
                                  Navigator.of(context).pop(); // Close loading
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (_) => const LoginScreen()),
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(
                                  Icons.logout,
                                  size: 27,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: 115,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 238, 239, 241),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.note_alt,
                                      size: 20,
                                      color: Color.fromARGB(255, 85, 73, 73)),
                                  SizedBox(width: 10),
                                  Text(
                                    "Your List of Assigned Service",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 85, 73, 73),
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_downward,
                                  size: 21,
                                  color: Color.fromARGB(255, 78, 64, 64)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 5),
                  child: isLoading || _isLoading
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          child: const Center(
                            child: SpinKitFadingCircle(
                              color: Colors.blue,
                              size: 50.0,
                            ),
                          ),
                        )
                      : documents.isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(
                                child: Text(
                                  "No Deliveries Available",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            )
                          : Column(children: [
                              ...documents.map(
                                (travel) => Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  width: double.infinity,
                                  height: 370,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    border: Border.all(
                                      color: Color.fromARGB(
                                          255, 33, 107, 243), // Border color
                                      width: 1.0, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Rounded corners
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: double.infinity,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: 45,
                                                          width:
                                                              45, // Ensure the width and height are equal for a perfect circle
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                33, 107, 243),
                                                            shape: BoxShape
                                                                .circle, // Makes the container circular
                                                            border: Border.all(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  79,
                                                                  78,
                                                                  78), // Optional: Add a border if needed
                                                              width:
                                                                  1.0, // Border width
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: SvgPicture
                                                                .asset(
                                                              'images/svg/key.svg',
                                                              width: 30,
                                                              height: 30,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                              Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              4, 10, 4, 10),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              "The Pizza Comapny - Sen Sok",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.5),
                                                              textScaleFactor:
                                                                  1.0),
                                                          SizedBox(
                                                            height: 6,
                                                          ),
                                                          Text(
                                                              "#23, Street 598 -Khan Sen Sok Phnom Penh, Cambodia",
                                                              style: TextStyle(
                                                                fontSize: 12.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                height: 2,
                                                              ),
                                                              textScaleFactor:
                                                                  1.0),
                                                        ],
                                                      ))),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 10),
                                                        child: Text("SVT00001",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13),
                                                            textScaleFactor:
                                                                1.0),
                                                      ),
                                                    ],
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          color:
                                              Color.fromARGB(255, 33, 107, 243),
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                            width: 37,
                                                            height: 37,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      33,
                                                                      107,
                                                                      243),
                                                              shape: BoxShape
                                                                  .circle, // Makes the container circular
                                                              border:
                                                                  Border.all(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255), // Optional: Add a border if needed
                                                                width:
                                                                    2.0, // Border width
                                                              ),
                                                            ),
                                                            child: Center(
                                                                child: Icon(
                                                              Icons.check,
                                                              size: 20,
                                                              color:
                                                                  Colors.white,
                                                            ))),
                                                        Text("- - - - -",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                fontSize: 13.5,
                                                                color: Colors
                                                                    .white),
                                                            textScaleFactor:
                                                                1.0),
                                                        Container(
                                                            width: 37,
                                                            height: 37,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      33,
                                                                      107,
                                                                      243),
                                                              shape: BoxShape
                                                                  .circle, // Makes the container circular
                                                              border:
                                                                  Border.all(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255), // Optional: Add a border if needed
                                                                width:
                                                                    2.0, // Border width
                                                              ),
                                                            ),
                                                            child: Center(
                                                                child: Icon(
                                                              Icons.car_crash,
                                                              color:
                                                                  Colors.white,
                                                            ))),
                                                        Text("- - - - -",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                fontSize: 13.5,
                                                                color: Colors
                                                                    .white),
                                                            textScaleFactor:
                                                                1.0),
                                                        Container(
                                                            width: 37,
                                                            height: 37,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      33,
                                                                      107,
                                                                      243),
                                                              shape: BoxShape
                                                                  .circle, // Makes the container circular
                                                              border:
                                                                  Border.all(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255), // Optional: Add a border if needed
                                                                width:
                                                                    2.0, // Border width
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: SvgPicture
                                                                  .asset(
                                                                'images/svg/key.svg',
                                                                width: 23,
                                                                height: 23,
                                                              ),
                                                            )),
                                                        const Text("- - - - -",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                fontSize: 13.5,
                                                                color: Colors
                                                                    .white),
                                                            textScaleFactor:
                                                                1.0),
                                                        Container(
                                                            width: 37,
                                                            height: 37,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      33,
                                                                      107,
                                                                      243),
                                                              shape: BoxShape
                                                                  .circle, // Makes the container circular
                                                              border:
                                                                  Border.all(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255), // Optional: Add a border if needed
                                                                width:
                                                                    2.0, // Border width
                                                              ),
                                                            ),
                                                            child: Center(
                                                                child: Icon(
                                                              Icons.flag,
                                                              color:
                                                                  Colors.white,
                                                            ))),
                                                      ],
                                                    ),
                                                  )),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    child: Text(
                                                        "Time 04:30 - 06:30",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 13),
                                                        textScaleFactor: 1.0),
                                                  )),
                                              Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 0, 0),
                                                  child: Container(
                                                    width: 100,
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                      color: Colors.yellow,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        // Define your button's action here
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                        ),
                                                      ),
                                                      child: Text("Repair",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12),
                                                          textScaleFactor: 1.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                      child: Center(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        goTo(context,
                                                            ServiceByIdScreen());
                                                      },
                                                      child: Icon(
                                                        Icons.keyboard_arrow_up,
                                                        color: Color.fromARGB(
                                                            255, 33, 107, 243),
                                                        size: 30,
                                                      ),
                                                    ),
                                                  ))),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  width: double.infinity,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 1,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10.0),
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  height: 45,
                                                                  width:
                                                                      45, // Ensure the width and height are equal for a perfect circle

                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Icon(
                                                                      Icons
                                                                          .build,
                                                                      size: 25,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )),
                                                      Expanded(
                                                          flex: 4,
                                                          child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          4,
                                                                          10,
                                                                          4,
                                                                          10),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      "The Pizza Comapny - Sen Sok",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12.5),
                                                                      textScaleFactor:
                                                                          1.0),
                                                                  SizedBox(
                                                                    height: 6,
                                                                  ),
                                                                  Text(
                                                                      "SN: 10003000400",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12.5,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        height:
                                                                            2,
                                                                      ),
                                                                      textScaleFactor:
                                                                          1.0),
                                                                ],
                                                              ))),
                                                      Expanded(
                                                          flex: 2,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Container(
                                                                width: 100,
                                                                height: 35,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          33,
                                                                          107,
                                                                          243),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                ),
                                                                child:
                                                                    TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    if (travel[
                                                                            "isActive"] !=
                                                                        true) {
                                                                      MaterialDialog
                                                                          .loading(
                                                                              context);
                                                                      Future.delayed(
                                                                          Duration(
                                                                              seconds: 1),
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        // goTo(
                                                                        //     context,
                                                                        //     AcceptedScreen());
                                                                      });
                                                                    }
                                                                  },
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                      "Accept",
                                                                      style: TextStyle(
                                                                          color: const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              255,
                                                                              255,
                                                                              255),
                                                                          fontSize:
                                                                              12),
                                                                      textScaleFactor:
                                                                          1.0),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                            ],
                                                          )),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ), ////
                                              ),
                                            ],
                                          ),
                                        ), /////
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 22),
        ),
        content: Text(
          content,
          style: const TextStyle(fontSize: 14.5),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          const SizedBox(
            width: 5,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              minimumSize: const Size(
                  70, 35), // width, height (height smaller than default)
              padding: const EdgeInsets.symmetric(
                  horizontal: 16), // optional: adjust padding
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Go"),
          ),
        ],
      );
    },
  );

  if (result == true) {
    onConfirm();
  }
}
