import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/core/widgets/text_time_dialog.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  _TimeScreenState createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  @override
  void dispose() {
    travelTime.dispose();
    travelEndTime.dispose();
    serviceTime.dispose();
    serviceEndTime.dispose();
    breakTime.dispose();
    breakEndTime.dispose();
    travelTimeNotifier.dispose();
    travelEndTimeNotifier.dispose();
    serviceTimeNotifier.dispose();
    serviceEndTimeNotifier.dispose();
    breakTimeNotifier.dispose();
    breakEndTimeNotifier.dispose();
    super.dispose();
  }

  final travelTime = TextEditingController();
  final travelEndTime = TextEditingController();
  final serviceTime = TextEditingController();
  final serviceEndTime = TextEditingController();
  final breakTime = TextEditingController();
  final breakEndTime = TextEditingController();

  final ValueNotifier<Map<String, dynamic>> travelTimeNotifier =
      ValueNotifier({"missing": false, "value": "", "isAdded": 0});
  final ValueNotifier<Map<String, dynamic>> travelEndTimeNotifier =
      ValueNotifier({"missing": false, "value": "", "isAdded": 0});
  final ValueNotifier<Map<String, dynamic>> serviceTimeNotifier =
      ValueNotifier({"missing": false, "value": "", "isAdded": 0});
  final ValueNotifier<Map<String, dynamic>> serviceEndTimeNotifier =
      ValueNotifier({"missing": false, "value": "", "isAdded": 0});
  final ValueNotifier<Map<String, dynamic>> breakTimeNotifier =
      ValueNotifier({"missing": false, "value": "", "isAdded": 0});
  final ValueNotifier<Map<String, dynamic>> breakEndTimeNotifier =
      ValueNotifier({"missing": false, "value": "", "isAdded": 0});

  int isEditTime = -1;

  void _showCreateTimeEntry() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.more_time_rounded,
                  color: const Color(0xFF425364), size: 20.sp),
              SizedBox(width: 3.w),
              Text("Log Time",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 15.5.sp)),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeSection("Travel Time", travelTime, travelEndTime,
                      travelTimeNotifier, travelEndTimeNotifier),
                  SizedBox(height: 3.h),
                  _buildTimeSection("Service Time", serviceTime, serviceEndTime,
                      serviceTimeNotifier, serviceEndTimeNotifier),
                  SizedBox(height: 3.h),
                  _buildTimeSection("Break Time (Optional)", breakTime,
                      breakEndTime, breakTimeNotifier, breakEndTimeNotifier,
                      isRequired: false),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                isEditTime = -1;
                Navigator.of(context).pop();
              },
              child: Text("Cancel",
                  style: GoogleFonts.inter(
                      color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_validate()) {
                  _onAddTimeEntry(context);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 40),
                backgroundColor: const Color(0xFF425364),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isEditTime == -1 ? "Add Entry" : "Save Changes",
                  style: TextStyle(fontSize: 14.5.sp)),
            ),
          ],
        );
      },
    );
  }

  DateTime? parseTime(String value) {
    if (value.trim().isEmpty || value == "--:--") return null;

    try {
      final t = DateFormat('h:mm a').parseLoose(value.trim());
      return DateTime(2000, 1, 1, t.hour, t.minute);
    } catch (_) {
      try {
        final p = value.split(':');
        return DateTime(2000, 1, 1, int.parse(p[0]), int.parse(p[1]));
      } catch (_) {
        return null;
      }
    }
  }

  DateTime currentTime() {
    final now = DateTime.now();
    return DateTime(2000, 1, 1, now.hour, now.minute);
  }

  Widget _buildTimeSection(
      String title,
      TextEditingController start,
      TextEditingController end,
      ValueNotifier<Map<String, dynamic>> startN,
      ValueNotifier<Map<String, dynamic>> endN,
      {bool isRequired = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B))),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
                child: CustomTimeFieldDialog(
                    isMissingFieldNotifier: startN,
                    controller: start,
                    label: 'Start',
                    star: isRequired)),
            SizedBox(width: 3.w),
            Expanded(
                child: CustomTimeFieldDialog(
                    isMissingFieldNotifier: endN,
                    controller: end,
                    label: 'End',
                    star: isRequired)),
          ],
        ),
      ],
    );
  }

  bool _validate() {
    bool isValid = true;

    final breakStartText = breakTime.text.trim();
    final breakEndText = breakEndTime.text.trim();

    // ===============================
    // 1️⃣ REQUIRED FIELDS
    // ===============================
    if (travelTime.text.isEmpty) {
      travelTimeNotifier.value = {
        "missing": true,
        "value": "Required",
        "isAdded": 1
      };
      isValid = false;
    }

    if (travelEndTime.text.isEmpty) {
      travelEndTimeNotifier.value = {
        "missing": true,
        "value": "Required",
        "isAdded": 1
      };
      isValid = false;
    }

    if (serviceTime.text.isEmpty) {
      serviceTimeNotifier.value = {
        "missing": true,
        "value": "Required",
        "isAdded": 1
      };
      isValid = false;
    }

    if (serviceEndTime.text.isEmpty) {
      serviceEndTimeNotifier.value = {
        "missing": true,
        "value": "Required",
        "isAdded": 1
      };
      isValid = false;
    }

    // ===============================
    // 2️⃣ BREAK TIME (OPTIONAL)
    // ===============================

    // Case A: both empty → allowed, skip validation
    if (breakStartText.isEmpty && breakEndText.isEmpty) {
      breakTimeNotifier.value = {"missing": false, "value": "", "isAdded": 0};
      breakEndTimeNotifier.value = {
        "missing": false,
        "value": "",
        "isAdded": 0
      };
    }
    // Case B: one empty → error
    else if (breakStartText.isEmpty || breakEndText.isEmpty) {
      breakTimeNotifier.value = {
        "missing": breakStartText.isEmpty,
        "value": "Required",
        "isAdded": 1
      };
      breakEndTimeNotifier.value = {
        "missing": breakEndText.isEmpty,
        "value": "Required",
        "isAdded": 1
      };
      isValid = false;
    }
    // Case C: both filled → validate range
    else {
      final jobStart = parseTime(widget.data["U_CK_Time"] ?? "");
      final breakStart = parseTime(breakStartText);
      final breakEnd = parseTime(breakEndText);

      if (jobStart == null || breakStart == null || breakEnd == null) {
        isValid = false;
      } else {
        // break start between jobStart and now
        if (!breakStart.isAfter(jobStart) ||
            breakStart.isAfter(currentTime())) {
          breakTimeNotifier.value = {
            "missing": true,
            "value":
                "Must be after ${widget.data["U_CK_Time"]} and not in future",
            "isAdded": 1
          };
          isValid = false;
        } else {
          breakTimeNotifier.value = {
            "missing": false,
            "value": "",
            "isAdded": 1
          };
        }

        // break end between jobStart and now
        if (!breakEnd.isAfter(jobStart) || breakEnd.isAfter(currentTime())) {
          breakEndTimeNotifier.value = {
            "missing": true,
            "value":
                "Must be after ${widget.data["U_CK_Time"]} and not in future",
            "isAdded": 1
          };
          isValid = false;
        } else {
          breakEndTimeNotifier.value = {
            "missing": false,
            "value": "",
            "isAdded": 1
          };
        }
      }
    }

    // ===============================
    // 3️⃣ FINAL RESULT
    // ===============================
    return isValid;
  }

//   bool _validate() {
//     bool isValid = true;
//     final breakStartText = breakTime.text.trim();
//     final breakEndText = breakEndTime.text.trim();
//     if (travelTime.text.isEmpty) {
//       travelTimeNotifier.value = {
//         "missing": true,
//         "value": "Required",
//         "isAdded": 1
//       };
//       isValid = false;
//     }
//     if (travelEndTime.text.isEmpty) {
//       travelEndTimeNotifier.value = {
//         "missing": true,
//         "value": "Required",
//         "isAdded": 1
//       };
//       isValid = false;
//     }
//     if (serviceTime.text.isEmpty) {
//       serviceTimeNotifier.value = {
//         "missing": true,
//         "value": "Required",
//         "isAdded": 1
//       };
//       isValid = false;
//     }
//     if (serviceEndTime.text.isEmpty) {
//       serviceEndTimeNotifier.value = {
//         "missing": true,
//         "value": "Required",
//         "isAdded": 1
//       };
//       isValid = false;
//     }
//     // Break Time is optional, but if one field is filled, both must be validated
//     // 1️⃣ Optional logic
//     if (breakStartText.isEmpty && breakEndText.isEmpty) {
//       breakTimeNotifier.value = {"missing": false, "value": "", "isAdded": 0};
//       breakEndTimeNotifier.value = {
//         "missing": false,
//         "value": "",
//         "isAdded": 0
//       };
//       return true;
//     }

//     // 2️⃣ One filled, one missing
//     if (breakStartText.isEmpty || breakEndText.isEmpty) {
//       breakTimeNotifier.value = {
//         "missing": breakStartText.isEmpty,
//         "value": "Required",
//         "isAdded": 1
//       };
//       breakEndTimeNotifier.value = {
//         "missing": breakEndText.isEmpty,
//         "value": "Required",
//         "isAdded": 1
//       };
//       return false;
//     }

//     // 3️⃣ Parse times
//     final jobStart = parseTime(widget.data["U_CK_Time"] ?? "");
//     final breakStart = parseTime(breakStartText);
//     final breakEnd = parseTime(breakEndText);

//     if (jobStart == null || breakStart == null || breakEnd == null) {
//       return false;
//     }

//     // 4️⃣ Break start must be BETWEEN jobStart and current time
//     if (!breakStart.isAfter(jobStart) || breakStart.isAfter(currentTime())) {
//       breakTimeNotifier.value = {
//         "missing": true,
//         "value": "Must be after ${widget.data["U_CK_Time"]} and not in future",
//         "isAdded": 1
//       };
//       isValid = false;
//     } else {
//       breakTimeNotifier.value = {"missing": false, "value": "", "isAdded": 1};
//     }

// // 5️⃣ Break end must be BETWEEN jobStart and current time
//     if (!breakEnd.isAfter(jobStart) || breakEnd.isAfter(currentTime())) {
//       breakEndTimeNotifier.value = {
//         "missing": true,
//         "value": "Must be after ${widget.data["U_CK_Time"]} and not in future",
//         "isAdded": 1
//       };
//       isValid = false;
//     } else {
//       breakEndTimeNotifier.value = {
//         "missing": false,
//         "value": "",
//         "isAdded": 1
//       };
//     }

//     return isValid;
//   }

  void _onAddTimeEntry(BuildContext context) {
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

    _clearInputs();
  }

  void onEditTimeEntry() {
    // Handled by callback inside _showCreateTimeEntry or by the provider directly
  }

  void _clearInputs() {
    travelTime.clear();
    travelEndTime.clear();
    serviceTime.clear();
    serviceEndTime.clear();
    breakTime.clear();
    breakEndTime.clear();
    isEditTime = -1;
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.data["U_CK_Status"] ?? "Pending";
    final docNum = widget.data["DocNum"] ?? "N/A";
    final customerName = widget.data["CustomerName"] ?? "Unknown Customer";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Time Entry"),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check_rounded, color: Colors.white),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Column(
        children: [
          StatusStepper(status: status),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              children: [
                // JOB Summary Card
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle),
                        child: Icon(Icons.business_center_rounded,
                            color: const Color(0xFF425364), size: 18.sp),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customerName,
                                style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B))),
                            Text("JOB #$docNum",
                                style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                Consumer<CompletedServiceProvider>(
                  builder: (context, provider, child) {
                    final hasEntry = provider.timeEntry.isNotEmpty;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("TIME LOGS",
                              style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF94A3B8),
                                  letterSpacing: 1.0)),
                          if (!hasEntry)
                            ElevatedButton.icon(
                              onPressed: _showCreateTimeEntry,
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: Text(
                                "LOG TIME",
                                style: TextStyle(fontSize: 12.5.sp),
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 40),
                                backgroundColor: const Color(0xFF425364),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 0.8.h),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                textStyle: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 1.5.h),
                Consumer<CompletedServiceProvider>(
                  builder: (context, provider, child) {
                    final timeEntries = provider.timeEntry;
                    if (timeEntries.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Column(
                            children: [
                              Icon(Icons.more_time_rounded,
                                  size: 30.sp, color: const Color(0xFFCBD5E1)),
                              SizedBox(height: 1.h),
                              Text("No time entries logged",
                                  style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: timeEntries
                          .asMap()
                          .entries
                          .map((entry) => _buildLogCard(entry.value, entry.key))
                          .toList(),
                    );
                  },
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Service Period #${index + 1}",
                  style: GoogleFonts.inter(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B))),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isEditTime = index;
                        travelTime.text =
                            getDataFromDynamic(item["U_CK_TraveledTime"]);
                        travelEndTime.text =
                            getDataFromDynamic(item["U_CK_TraveledEndTime"]);
                        serviceTime.text =
                            getDataFromDynamic(item["U_CK_ServiceStartTime"]);
                        serviceEndTime.text =
                            getDataFromDynamic(item["U_CK_SerEndTime"]);
                        breakTime.text =
                            getDataFromDynamic(item["U_CK_BreakTime"]);
                        breakEndTime.text =
                            getDataFromDynamic(item["U_CK_BreakEndTime"]);
                      });
                      _showCreateTimeEntry();
                    },
                    icon: Icon(Icons.edit_note_rounded,
                        color: Colors.blue, size: 20.sp),
                  ),
                  IconButton(
                    onPressed: () => context
                        .read<CompletedServiceProvider>()
                        .removeTimeEntry(index),
                    icon: Icon(Icons.delete_outline_rounded,
                        color: Colors.red, size: 20.sp),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 1.h),
          _buildTimeRow("Travel", item["U_CK_TraveledTime"],
              item["U_CK_TraveledEndTime"], Colors.blue),
          _buildTimeRow("Service", item["U_CK_ServiceStartTime"],
              item["U_CK_SerEndTime"], Colors.green),
          _buildTimeRow("Break", item["U_CK_BreakTime"],
              item["U_CK_BreakEndTime"], Colors.orange),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, dynamic start, dynamic end, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.6.h),
      child: Row(
        children: [
          Container(
              width: 3,
              height: 4.h,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8))),
                SizedBox(height: 1.5.h),
                Text(
                    "${getDataFromDynamic(start)} - ${getDataFromDynamic(end)}",
                    style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569))),
              ],
            ),
          ),
          Text(
              calculateSpentTime(
                  getDataFromDynamic(start), getDataFromDynamic(end)),
              style: GoogleFonts.inter(
                  fontSize: 13.sp, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  String calculateSpentTime(String start, String end) {
    try {
      if (start.isEmpty || end.isEmpty) return "0h 0m";
      final format = DateFormat("HH:mm");
      final startTime = format.parse(start);
      var endTime = format.parse(end);
      if (endTime.isBefore(startTime))
        endTime = endTime.add(const Duration(days: 1));
      final diff = endTime.difference(startTime);
      return "${diff.inHours}h ${diff.inMinutes % 60}m";
    } catch (e) {
      return "0h 0m";
    }
  }
}
