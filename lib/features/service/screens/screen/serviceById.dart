import 'dart:math';

import 'package:bizd_tech_service/core/widgets/title_break.dart';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/core/providers/helper_provider.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/provider/update_status_provider.dart';
import 'package:bizd_tech_service/features/service/screens/component/detail_row.dart';
import 'package:bizd_tech_service/features/service/screens/component/row_item.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:bizd_tech_service/features/service/screens/component/service_info_card.dart';
import 'package:bizd_tech_service/features/service/screens/screen/sericeEntry.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF425364),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Service Information',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _refreshData();
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
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
                // Status Stepper
                StatusStepper(status: widget.data["U_CK_Status"] ?? "Open"),
                
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    children: [
                      ServiceInfoCard(data: widget.data),
                      const SizedBox(height: 16),
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
                  ]
                ),
              ),
              ],
            ),
          ),
        ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        child: Row(
          children: [
             widget.data["U_CK_Status"] == "Pending"
                ? Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _onReject();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text("Reject",
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  )
                : const SizedBox.shrink(),
                widget.data["U_CK_Status"] == "Pending" ? const SizedBox(width: 12) : const SizedBox.shrink(),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onUpdateStatus();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.data["U_CK_Status"] == "Accept"
                              ? Colors.amber.shade700
                              : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                        widget.data["U_CK_Status"] == "Pending"
                            ? "Accept"
                            : widget.data["U_CK_Status"] == "Accept"
                                ? "Start Travel"
                                : widget.data["U_CK_Status"] == "Travel"
                                    ? "Start Service"
                                    : "Enter Service",
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
          ],
        ),
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
