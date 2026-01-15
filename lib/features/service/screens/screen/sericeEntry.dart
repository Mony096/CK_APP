
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/screens/screen/image.dart';
import 'package:bizd_tech_service/features/service/screens/screen/materialReserve.dart';
import 'package:bizd_tech_service/features/service/screens/screen/openIssue.dart';
import 'package:bizd_tech_service/features/service/screens/screen/serviceCheckList.dart';
import 'package:bizd_tech_service/features/service/screens/screen/signature.dart';
import 'package:bizd_tech_service/features/service/screens/screen/time.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider_offline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ServiceEntryScreen extends StatefulWidget {
  const ServiceEntryScreen({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  __ServiceEntryScreenState createState() => __ServiceEntryScreenState();
}

class __ServiceEntryScreenState extends State<ServiceEntryScreen> {
  void onCompletedService() async {
    // final res =
    //     await Provider.of<CompletedServiceProvider>(context, listen: false)
    //         .onCompletedService(
    //             context: context,
    //             attachmentEntryExisting: widget.data["U_CK_AttachmentEntry"],
    //             docEntry: widget.data["DocEntry"]);
    // setState(() {
    //   print("asasa");
    // });
    final res =
        await Provider.of<CompletedServiceProvider>(context, listen: false)
            .onCompletedServiceOffline(
      context: context,
      attachmentEntryExisting: widget.data["U_CK_AttachmentEntry"],
      docEntry: widget.data["DocEntry"],
      startTime: widget.data["U_CK_Time"],
      endTime: widget.data["U_CK_EndTime"],
    );
    if (res) {
      Navigator.of(context).pop(true); // Return true to previous screen
    }
  }

  Future<void> clearOfflineDataWithLogout(BuildContext context) async {
    final offlineProviderService =
        Provider.of<ServiceListProviderOffline>(context, listen: false);
    final offlineProviderServiceCustomer =
        Provider.of<CustomerListProviderOffline>(context, listen: false);
    final offlineProviderServiceItem =
        Provider.of<ItemListProviderOffline>(context, listen: false);
    final offlineProviderEquipment =
        Provider.of<EquipmentOfflineProvider>(context, listen: false);
    final offlineProviderSite =
        Provider.of<SiteListProviderOffline>(context, listen: false);

    try {
      // Clear service data
      await offlineProviderService.clearDocuments();
      await offlineProviderServiceCustomer.clearDocuments();
      await offlineProviderServiceItem.clearDocuments();
      await offlineProviderEquipment.clearEquipments();
      await offlineProviderSite.clearDocuments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to clear data: $e")),
      );
    }
    // Show loading popup
  }

  void onBackScreen() {
    MaterialDialog.warningBackScreen(
      context,
      title: '',
      body: "Are you sure you want to go back without completing?",
      confirmLabel: "Yes",
      cancelLabel: "No",
      onConfirm: () {
        context.read<CompletedServiceProvider>().clearData();
        Navigator.of(context).pop(); // Close warning dialog first
      },

      onCancel: () {},
      icon: Icons.question_mark, // 👈 Pass the icon here
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          context.read<CompletedServiceProvider>().clearData();
          return true; // Allow navigation to pop
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 236, 238, 240),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 66, 83, 100),
            // Leading menu icon on the left
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                onBackScreen();
                // Handle menu button press or keep it empty for default Drawer action
              },
            ),
            // Centered title
            title: Center(
              child: Text(
                'Service Entry',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.042,
                    color: Colors.white),
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
                    icon:
                        const Icon(Icons.refresh_rounded, color: Colors.white),
                  ),
                  // SizedBox(width: 3),
                  IconButton(
                    onPressed: () async {
                      MaterialDialog.loading(context);
                      await clearOfflineDataWithLogout(context);
                      await Provider.of<AuthProvider>(context, listen: false)
                          .logout();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreenV2()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                  )
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      height: 80,
                      color: const Color.fromARGB(255, 66, 83, 100),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              width: 37,
                              height: 37,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 66, 83, 100),
                                shape: BoxShape
                                    .circle, // Makes the container circular
                                border: Border.all(
                                  color: widget.data["U_CK_Status"] ==
                                              "Accept" ||
                                          widget.data["U_CK_Status"] ==
                                              "Travel" ||
                                          widget.data["U_CK_Status"] ==
                                              "Service" ||
                                          widget.data["U_CK_Status"] == "Entry"
                                      ? Colors.green
                                      : Colors
                                          .white, // Optional: Add a border if needed
                                  width: 2.0, // Border width
                                ),
                              ),
                              child: Center(
                                  child: Icon(
                                Icons.check,
                                size: 20,
                                color: widget.data["U_CK_Status"] == "Accept" ||
                                        widget.data["U_CK_Status"] ==
                                            "Travel" ||
                                        widget.data["U_CK_Status"] ==
                                            "Service" ||
                                        widget.data["U_CK_Status"] == "Entry"
                                    ? Colors.green
                                    : Colors.white,
                              ))),
                          const Text("- - - - -",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                  color: Colors.white),
                              textScaleFactor: 1.0),
                          Container(
                              width: 37,
                              height: 37,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 66, 83, 100),
                                shape: BoxShape
                                    .circle, // Makes the container circular
                                border: Border.all(
                                  color: widget.data["U_CK_Status"] ==
                                              "Travel" ||
                                          widget.data["U_CK_Status"] ==
                                              "Service" ||
                                          widget.data["U_CK_Status"] == "Entry"
                                      ? Colors.green
                                      : Colors
                                          .white, // Optional: Add a border if needed
                                  width: 2.0, // Border width
                                ),
                              ),
                              child: Center(
                                  child: Icon(
                                Icons.car_crash,
                                color: widget.data["U_CK_Status"] == "Travel" ||
                                        widget.data["U_CK_Status"] ==
                                            "Service" ||
                                        widget.data["U_CK_Status"] == "Entry"
                                    ? Colors.green
                                    : Colors.white,
                              ))),
                          const Text("- - - - -",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                  color: Colors.white),
                              textScaleFactor: 1.0),
                          Container(
                              width: 37,
                              height: 37,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 66, 83, 100),
                                shape: BoxShape
                                    .circle, // Makes the container circular
                                border: Border.all(
                                  color: widget.data["U_CK_Status"] ==
                                              "Service" ||
                                          widget.data["U_CK_Status"] == "Entry"
                                      ? Colors.green
                                      : Colors
                                          .white, // Optional: Add a border if needed
                                  width: 2.0, // Border width
                                ),
                              ),
                              child: Center(
                                child: SvgPicture.asset('images/svg/key.svg',
                                    width: 23,
                                    height: 23,
                                    color: widget.data["U_CK_Status"] ==
                                                "Service" ||
                                            widget.data["U_CK_Status"] ==
                                                "Entry"
                                        ? Colors.green
                                        : Colors.white),
                              )),
                          const Text("- - - - -",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                  color: Colors.white),
                              textScaleFactor: 1.0),
                          Container(
                              width: 37,
                              height: 37,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 66, 83, 100),
                                shape: BoxShape
                                    .circle, // Makes the container circular
                                border: Border.all(
                                  color: widget.data["U_CK_Status"] == "Entry"
                                      ? Colors.green
                                      : Colors
                                          .white, // Optional: Add a border if needed
                                  width: 2.0, // Border width
                                ),
                              ),
                              child: Center(
                                  child: Icon(Icons.flag,
                                      color:
                                          widget.data["U_CK_Status"] == "Entry"
                                              ? Colors.green
                                              : Colors.white))),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                        // color: const Color.fromARGB(255, 255, 255, 255),

                        borderRadius:
                            BorderRadius.circular(5.0), // Rounded corners
                      ),
                      child: ListView(children: [
                        Container(
                          // margin: EdgeInsets.only(bottom: 1),
                          padding: const EdgeInsets.only(bottom: 6),
                          width: double.infinity,
                          // height: 250,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            border: Border.all(
                              color: Colors.green, // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius:
                                BorderRadius.circular(5.0), // Rounded corners
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 45,
                                                width:
                                                    45, // Ensure the width and height are equal for a perfect circle
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape
                                                      .circle, // Makes the container circular
                                                  border: Border.all(
                                                    color: const Color.fromARGB(
                                                        255,
                                                        79,
                                                        78,
                                                        78), // Optional: Add a border if needed
                                                    width: 1.0, // Border width
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SvgPicture.asset(
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
                                            padding: const EdgeInsets.fromLTRB(
                                                4, 10, 4, 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${widget.data["CustomerName"] ?? "N/A"}",
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.033),
                                                  textScaleFactor: 1.0,
                                                ),
                                                const SizedBox(
                                                  height: 6,
                                                ),
                                                Text(
                                                  ((widget.data["CustomerAddress"]
                                                                  as List?)
                                                              ?.isNotEmpty ==
                                                          true)
                                                      ? (widget
                                                              .data[
                                                                  "CustomerAddress"]
                                                              .first["StreetNo"] ??
                                                          "N/A")
                                                      : "N/A",
                                                  style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.032,
                                                    fontWeight: FontWeight.bold,
                                                    height: 2,
                                                  ),
                                                  textScaleFactor: 1.0,
                                                ),
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
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "No: ",
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.033),
                                                    textScaleFactor: 1.0,
                                                  ),
                                                  Text(
                                                    "${widget.data["DocNum"]}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.033),
                                                    textScaleFactor: 1.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ))
                                  ],
                                ),
                              ),
                              Container(
                                  // height: 150,
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 8),
                                  color: const Color.fromARGB(255, 66, 83, 100),
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 6),
                                              child: SvgPicture.asset(
                                                color: const Color.fromARGB(
                                                    255, 255, 255, 255),
                                                'images/svg/dolla.svg',
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              flex: 6,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: Text(
                                                        "Service:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.033),
                                                        textScaleFactor: 1.0,
                                                      )),
                                                      Expanded(
                                                          child: Text(
                                                        "Status:",
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.033,
                                                            color:
                                                                Colors.white),
                                                        textScaleFactor: 1.0,
                                                      )),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                          child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: (widget.data[
                                                                        "CK_JOB_SERVICESCollection"]
                                                                    as List)
                                                                .isEmpty
                                                            ? [
                                                                Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              8),
                                                                  child: Text(
                                                                    "No Services Available",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width *
                                                                                0.032),
                                                                  ),
                                                                )
                                                              ]
                                                            : (widget.data["CK_JOB_SERVICESCollection"]
                                                                            as List)
                                                                        .length >
                                                                    2
                                                                ? [
                                                                    ...(widget.data["CK_JOB_SERVICESCollection"]
                                                                            as List)
                                                                        .take(2)
                                                                        .map((e) =>
                                                                            Container(
                                                                              margin: const EdgeInsets.only(bottom: 8),
                                                                              child: Text(
                                                                                "${e["U_CK_ServiceName"]}",
                                                                                style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.031),
                                                                                textScaleFactor: 1.0,
                                                                              ),
                                                                            )),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          bottom:
                                                                              7),
                                                                      child:
                                                                          Text(
                                                                        "more...",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: MediaQuery.of(context).size.width * 0.031),
                                                                        textScaleFactor:
                                                                            1.0,
                                                                      ),
                                                                    ),
                                                                  ]
                                                                : (widget.data[
                                                                            "CK_JOB_SERVICESCollection"]
                                                                        as List)
                                                                    .map((e) =>
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              bottom: 8),
                                                                          child:
                                                                              Text(
                                                                            "${e["U_CK_ServiceName"]}",
                                                                            style:
                                                                                TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.032),
                                                                            textScaleFactor:
                                                                                1.0,
                                                                          ),
                                                                        ))
                                                                    .toList(),
                                                      )),
                                                      Expanded(
                                                          child: Text(
                                                        "Open",
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.033),
                                                        textScaleFactor: 1.0,
                                                      )),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ))
                                        ],
                                      ),
                                      ///////////////////////////
                                      Row(
                                        children: [
                                          const Expanded(
                                            flex: 1,
                                            child: Padding(
                                                padding:
                                                    EdgeInsets.only(right: 6),
                                                child: Icon(
                                                  Icons.build,
                                                  color: Colors.white,
                                                  size: 25,
                                                )),
                                          ),
                                          Expanded(
                                              flex: 6,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: Text(
                                                        "Equipment:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.033),
                                                        textScaleFactor: 1.0,
                                                      )),
                                                      Expanded(
                                                          child: Text("",
                                                              textAlign:
                                                                  TextAlign.end,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white))),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  (widget.data["CK_JOB_EQUIPMENTCollection"]
                                                              as List)
                                                          .isEmpty
                                                      ? Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 8),
                                                          child: Text(
                                                            "No Equipment Available",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.031),
                                                          ),
                                                        )
                                                      : Container(),
                                                  ...(widget.data[
                                                              "CK_JOB_EQUIPMENTCollection"]
                                                          as List)
                                                      .take(2)
                                                      .map(
                                                        (item) => Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 10),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  child: Text(
                                                                "${item["U_CK_EquipName"]}",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.031),
                                                                textScaleFactor:
                                                                    1.0,
                                                              )),
                                                              Expanded(
                                                                  child: Text(
                                                                "SN: ${item["U_CK_SerialNum"]}",
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.031,
                                                                    color: Colors
                                                                        .white),
                                                                textScaleFactor:
                                                                    1.0,
                                                              )),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                  (widget.data["CK_JOB_EQUIPMENTCollection"]
                                                                  as List)
                                                              .length >
                                                          2
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 7),
                                                          child: Text(
                                                            "more...",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.031),
                                                            textScaleFactor:
                                                                1.0,
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ))
                                        ],
                                      ),
                                      ///////////////////////////////////////////
                                    ],
                                  )),
                            ],
                          ),
                        ),
                        //////Enddddddddddddddddddddddddddddddddddddddddddddd
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            goTo(
                                context,
                                ServiceCheckListScreen(
                                  data: widget.data,
                                ));
                          },
                          child: Menu(
                            title: 'Checklist',
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SvgPicture.asset(
                                color: Colors.green,
                                'images/svg/activity.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            goTo(
                                context,
                                MaterialReserveScreen(
                                  data: widget.data,
                                ));
                          },
                          child: Menu(
                            title: 'Material Reserve',
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SvgPicture.asset(
                                color: Colors.green,
                                'images/svg/material.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            goTo(
                                context,
                                ImageScreen(
                                  data: widget.data,
                                ));
                          },
                          child: Menu(
                            title: 'Image',
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SvgPicture.asset(
                                color: Colors.green,
                                'images/svg/image.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            goTo(context, TimeScreen(data: widget.data));
                          },
                          child: Menu(
                            title: 'Time Entry',
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SvgPicture.asset(
                                color: Colors.green,
                                'images/svg/clock.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            goTo(context, SignatureScreen(data: widget.data));
                          },
                          child: Menu(
                            title: 'Signature',
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SvgPicture.asset(
                                color: Colors.green,
                                'images/svg/signature.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            goTo(context, OpenIssueScreen(data: widget.data));
                          },
                          child: Menu(
                            title: 'Open Issue',
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SvgPicture.asset(
                                color: Colors.green,
                                'images/svg/report.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        /////do somthing
                        const SizedBox(
                          height: 7,
                        ),
                      ]),
                    )),
                  ],
                )),
          ),
          bottomNavigationBar: Container(
            color: const Color.fromARGB(255, 255, 255, 255),
            height: 105,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 30),
            child: Row(
              children: [
                Expanded(flex: 2, child: Container()),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // print("asas");
                      onCompletedService();
                      // Define your button's action here
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: const Text(
                      "Complete",
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ));
  }
}

class Menu extends StatefulWidget {
  const Menu({super.key, this.icon, required this.title});
  final dynamic icon;
  final String title;
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(flex: 1, child: widget.icon),
          Expanded(
              flex: 6,
              child: Text(
                widget.title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.032),
                textScaleFactor: 1.0,
              )),
          const Expanded(
              flex: 1,
              child: Icon(
                Icons.keyboard_arrow_right,
                size: 30,
              )),
        ],
      ),
    );
  }
}
