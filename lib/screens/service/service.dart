import 'dart:async';
import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/service_list_provider.dart';
import 'package:bizd_tech_service/provider/service_provider.dart';
import 'package:bizd_tech_service/screens/service/serviceById.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});
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

    final svProvider = Provider.of<ServiceListProvider>(context, listen: false);
    if (svProvider.documents.isEmpty) {
      await svProvider.fetchDocuments();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUserName() async {
    final name = await getName();
    setState(() {
      userName = name;
    });
  }

  Future<String?> getName() async {
    return await LocalStorageManger.getString('UserName');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceListProvider>(
      builder: (context, deliveryProvider, _) {
        final documents = deliveryProvider.documents;
        final isLoading = deliveryProvider.isLoading;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 66, 83, 100),
            // Leading menu icon on the left
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
                // Handle menu button press or keep it empty for default Drawer action
              },
            ),
            // Centered title
            title: Center(
              child: Text(
                "$userName' Service",
                style: TextStyle(fontSize: 17, color: Colors.white),
                textScaleFactor: 1.0,
              ),
            ),
            // Right-aligned actions (scan barcode)
            actions: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // refresh();
                    },
                    icon: Icon(Icons.refresh_rounded, color: Colors.white),
                  ),
                  // SizedBox(width: 3),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.logout, color: Colors.white),
                  )
                ],
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TextFormField(

              //   controller: null,
              //   decoration: InputDecoration(
              //     enabledBorder: OutlineInputBorder(
              //       borderSide: const BorderSide(
              //         color: Colors.grey,
              //         width: 1.0, // Border color and width when not focused
              //       ),
              //       borderRadius: BorderRadius.circular(5.0), // Rounded corners
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderSide: BorderSide(
              //         color: const Color.fromARGB(255, 123, 125, 126),
              //         width: 1.0, // Border color and width when focused
              //       ),
              //       borderRadius: BorderRadius.circular(5.0), // Rounded corners
              //     ),
              //     contentPadding: const EdgeInsets.only(top: 12),
              //     hintText: 'Search...', // Placeholder text
              //     hintStyle: TextStyle(
              //       fontSize: 14.0, // Placeholder font size
              //       color: Colors.grey,
              //       // Placeholder text color
              //     ),
              //     prefixIcon: Icon(Icons.search),
              //     suffixIcon: IconButton(
              //       icon: Icon(
              //         Icons.list,
              //       ),
              //       onPressed: null,
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 10,
              ),
              DateSelector(),
              // SizedBox(
              //   height: 7,
              // ),
              // // CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 5),
                  child: isLoading || _isLoading
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          child: const Center(
                            child: SpinKitFadingCircle(
                              color: Colors.green,
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
                              SizedBox(
                                height: 5,
                              ),
                              ...documents.map(
                                (travel) => Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  width: double.infinity,
                                  height: 370,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromARGB(
                                                255, 133, 136, 138)
                                            .withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 2,
                                        offset: const Offset(1, 1),
                                      )
                                    ],
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    border: Border.all(
                                      color: Colors.green, // Border color
                                      width: 1.0, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Rounded corners
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
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
                                                            color: Colors
                                                                .green, /////////Icon Right
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
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  255,
                                                                  255,
                                                                  255),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                              Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          4, 10, 4, 10),
                                                      child: const Column(
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
                                              const Expanded(
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
                                                            EdgeInsets.only(
                                                                right: 10),
                                                        child: Text(
                                                            "SVT00001 #",
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
                                          padding: const EdgeInsets.all(10),
                                          color: const Color.fromARGB(
                                              255, 66, 83, 100),
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
                                                                      66,
                                                                      83,
                                                                      100),
                                                              shape: BoxShape
                                                                  .circle, // Makes the container circular
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .green, // Optional: Add a border if needed
                                                                width:
                                                                    2.0, // Border width
                                                              ),
                                                            ),
                                                            child: const Center(
                                                                child: Icon(
                                                              Icons.check,
                                                              size: 20,
                                                              color:
                                                                  Colors.green,
                                                            ))),
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
                                                                      66,
                                                                      83,
                                                                      100),
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
                                                            child: const Center(
                                                                child: Icon(
                                                              Icons.car_crash,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      255),
                                                            ))),
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
                                                                      66,
                                                                      83,
                                                                      100),
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
                                                              child: SvgPicture.asset(
                                                                  'images/svg/key.svg',
                                                                  width: 23,
                                                                  height: 23,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255)),
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
                                                                      66,
                                                                      83,
                                                                      100),
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
                                                            child: const Center(
                                                                child: Icon(
                                                                    Icons.flag,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255)))),
                                                      ],
                                                    ),
                                                  )),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    child: const Text(
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
                                                      child: const Text(
                                                          "Repair",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12),
                                                          textScaleFactor: 1.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
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
                                                      child: const Icon(
                                                        Icons.keyboard_arrow_up,
                                                        color: Colors.green,
                                                        size: 30,
                                                      ),
                                                    ),
                                                  ))),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: Row(
                                                    children: [
                                                      const Expanded(
                                                          flex: 1,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10.0),
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  height: 45,
                                                                  width:
                                                                      45, // Ensure the width and height are equal for a perfect circle

                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
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
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      4,
                                                                      10,
                                                                      4,
                                                                      10),
                                                              child:
                                                                  const Column(
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
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Container(
                                                                width: 100,
                                                                height: 35,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .green,
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
                                                                          const Duration(
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
                                                                  child: const Text(
                                                                      "Accept",
                                                                      style: TextStyle(
                                                                          color: Color.fromARGB(
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
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                            ],
                                                          )),
                                                      const SizedBox(
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

class DateSelector extends StatefulWidget {
  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime _selectedDate = DateTime.now(); // Default to the current date

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the date to "Monday, January 15"
    final formattedDate = DateFormat('EEEE, MMMM d').format(_selectedDate);

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        border: Border.all(
          color: Colors.green, // Border color
          width: 1.0, // Border width
        ),
        borderRadius: BorderRadius.circular(5.0), // Rounded corners
      ),
      width: double.infinity,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: Icon(Icons.date_range)),
          Expanded(
            flex: 4,
            child: Text(
              formattedDate, // Display formatted date
              style: TextStyle(fontSize: 13),
              textScaleFactor: 1.0,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    size: 30,
                    color: Color.fromARGB(255, 88, 89, 90),
                  ),
                  onPressed: () => _selectDate(context),
                ),
                SizedBox(width: 3),
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_right,
                    size: 30,
                    color: Color.fromARGB(255, 88, 89, 90),
                  ),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
