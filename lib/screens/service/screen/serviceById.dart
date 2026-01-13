import 'dart:math';

import 'package:bizd_tech_service/component/title_break.dart';
import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/screens/auth/login_screen_v2.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/provider/helper_provider.dart';
import 'package:bizd_tech_service/provider/service_list_provider.dart';
import 'package:bizd_tech_service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/provider/update_status_provider.dart';
import 'package:bizd_tech_service/screens/service/component/detail_row.dart';
import 'package:bizd_tech_service/screens/service/component/row_item.dart';
import 'package:bizd_tech_service/screens/service/screen/sericeEntry.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceByIdScreen extends StatefulWidget {
  const ServiceByIdScreen({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  __ServiceByIdScreenState createState() => __ServiceByIdScreenState();
}

class __ServiceByIdScreenState extends State<ServiceByIdScreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _onReject() async {
    // if (_pdf.isEmpty) {
    // print(currentStatus);
    // return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please provide a signature')),
    //   );
    //   return;
    // }
    try {
      // await Provider.of<UpdateStatusProvider>(context, listen: false)
      //     .updateDocumentAndStatus(
      //   docEntry: widget.data["DocEntry"],
      //   status: "Open",
      //   context: context, // ✅ Corrected here
      // );
      // if (!mounted) return; // <--- Add this check

      // Navigator.of(context).pop(); // Go back
      // Navigator.of(context).pop(); // Go back

      // await _refreshData();

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Update Status Successfully')),
      // );
      MaterialDialog.loading(context);
      await Future.delayed(const Duration(seconds: 1));

      await Provider.of<ServiceListProviderOffline>(context, listen: false)
          .updateDocumentAndStatusOffline(
        docEntry: widget.data["DocEntry"],
        status: "Open",
        context: context,
      );
      final provider = context.read<ServiceListProviderOffline>();
      provider.refreshDocuments(); // clear filter + reload all
      MaterialDialog.close(context);
      MaterialDialog.close(context);
    } catch (e) {
      Navigator.of(context).pop(); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
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

  Future<void> _refreshData() async {
    // setState(() => _initialLoading = true);

    // final provider = Provider.of<ServiceListProvider>(context, listen: false);
    // // ✅ Only fetch if not already loaded
    // provider.resetPagination();
    // await provider.resfreshFetchDocuments(context);
    // setState(() => _initialLoading = false);
    final provider = context.read<ServiceListProviderOffline>();
    provider.refreshDocuments(); // clear filter + reload all
  }

  Future<void> onUpdateStatus() async {
    if (widget.data["U_CK_Status"] == "Service") {
      goTo(context, ServiceEntryScreen(data: widget.data));
      return;
    }

    try {
      // await Provider.of<UpdateStatusProvider>(context, listen: false)
      //     .updateDocumentAndStatus(
      //   docEntry: widget.data["DocEntry"],
      //   status: widget.data["U_CK_Status"] == "Pending"
      //       ? "Accept"
      //       : widget.data["U_CK_Status"] == "Accept"
      //           ? "Travel"
      //           : widget.data["U_CK_Status"] == "Travel"
      //               ? "Service"
      //               : "Entry",
      //   context: context, // ✅ Corrected here
      // );
      // if (!mounted) return; // <--- Add this check

      // Navigator.of(context).pop(); // Go back
      // Navigator.of(context).pop(); // Go back
      // await _refreshData();

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Update Status Successfully')),
      // );
      // ⏳ Wait 1 seconds before updating
      MaterialDialog.loading(context);
      await Future.delayed(const Duration(seconds: 1));

      await Provider.of<ServiceListProviderOffline>(context, listen: false)
          .updateDocumentAndStatusOffline(
        docEntry: widget.data["DocEntry"],
        status: widget.data["U_CK_Status"] == "Pending"
            ? "Accept"
            : widget.data["U_CK_Status"] == "Accept"
                ? "Travel"
                : widget.data["U_CK_Status"] == "Travel"
                    ? "Service"
                    : "Entry",
        context: context,
      );
      final provider = context.read<ServiceListProviderOffline>();
      provider.refreshDocuments(); // clear filter + reload all
      MaterialDialog.close(context);
      MaterialDialog.close(context);
    } catch (e) {
      Navigator.of(context).pop(); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  Future<void> _loadUserName() async {
    final name = await getName();
    setState(() {
      userName = name;
    });
  }

  Future<String?> getName() async {
    return await LocalStorageManger.getString('FullName');
  }

  final numberFormatCurrency = NumberFormat("#,##0.00", "en_US");
  final numberQty = NumberFormat("#,##0", "en_US");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 83, 100),
        // Leading menu icon on the left
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
            // Handle menu button press or keep it empty for default Drawer action
          },
        ),
        // Centered title
        title: Center(
          child: Text('Service Infomation',
              style: TextStyle(fontSize:  MediaQuery.of(context).size.width * 0.042, color: Colors.white),
              textScaleFactor: 1.0),
        ),
        // Right-aligned actions (scan barcode)
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _refreshData();
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
              // SizedBox(width: 3),
              // IconButton(
              //   onPressed: () async {
              //     MaterialDialog.loading(context);
              //     await Provider.of<AuthProvider>(context, listen: false)
              //         .logout();
              //     Navigator.of(context).pop();
              //     Navigator.of(context).pushAndRemoveUntil(
              //       MaterialPageRoute(builder: (_) => const LoginScreenV2()),
              //       (route) => false,
              //     );
              //   },
              //   icon: const Icon(Icons.logout, color: Colors.white),
              // )
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
                            shape:
                                BoxShape.circle, // Makes the container circular
                            border: Border.all(
                              color: widget.data["U_CK_Status"] == "Accept" ||
                                      widget.data["U_CK_Status"] == "Travel" ||
                                      widget.data["U_CK_Status"] == "Service" ||
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
                                    widget.data["U_CK_Status"] == "Travel" ||
                                    widget.data["U_CK_Status"] == "Service" ||
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
                            shape:
                                BoxShape.circle, // Makes the container circular
                            border: Border.all(
                              color: widget.data["U_CK_Status"] == "Travel" ||
                                      widget.data["U_CK_Status"] == "Service" ||
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
                                    widget.data["U_CK_Status"] == "Service" ||
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
                            shape:
                                BoxShape.circle, // Makes the container circular
                            border: Border.all(
                              color: widget.data["U_CK_Status"] == "Service" ||
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
                                        widget.data["U_CK_Status"] == "Entry"
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
                            shape:
                                BoxShape.circle, // Makes the container circular
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
                                  color: widget.data["U_CK_Status"] == "Entry"
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
                    color: const Color.fromARGB(255, 255, 255, 255),
                    border: Border.all(
                      color: Colors.green, // Border color
                      width: 1.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(5.0), // Rounded corners
                  ),
                  child: ListView(children: [
                    SizedBox(
                      // margin: EdgeInsets.only(bottom: 1),
                      width: double.infinity,
                      height: 240,
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
                                                widget.data["CustomerName"] ??
                                                    "N/A", //////aaaaaaaaaaaaa
                                                style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.033),
                                                textScaleFactor: 1.0),
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
                                                textScaleFactor: 1.0),
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
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                "No: ",
                                                style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.033),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                "${widget.data["DocNum"]}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
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
                            height: 130,
                            padding: const EdgeInsets.all(10),
                            color: const Color.fromARGB(255, 66, 83, 100),
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.date_range,
                                                    size: 19,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                      "${showDateOnService(widget.data["U_CK_Date"]?.split("T")[0] ?? "")} ",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.031),
                                                      textScaleFactor: 1.0),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.timer,
                                                    size: 19,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                      "${widget.data["U_CK_Time"] ?? "No Time"} - ${widget.data["U_CK_EndTime"] ?? "No Time"}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.031),
                                                      textScaleFactor: 1.0),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 3),
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
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                  ),
                                                  child: Text(
                                                      "${widget.data["U_CK_JobType"] ?? "N/A"}",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.030),
                                                      textScaleFactor: 1.0),
                                                ),
                                              ),
                                            ],
                                          )),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              userName ?? "...",
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.031,
                                                color: Colors.white,
                                              ),
                                              textScaleFactor: 1.0,
                                              overflow: TextOverflow
                                                  .ellipsis, // ⬅️ important
                                              maxLines:
                                                  1, // ⬅️ keep it one line
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Center(
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.green,
                            size: 35,
                          ),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Row(
                        children: [
                          // Left line
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),

                          // Center text
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "${widget.data["CustomerName"] ?? "N/A"}s' Information",
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.034,
                                // fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(221, 85, 81, 81),
                              ),
                            ),
                          ),

                          // Right line
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),
                    DetailRow(
                      title: "Contact:",
                      svg: SvgPicture.asset(
                        color: Colors.green,
                        'images/svg/contact.svg',
                        width: 30,
                        height: 30,
                      ),
                      rows: (widget.data["CustomerContact"] as List).isEmpty
                          ? [
                              RowItem(
                                left: "No Contact Available",
                                right: "",
                              ),
                            ]
                          : (widget.data["CustomerContact"] as List)
                              .expand<RowItem>((e) => [
                                    RowItem(
                                      left: e["Name"] ?? "N/A",
                                      right: "",
                                    ),
                                    RowItem(
                                      left: e["MobilePhone"] ?? "N/A",
                                      right: GestureDetector(
                                        onTap: () => makePhoneCall(
                                            context, e["MobilePhone"]),
                                        child: const Icon(
                                          Icons.phone,
                                          size: 20,
                                          color: Colors.green,
                                        ),
                                      ),
                                      isRightIcon: true,
                                    ),
                                  ])
                              .toList(),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    DetailRow(
                      title: "Service:",
                      svg: SvgPicture.asset(
                        color: Colors.green,
                        'images/svg/dolla.svg',
                        width: 30,
                        height: 30,
                      ),
                      rows: (widget.data["CK_JOB_SERVICESCollection"] as List)
                              .isEmpty
                          ? [
                              RowItem(
                                left: "No Service Available",
                                right: "",
                              ),
                            ]
                          : (widget.data["CK_JOB_SERVICESCollection"] as List)
                              .expand<RowItem>((e) => [
                                    RowItem(
                                      left: e["U_CK_ServiceName"] ?? "N/A",
                                      right: 'USD ${numberFormatCurrency.format(
                                        double.tryParse(e["U_CK_UnitPrice"]
                                                .toString()) ??
                                            0,
                                      )} ',
                                    ),
                                  ])
                              .toList(),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    DetailRow(
                      title: "Equipment:",
                      svg: const Icon(
                        Icons.build,
                        size: 25,
                        color: Colors.green,
                      ),
                      rows: (widget.data["CK_JOB_EQUIPMENTCollection"] as List)
                              .isEmpty
                          ? [
                              RowItem(
                                left: "No Equipment Available",
                                right: "",
                              ),
                            ]
                          : (widget.data["CK_JOB_EQUIPMENTCollection"] as List)
                              .expand<RowItem>((e) => [
                                    RowItem(
                                      left: e["U_CK_EquipName"] ?? "N/A",
                                      right:
                                          'SN: ${e["U_CK_SerialNum"] ?? "N/A"}',
                                    ),
                                  ])
                              .toList(),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    DetailRow(
                        title: "Activity:",
                        svg: SvgPicture.asset(
                          color: Colors.green,
                          'images/svg/activity.svg',
                          width: 30,
                          height: 30,
                        ),
                        rows: (widget.data["activityLine"] as List).isEmpty
                            ? [
                                RowItem(
                                  left: "No Activity Available",
                                  right: "",
                                ),
                              ]
                            : (widget.data["activityLine"] as List)
                                .expand<RowItem>((e) => [
                                      RowItem(
                                          left: "${e["Activity"] ?? "N/A"}",
                                          right: SvgPicture.asset(
                                            color: Colors.green,
                                            'images/svg/task_check.svg',
                                            width: 25,
                                            height: 25,
                                          ),
                                          isRightIcon: true),
                                    ])
                                .toList()
                        //  [
                        //     RowItem(
                        //         left: "Activity Name1",
                        //         right: SvgPicture.asset(
                        //           color: Colors.green,
                        //           'images/svg/task_check.svg',
                        //           width: 25,
                        //           height: 25,
                        //         ),
                        //         isRightIcon: true),
                        //     RowItem(
                        //         left: "Activity Name2",
                        //         right: SvgPicture.asset(
                        //           color: Colors.black,
                        //           'images/svg/task_check.svg',
                        //           width: 25,
                        //           height: 25,
                        //         ),
                        //         isRightIcon: true),
                        //     RowItem(
                        //         left: "Activity Name3",
                        //         right: SvgPicture.asset(
                        //           color: Colors.black,
                        //           'images/svg/task_check.svg',
                        //           width: 25,
                        //           height: 25,
                        //         ),
                        //         isRightIcon: true),
                        //   ],
                        ),
                    const SizedBox(
                      height: 15,
                    ),
                    DetailRow(
                      title: "Material Reserve:",
                      svg: SvgPicture.asset(
                        color: Colors.green,
                        'images/svg/material.svg',
                        width: 30,
                        height: 30,
                      ),
                      rows: (widget.data["CK_JOB_MATERIALCollection"] as List)
                              .isEmpty
                          ? [
                              RowItem(
                                left: "No Material Available",
                                right: "",
                              ),
                            ]
                          : (widget.data["CK_JOB_MATERIALCollection"] as List)
                              .expand<RowItem>((e) => [
                                    RowItem(
                                      left: e["U_CK_ItemName"] ?? "N/A",
                                      right: '${numberQty.format(
                                        double.tryParse(
                                                e["U_CK_Qty"].toString()) ??
                                            0,
                                      )} ',
                                    ),
                                  ])
                              .toList(),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    DetailRow(
                      title: "Tool & Assets:",
                      svg: SvgPicture.asset(
                        color: Colors.green,
                        'images/svg/tool.svg',
                        width: 30,
                        height: 30,
                      ),
                      rows: [{}].isEmpty
                          ? [
                              RowItem(
                                left: "Tool & Assets Available",
                                right: "",
                              ),
                            ]
                          : [
                              RowItem(
                                left: "Tools Item 1",
                                right: "10",
                              ),
                              RowItem(
                                left: "Tools Item 2",
                                right: "20",
                              ),
                              RowItem(
                                left: "Tools Item 3",
                                right: "30",
                              ),
                            ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),
                    const Row(
                      children: [
                        SizedBox(
                          width: 27,
                        ),
                        Icon(
                          Icons.warning_rounded,
                          size: 30,
                          color: Color.fromARGB(255, 215, 197, 29),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 10, 5, 10),
                      child: Text("Service task remark for technician",
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.033),
                          textScaleFactor: 1.0),
                    ),
                    Container(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      height: 70,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Container()),
                          Expanded(
                            child: widget.data["U_CK_Status"] == "Pending"
                                ? TextButton(
                                    onPressed: () {
                                      _onReject();
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    child: Text("Reject",
                                        style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255),
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.031),
                                        textScaleFactor: 1.0),
                                  )
                                : Container(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                onUpdateStatus();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    widget.data["U_CK_Status"] == "Accept"
                                        ? Colors.yellow
                                        : Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: Text(
                                  widget.data["U_CK_Status"] == "Pending"
                                      ? "Accept"
                                      : widget.data["U_CK_Status"] == "Accept"
                                          ? "Travel"
                                          : widget.data["U_CK_Status"] ==
                                                  "Travel"
                                              ? "Service"
                                              : "Entry",
                                  style: TextStyle(
                                      color: widget.data["U_CK_Status"] ==
                                              "Accept"
                                          ? const Color.fromARGB(255, 8, 8, 8)
                                          : const Color.fromARGB(
                                              255, 255, 255, 255),
                                      fontSize:  MediaQuery.of(context).size.width *
                                              0.031),
                                  textScaleFactor: 1.0),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    )
                    /////do somthing
                  ]),
                )),
              ],
            )),
      ),
      // bottomNavigationBar: Container(
      //   color: const Color.fromARGB(255, 255, 255, 255),
      //   height: 70,
      //   padding: const EdgeInsets.all(12),
      //   child: Row(
      //     children: [
      //     Expanded(flex: 2,child: Container()),
      //       Expanded(
      //         child: TextButton(
      //           onPressed: () {
      //             // Define your button's action here
      //           },
      //           style: TextButton.styleFrom(
      //             backgroundColor: Colors.red,
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(5.0),
      //             ),
      //           ),
      //           child: Text(
      //             "Reject",
      //             style: TextStyle(
      //                 color: const Color.fromARGB(255, 255, 255, 255),
      //                 fontSize: 13),
      //           ),
      //         ),
      //       ),
      //       const SizedBox(width: 12),
      //       Expanded(
      //         child: TextButton(
      //           onPressed: () {
      //             // Define your button's action here
      //           },
      //           style: TextButton.styleFrom(
      //             backgroundColor: Color.fromARGB(255, 33, 107, 243),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(5.0),
      //             ),
      //           ),
      //           child: Text(
      //             "Accept",
      //             style: TextStyle(
      //                 color: const Color.fromARGB(255, 255, 255, 255),
      //                 fontSize: 13),
      //           ),
      //         ),
      //       ),
      //       const SizedBox(width: 12),
      //     ],
      //   ),
      // ),
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
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400),
        ),
        content: Text(
          content,
          style: const TextStyle(fontSize: 13),
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
  //   @override
  // void dispose() {
  //   stopLocationUpdates();
  //   super.dispose();
  // }
}
