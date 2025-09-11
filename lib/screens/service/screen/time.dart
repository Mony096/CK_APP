import 'dart:developer';

import 'package:bizd_tech_service/component/text_time_dialog.dart';
import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/provider/helper_provider.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  _TimeScreenState createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  String? userName;

  int updateIndexTime = -1;
  int isEditTime = -1;
  int isAdded = 0;
  final travelTime = TextEditingController();
  final travelEndTime = TextEditingController();
  final serviceTime = TextEditingController();
  final serviceEndTime = TextEditingController();
  final breakTime = TextEditingController();
  final breakEndTime = TextEditingController();
  final ValueNotifier<Map<String, dynamic>> travelTimeNotifier = ValueNotifier(
      {"missing": false, "value": "Travel time required", "isAdded": 0});
  final ValueNotifier<Map<String, dynamic>> travelEndTimeNotifier =
      ValueNotifier({
    "missing": false,
    "value": "Travel end time required",
    "isAdded": 0
  });

  final ValueNotifier<Map<String, dynamic>> serviceTimeNotifier = ValueNotifier(
      {"missing": false, "value": "Service time required", "isAdded": 0});

  final ValueNotifier<Map<String, dynamic>> serviceEndTimeNotifier =
      ValueNotifier({
    "missing": false,
    "value": "Service end time required",
    "isAdded": 0
  });

  final ValueNotifier<Map<String, dynamic>> breakTimeNotifier = ValueNotifier(
      {"missing": false, "value": "Break time required", "isAdded": 0});
  final ValueNotifier<Map<String, dynamic>> breakEndTimeNotifier =
      ValueNotifier(
          {"missing": false, "value": "Break end time required", "isAdded": 0});
  void _showCreateTimeEntry() async {
    await showDialog<String>(
      barrierDismissible: false, // user must tap button!

      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0), // Rounded corners
          ),
          content: Container(
              padding: const EdgeInsets.only(top: 7),
              width: double.maxFinite, // Use full width of the dialog
              constraints: const BoxConstraints(
                maxHeight: 427, // Limit the height to prevent overflow
              ),
              child: Container(
                  child: ListView(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 21,
                            color: Color.fromARGB(255, 89, 89, 91),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Travel Time",
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "*",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 255, 0, 0)),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_drop_down,
                          size: 24, color: Color.fromARGB(255, 89, 89, 91))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTimeFieldDialog(
                          isMissingFieldNotifier: travelTimeNotifier,
                          controller: travelTime,
                          label: 'Start Time',
                          star: false,
                          // focusNode: codeFocusNode,
                        ),
                      ),
                      const SizedBox(
                        width: 13,
                      ),
                      Expanded(
                        child: CustomTimeFieldDialog(
                          isMissingFieldNotifier: travelEndTimeNotifier,
                          controller: travelEndTime,
                          label: 'End Time',
                          star: false,

                          // focusNode: codeFocusNode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 21,
                            color: Color.fromARGB(255, 89, 89, 91),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Service Time",
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "*",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 255, 0, 0)),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_drop_down,
                          size: 24, color: Color.fromARGB(255, 89, 89, 91))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTimeFieldDialog(
                          isMissingFieldNotifier: serviceTimeNotifier,
                          controller: serviceTime,
                          label: 'Start Time',
                          star: false,

                          // focusNode: codeFocusNode,
                        ),
                      ),
                      const SizedBox(
                        width: 13,
                      ),
                      Expanded(
                        child: CustomTimeFieldDialog(
                          isMissingFieldNotifier: serviceEndTimeNotifier,
                          controller: serviceEndTime,
                          label: 'End Time',
                          star: false,

                          // focusNode: codeFocusNode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 21,
                            color: Color.fromARGB(255, 89, 89, 91),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Break Time",
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "*",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 255, 0, 0)),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_drop_down,
                          size: 24, color: Color.fromARGB(255, 89, 89, 91))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTimeFieldDialog(
                          isMissingFieldNotifier: breakTimeNotifier,
                          controller: breakTime,
                          label: 'Start Time',
                          star: false,

                          // focusNode: codeFocusNode,
                        ),
                      ),
                      const SizedBox(
                        width: 13,
                      ),
                      Expanded(
                        child: CustomTimeFieldDialog(
                          isMissingFieldNotifier: breakEndTimeNotifier,
                          controller: breakEndTime,
                          label: 'End Time',
                          star: false,

                          // focusNode: codeFocusNode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isEditTime = -1;
                          });
                          // clear();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                              color: Color.fromARGB(255, 66, 83, 100)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () {
                            // if (onConfirm != null) {
                            //   onConfirm();
                            // }
                            if (travelTime.text.isEmpty ||
                                travelEndTime.text.isEmpty ||
                                serviceTime.text.isEmpty ||
                                serviceEndTime.text.isEmpty ||
                                breakTime.text.isEmpty ||
                                breakEndTime.text.isEmpty) {
                              travelTimeNotifier.value = {
                                "missing": travelTime.text.isEmpty,
                                "value": "Travel Time is required!",
                                "isAdded": 1,
                              };
                              travelEndTimeNotifier.value = {
                                "missing": travelEndTime.text.isEmpty,
                                "value": "Travel End Time is required!",
                                "isAdded": 1,
                              };
                              serviceTimeNotifier.value = {
                                "missing": serviceTime.text.isEmpty,
                                "value": "Service Time is required!",
                                "isAdded": 1,
                              };
                              serviceEndTimeNotifier.value = {
                                "missing": serviceEndTime.text.isEmpty,
                                "value": "Service End Time is required!",
                                "isAdded": 1,
                              };
                              breakTimeNotifier.value = {
                                "missing": breakTime.text.isEmpty,
                                "value": "Break Time is required!",
                                "isAdded": 1,
                              };
                              breakEndTimeNotifier.value = {
                                "missing": breakEndTime.text.isEmpty,
                                "value": "Break End Time is required!",
                                "isAdded": 1,
                              };

                              return;
                            }

                            isEditTime == -1
                                ? _onAddTimeEntry(context)
                                : onEditTimeEntry();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 66, 83, 100),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            // Adjust the padding to make the button smaller
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Text(
                              // isEditComp >= 0 ? "Edit" : "Add",
                              // final item = provider.timeEntry;
                              context
                                      .read<CompletedServiceProvider>()
                                      .timeEntry
                                      .isEmpty
                                  ? "Add Time"
                                  : "Edit Time",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ))),
          backgroundColor: Colors.white,
          elevation: 4.0,
        );
      },
    );
  }

  void _onAddTimeEntry(BuildContext context, {bool force = false}) {
    try {
      // if (name.text.isEmpty) throw Exception('Name is missing.');
      // if (brand.text.isEmpty) throw Exception('Brand is missing.');

      final item = {
        "U_CK_TraveledTime": travelTime.text,
        "U_CK_TraveledEndTime": travelEndTime.text,
        "U_CK_ServiceStartTime": serviceTime.text,
        "U_CK_SerEndTime": serviceEndTime.text,
        "U_CK_BreakTime": breakTime.text,
        "U_CK_BreakEndTime": breakEndTime.text,
      };

      Provider.of<CompletedServiceProvider>(context, listen: false)
          .addOrEditTimeEntry(item, editIndex: isEditTime);

      // Reset edit mode
      setState(() {
        isEditTime = -1;
      });
      // clear();
      clearValidation();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).unfocus();
      });
      final provider = context.read<CompletedServiceProvider>();

      print(provider.timeEntry);
    } catch (err) {
      if (err is Exception) {
        // Sh SnackBar
        MaterialDialog.success(context, title: 'Warning', body: err.toString());
      }
    }
  }

  void onEditTimeEntry() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCreateTimeEntry(); // Then open edit form dialog
    });
    final provider = context.read<CompletedServiceProvider>();
    final item = provider.timeEntry[0];
    travelTime.text = getDataFromDynamic(item["U_CK_TraveledTime"]);
    travelEndTime.text = getDataFromDynamic(item["U_CK_TraveledEndTime"]);
    serviceTime.text = getDataFromDynamic(item["U_CK_ServiceStartTime"]);
    serviceEndTime.text = getDataFromDynamic(item["U_CK_SerEndTime"]);
    breakTime.text = getDataFromDynamic(item["U_CK_BreakTime"]);
    breakEndTime.text = getDataFromDynamic(item["U_CK_BreakEndTime"]);

    // FocusScope.of(context).requestFocus(codeFocusNode);

    // setState(() {
    //   isEditTime = 0;
    // });
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
// String calculateSpentTime(String start, String end) {
//     final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

//     final startTime = dateFormat.parse("2025-09-01 $start:00");
//     var endTime = dateFormat.parse("2025-09-01 $end:00");

//     // Handle overnight time (end < start)
//     if (endTime.isBefore(startTime)) {
//       endTime = endTime.add(Duration(days: 1));
//     }

//     final duration = endTime.difference(startTime);
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);

//     return "${hours}h ${minutes}m";
//   }
  void clearValidation() {
    travelTimeNotifier.value = {
      "missing": false,
      "value": "Code is required!",
      "isAdded": 1,
    };
    travelEndTimeNotifier.value = {
      "missing": false,
      "value": "Name is required!",
      "isAdded": 1,
    };
    serviceTimeNotifier.value = {
      "missing": false,
      "value": "Part is required!",
      "isAdded": 1,
    };

    serviceEndTimeNotifier.value = {
      "missing": false,
      "value": "Brand is required!",
      "isAdded": 1,
    };
    breakTimeNotifier.value = {
      "missing": false,
      "value": "Model is required!",
      "isAdded": 1,
    };
    breakEndTimeNotifier.value = {
      "missing": false,
      "value": "Model is required!",
      "isAdded": 1,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 238, 240),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 83, 100),
        // Leading menu icon on the left
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        // Centered title
        title: GestureDetector(
          // onTap: () {
          //      print(calculateSpentTime(
          //     "2:00",
          //     "5:30",
          //   ));
          // },
          child: const Center(
            child: Text(
              'Time Entry',
              style: TextStyle(fontSize: 17, color: Colors.white),
              textScaleFactor: 1.0,
            ),
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
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
              // SizedBox(width: 3),
              IconButton(
                onPressed: () async {
                  MaterialDialog.loading(context);
                  await Provider.of<AuthProvider>(context, listen: false)
                      .logout();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                    // color: const Color.fromARGB(255, 255, 255, 255),

                    borderRadius: BorderRadius.circular(5.0), // Rounded corners
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
                                              style: const TextStyle(
                                                  fontSize: 12.5),
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
                                              style: const TextStyle(
                                                fontSize: 12.5,
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
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text(
                                                "No: ",
                                                style: TextStyle(fontSize: 13),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                "${widget.data["DocNum"]}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13),
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
                              padding: const EdgeInsets.fromLTRB(10, 15, 10, 8),
                              color: const Color.fromARGB(255, 66, 83, 100),
                              width: double.infinity,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 6),
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
                                              const Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                    "Service:",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 13.5),
                                                    textScaleFactor: 1.0,
                                                  )),
                                                  Expanded(
                                                      child: Text(
                                                    "Status:",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13.5,
                                                        color: Colors.white),
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
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
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
                                                              child: const Text(
                                                                "No Services Available",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12.5),
                                                              ),
                                                            )
                                                          ]
                                                        : (widget.data["CK_JOB_SERVICESCollection"]
                                                                        as List)
                                                                    .length >
                                                                2
                                                            ? [
                                                                ...(widget.data[
                                                                            "CK_JOB_SERVICESCollection"]
                                                                        as List)
                                                                    .take(2)
                                                                    .map((e) =>
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              bottom: 8),
                                                                          child:
                                                                              Text(
                                                                            "${e["U_CK_ServiceName"]}",
                                                                            style:
                                                                                const TextStyle(color: Colors.white, fontSize: 12.5),
                                                                            textScaleFactor:
                                                                                1.0,
                                                                          ),
                                                                        )),
                                                                const Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          bottom:
                                                                              7),
                                                                  child: Text(
                                                                    "more...",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            12.5),
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
                                                                          bottom:
                                                                              8),
                                                                      child:
                                                                          Text(
                                                                        "${e["U_CK_ServiceName"]}",
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 12.5),
                                                                        textScaleFactor:
                                                                            1.0,
                                                                      ),
                                                                    ))
                                                                .toList(),
                                                  )),
                                                  const Expanded(
                                                      child: Text(
                                                    "Open",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12.5),
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
                                            padding: EdgeInsets.only(right: 6),
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
                                              const Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                    "Equipment:",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 13.5),
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
                                                          const EdgeInsets.only(
                                                              bottom: 8),
                                                      child: const Text(
                                                        "No Equipment Available",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12.5),
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
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            "${item["U_CK_EquipName"]}",
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12.5),
                                                            textScaleFactor:
                                                                1.0,
                                                          )),
                                                          Expanded(
                                                              child: Text(
                                                            "SN: ${item["U_CK_SerialNum"]}",
                                                            textAlign:
                                                                TextAlign.end,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12.5,
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
                                                  ? const Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 7),
                                                      child: Text(
                                                        "more...",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12.5),
                                                        textScaleFactor: 1.0,
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ))
                                    ],
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ), //
                    ////endddddddddddddddddddddddddd
                    const SizedBox(
                      height: 10,
                    ),
                    Menu(
                      title: userName ?? "...",
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: SvgPicture.asset(
                          color: Colors.green,
                          'images/svg/clock.svg',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      date: showDateOnService(
                          widget.data["U_CK_Date"]?.split("T")[0] ?? ""),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DetailTime(
                      onTap: () {
                        final provider =
                            context.read<CompletedServiceProvider>();
                        // final item = provider.timeEntry;
                        provider.timeEntry.isEmpty
                            ? _showCreateTimeEntry()
                            : onEditTimeEntry();
                      },
                      isValidTime: context
                          .read<CompletedServiceProvider>()
                          .timeEntry
                          .isNotEmpty,
                      timeEntry: context
                              .read<CompletedServiceProvider>()
                              .timeEntry
                              .isNotEmpty
                          ? context
                              .read<CompletedServiceProvider>()
                              .timeEntry[0]
                          : {},
                    ),
                    /////do somthing
                  ]),
                )),
              ],
            )),
      ),
    );
  }
}

class Menu extends StatefulWidget {
  const Menu({super.key, this.icon, required this.title, required this.date});
  final dynamic icon;
  final String title;
  final String date;
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
              flex: 3,
              child: Text(
                textScaleFactor: 1.0,
                widget.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              )),
          Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  textAlign: TextAlign.right,
                  textScaleFactor: 1.0,
                  widget.date,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              )),
        ],
      ),
    );
  }
}

class DetailTime extends StatefulWidget {
  const DetailTime({
    super.key,
    this.onTap,
    required this.isValidTime,
    required this.timeEntry,
  });
  final VoidCallback? onTap;
  final bool isValidTime;
  final Map<String, dynamic> timeEntry;
  @override
  State<DetailTime> createState() => _DetailTimeState();
}

class _DetailTimeState extends State<DetailTime> {
  @override
  void initState() {
    super.initState();
    print(widget.timeEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
        color: Colors.white,
        child: Column(
          children: [
            widget.isValidTime
                ? Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  textScaleFactor: 1.0,
                                  "Travel Time:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              )),
                          Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Start Time:",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    width: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey, // Border color
                                        width: 1.0, // Border width
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          3.0), // Optional: Rounded corners
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 3),
                                          child: Text(
                                            widget
                                                .timeEntry["U_CK_TraveledTime"],
                                            style:
                                                const TextStyle(fontSize: 13),
                                            textScaleFactor: 1.0,
                                          ),
                                        ),
                                        SvgPicture.asset(
                                          color: const Color.fromARGB(
                                              255, 29, 30, 29),
                                          'images/svg/schedule.svg',
                                          width: 20,
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("End Time:",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    width: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey, // Border color
                                        width: 1.0, // Border width
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          3.0), // Optional: Rounded corners
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 3),
                                          child: Text(
                                            widget.timeEntry[
                                                "U_CK_TraveledEndTime"],
                                            style:
                                                const TextStyle(fontSize: 13),
                                            textScaleFactor: 1.0,
                                          ),
                                        ),
                                        SvgPicture.asset(
                                          color: const Color.fromARGB(
                                              255, 29, 30, 29),
                                          'images/svg/schedule.svg',
                                          width: 20,
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          // const SizedBox(
                          //   width: 10,
                          // ),
                          Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  const Text(
                                    textScaleFactor: 1.0,
                                    "Eff.T",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  // Row(
                                  //   children: [
                                  //     Text(
                                  //         widget.timeEntry["total_travel_time"],
                                  //         textScaleFactor: 1.0,
                                  //         style: const TextStyle(
                                  //             fontSize: 14,
                                  //             color: Colors.green,
                                  //             fontWeight: FontWeight.bold)),
                                  //     const SizedBox(
                                  //       width: 4,
                                  //     ),
                                  //     const Icon(Icons.timelapse,
                                  //         size: 18, color: Colors.green),
                                  //   ],
                                  // ),
                                  SizedBox(
                                    width: 85,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            widget
                                                .timeEntry["total_travel_time"],
                                            textScaleFactor: 1.0,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.green,
                                            )),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        const Icon(Icons.timelapse,
                                            size: 18, color: Colors.green),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          const Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  textScaleFactor: 1.0,
                                  "Service Time:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              )),
                          Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Start Time:",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    width: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey, // Border color
                                        width: 1.0, // Border width
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          3.0), // Optional: Rounded corners
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 3),
                                          child: Text(
                                            widget.timeEntry[
                                                "U_CK_ServiceStartTime"],
                                            style:
                                                const TextStyle(fontSize: 13),
                                            textScaleFactor: 1.0,
                                          ),
                                        ),
                                        SvgPicture.asset(
                                          color: const Color.fromARGB(
                                              255, 29, 30, 29),
                                          'images/svg/schedule.svg',
                                          width: 20,
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("End Time:",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    width: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey, // Border color
                                        width: 1.0, // Border width
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          3.0), // Optional: Rounded corners
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 3),
                                          child: Text(
                                            widget.timeEntry["U_CK_SerEndTime"],
                                            style:
                                                const TextStyle(fontSize: 13),
                                            textScaleFactor: 1.0,
                                          ),
                                        ),
                                        SvgPicture.asset(
                                          color: const Color.fromARGB(
                                              255, 29, 30, 29),
                                          'images/svg/schedule.svg',
                                          width: 20,
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          // const SizedBox(
                          //   width: 5,
                          // ),
                          Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  // Text(widget.timeEntry["total_service_time"],
                                  //     textScaleFactor: 1.0,
                                  //     style: const TextStyle(
                                  //         fontSize: 14,
                                  //         color: Colors.green,
                                  //         fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 85,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            widget.timeEntry[
                                                "total_service_time"],
                                            textScaleFactor: 1.0,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.green,
                                            )),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        const Icon(Icons.timelapse,
                                            size: 18, color: Colors.green),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          const Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  textScaleFactor: 1.0,
                                  "Break Time:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              )),
                          Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Start Time:",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    width: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey, // Border color
                                        width: 1.0, // Border width
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          3.0), // Optional: Rounded corners
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 3),
                                          child: Text(
                                            widget.timeEntry["U_CK_BreakTime"],
                                            style:
                                                const TextStyle(fontSize: 13),
                                            textScaleFactor: 1.0,
                                          ),
                                        ),
                                        SvgPicture.asset(
                                          color: const Color.fromARGB(
                                              255, 29, 30, 29),
                                          'images/svg/schedule.svg',
                                          width: 20,
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("End Time:",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    width: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey, // Border color
                                        width: 1.0, // Border width
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          3.0), // Optional: Rounded corners
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 3),
                                          child: Text(
                                            widget
                                                .timeEntry["U_CK_BreakEndTime"],
                                            style:
                                                const TextStyle(fontSize: 13),
                                            textScaleFactor: 1.0,
                                          ),
                                        ),
                                        SvgPicture.asset(
                                          color: const Color.fromARGB(
                                              255, 29, 30, 29),
                                          'images/svg/schedule.svg',
                                          width: 20,
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          // const SizedBox(
                          //   width: 10,
                          // ),
                          Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  SizedBox(
                                    width: 85,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            widget
                                                .timeEntry["total_break_time"],
                                            textScaleFactor: 1.0,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.green,
                                            )),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        const Icon(Icons.timelapse,
                                            size: 18, color: Colors.green),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.alarm,
                          size: 23,
                          color: Color.fromARGB(221, 168, 168, 171),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "No Time Added",
                          style: TextStyle(
                              fontSize: 14,
                              // fontWeight: FontWeight.w500,
                              color: Color.fromARGB(221, 168, 168, 171)),
                        ),
                      ],
                    ),
                  ),
            Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              height: 70,
              padding: const EdgeInsets.fromLTRB(12, 12, 0, 10),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Container()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: widget.onTap,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: Text(
                        !widget.isValidTime ? "Add Time" : "Edit Time",
                        style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ],
        ));
  }
}
