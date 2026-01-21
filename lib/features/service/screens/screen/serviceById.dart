import 'dart:io';

import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/screens/component/detail_row.dart';
import 'package:bizd_tech_service/features/service/screens/component/row_item.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:bizd_tech_service/features/service/screens/screen/sericeEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
    print(widget.data["CK_JOB_EQUIPMENTCollection"]);
  }

  void _onRejected() async {
    // 1. Check internet connection first
    final hasInternet = await _checkInternetConnection();

    if (hasInternet) {
      // Show dialog asking user to choose between save offline or save to SAP
      if (!mounted) return;
      _showInternetAvailableDialog();
    } else {
      // No internet - save offline only
      await _saveOfflineOnly();
    }
    // Navigator.of(context).pop();
  }

  /// Show dialog when internet is available
  void _showInternetAvailableDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.wifi,
                  color: Color(0xFF22C55E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Internet Available',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 24),
              Text(
                'Your internet connection is available. How would you like to save this service?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      await _saveOfflineOnly();
                    },
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: Text(
                      'Save Offline',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      await _saveAndSyncToSAP();
                    },
                    icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                    label: Text(
                      'Save to SAP',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Save offline only without syncing to SAP
  Future<void> _saveOfflineOnly() async {
    final now = DateTime.now();
    final timeStamp = DateFormat("HH:mm:ss").format(now);
    final res =
        await Provider.of<CompletedServiceProvider>(context, listen: false)
            .onReject(
      context: context,
      docEntry: widget.data["DocEntry"],
      customerName: widget.data["U_CK_Cardname"],
      date: widget.data["U_CK_Date"] ?? "",
    );
    if (res && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  /// Save offline and sync to SAP
  Future<void> _saveAndSyncToSAP() async {
    final now = DateTime.now();
    final timeStamp = DateFormat("HH:mm:ss").format(now);
    final onlineProvider =
        Provider.of<ServiceListProvider>(context, listen: false);
    final res =
        await Provider.of<CompletedServiceProvider>(context, listen: false)
            .onReject(
      context: context,
      docEntry: widget.data["DocEntry"],
      customerName: widget.data["U_CK_Cardname"],
      date: widget.data["U_CK_Date"] ?? "",
    );

    if (res) {
      if (mounted) MaterialDialog.loading(context);
      try {
        debugPrint("📡 Internet available - triggering immediate sync...");
        // await Provider.of<CompletedServiceProvider>(context, listen: false)
        //     .syncAllOfflineServicesToSAP(context);
        final now = DateTime.now();
        final timeStamp = DateFormat("HH:mm:ss").format(now);

        // 2. Build the payload
        final payload = {
          "DocEntry": widget.data["DocEntry"],
          "U_CK_Date": widget.data["U_CK_Date"],
          "U_CK_Status": "Rejected",
          "CK_JOB_TIMECollection": [
            {
              "U_CK_Date": widget.data["U_CK_Date"],
              "U_CK_RejectedTime": timeStamp,
            },
          ],
        };
        await onlineProvider.updateStatusDirectToSAP(
          updatePayload: payload,
          context: context,
        );
        print("Synce to SAP progress ....");
      } catch (e) {
        debugPrint(
            "❌ Immediate sync failed (will still reflect as offline): $e");
        // We don't show an error here because the data is safe offline
        // and will be shown as "Pending Sync" on the dashboard.
      } finally {
        if (mounted) MaterialDialog.close(context);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  /// Check if device has internet connection
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }
  // Future<void> _onReject() async {
  //   try {
  //     MaterialDialog.loading(context);
  //     await Future.delayed(const Duration(seconds: 1));

  //     await Provider.of<ServiceListProviderOffline>(context, listen: false)
  //         .updateDocumentAndStatusOffline(
  //       docEntry: widget.data["DocEntry"],
  //       status: "Rejected",
  //       context: context,
  //     );
  //     final provider = context.read<ServiceListProviderOffline>();
  //     provider.refreshDocuments();
  //     MaterialDialog.close(context);
  //     MaterialDialog.close(context);
  //   } catch (e) {
  //     Navigator.of(context).pop();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('❌ Error: $e')),
  //     );
  //   }
  // }

  void makePhoneCall(BuildContext context, String phoneNumber) {
    _showConfirmationDialog(
      context: context,
      title: "Call $phoneNumber ?",
      content: "Do you want to call this number ?",
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
    final provider = context.read<ServiceListProviderOffline>();
    provider.refreshDocuments();
  }

  Future<void> onUpdateStatus() async {
    if (widget.data["U_CK_Status"] == "Service") {
      final res = await goTo(context, ServiceEntryScreen(data: widget.data));
      if (res == true && mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    try {
      MaterialDialog.loading(context);

      // ⏳ Small delay for better UX
      await Future.delayed(const Duration(milliseconds: 300));

      final offlineProvider =
          Provider.of<ServiceListProviderOffline>(context, listen: false);
      final onlineProvider =
          Provider.of<ServiceListProvider>(context, listen: false);

      final cachedDoc =
          await offlineProvider.getDocumentByDocEntry(widget.data["DocEntry"]);
      if (cachedDoc == null) {
        throw "Document not found";
      }

      final now = DateTime.now();
      final timeStamp = DateFormat("HH:mm:ss").format(now);
      // Determine next status
      String nextStatus;
      switch (widget.data["U_CK_Status"]) {
        case "Pending" || "Open":
          nextStatus = "Accept";
          break;
        case "Accept":
          nextStatus = "Travel";
          break;
        case "Travel":
          nextStatus = "Service";
          break;
        default:
          nextStatus = "Entry";
      }

      // Prepare payload
      final updatePayload = {
        // ...cachedDoc,
        "U_CK_TravelTime":
            widget.data["U_CK_Status"] == "Accept" ? timeStamp : null,
        "U_CK_Time": cachedDoc["U_CK_Time"] ?? "",
        "U_CK_EndTime": cachedDoc["U_CK_EndTime"] ?? "",
        'DocEntry': widget.data["DocEntry"],
        'U_CK_Status': nextStatus,
      };

      if (widget.data["U_CK_Status"] == "Pending" ||
          widget.data["U_CK_Status"] == "Open") {
        updatePayload["U_CK_Time"] = timeStamp;
      } else {
        updatePayload["U_CK_EndTime"] = timeStamp;
      }

      if (widget.data["U_CK_Status"] == "Open" ||
          widget.data["U_CK_Status"] == "Pending") {
        updatePayload["U_CK_AcceptTime"] = timeStamp;
      }
      if (widget.data["U_CK_Status"] == "Accept") {
        updatePayload["U_CK_TravelTime"] = timeStamp;
      }

      debugPrint(
          "📤 Updating status to $nextStatus for DocEntry: ${widget.data["DocEntry"]}");

      // 1. Update Online if internet is available
      final hasInternet = await _checkInternetConnection();
      if (hasInternet) {
        await onlineProvider.updateStatusDirectToSAP(
          updatePayload: updatePayload,
          context: context,
        );
      } else {
        debugPrint("📡 Offline mode: Skipping SAP update, will sync later.");
      }

      // 2. Update Offline storage
      await offlineProvider.updateDocumentAndStatusOffline(
        docEntry: widget.data["DocEntry"],
        status: nextStatus,
        time: timeStamp,
        context: context,
      );

      // 3. Refresh and Close
      offlineProvider.refreshDocuments();

      if (mounted) {
        MaterialDialog.close(context);
        MaterialDialog.close(context);
      }
    } catch (e) {
      debugPrint("❌ Error in onUpdateStatus: $e");
      if (mounted) {
        MaterialDialog.close(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    final status = widget.data["U_CK_Status"] ?? "Pending";
    final docNum = widget.data["DocNum"] ?? "N/A";
    final customerName = widget.data["CustomerName"] ?? "Unknown Customer";
    final address =
        (widget.data["CustomerAddress"] as List?)?.isNotEmpty == true
            ? widget.data["CustomerAddress"].first["StreetNo"] ?? "No Address"
            : "No Address";
    final jobType = widget.data["U_CK_JobType"] ?? "Service";
    final dateStr = widget.data["U_CK_Date"]?.split("T")[0] ?? "";
    final startTime = widget.data["U_CK_Time"] ?? "--:--";
    final endTime = widget.data["U_CK_EndTime"] ?? "--:--";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Service Details",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF425364),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
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
                // Info Card
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildModernIconBadge(
                              Icons.business_center_rounded, Colors.blue),
                          _buildModernDocBadge("JOB #$docNum"),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        customerName,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 16.sp, color: const Color(0xFF64748B)),
                          SizedBox(width: 1.5.w),
                          Expanded(
                            child: Text(
                              address,
                              style: GoogleFonts.inter(
                                fontSize: 13.5.sp,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.5.h),
                      Divider(height: 1, color: const Color(0xFFF1F5F9)),
                      SizedBox(height: 2.5.h),
                      Row(
                        children: [
                          _buildModernInfoItem(Icons.calendar_today_rounded,
                              "DATE", showDateOnService(dateStr)),
                          _buildModernVerticalDivider(),
                          _buildModernInfoItem(Icons.access_time_rounded,
                              "SCHEDULED", "$startTime - $endTime"),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          _buildModernInfoItem(Icons.person_rounded,
                              "TECHNICIAN", userName ?? "Loading..."),
                          _buildModernVerticalDivider(),
                          _buildModernInfoItem(
                              Icons.label_rounded, "JOB TYPE", jobType,
                              isBadge: true),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                _buildModernSectionTitle("ADDITIONAL INFORMATION"),
                DetailRow(
                  title: "Contact Information",
                  svg: SvgPicture.asset('images/svg/contact.svg',
                      color: const Color(0xFF22C55E)),
                  rows:
                      (widget.data["CustomerContact"] as List?)?.isEmpty ?? true
                          ? [RowItem(left: "No Contact Available")]
                          : (widget.data["CustomerContact"] as List)
                              .expand<RowItem>((e) => [
                                    RowItem(left: e["Name"] ?? "N/A"),
                                    RowItem(
                                      left: e['Phone1'] ?? "N/A",
                                      right: IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => makePhoneCall(
                                            context, e["Phone1"] ?? ""),
                                        icon: Icon(Icons.phone_rounded,
                                            size: 18.sp,
                                            color: const Color(0xFF22C55E)),
                                      ),
                                      isRightIcon: true,
                                    ),
                                  ])
                              .toList(),
                ),
                DetailRow(
                    title: "Service Items",
                    svg: SvgPicture.asset('images/svg/dolla.svg',
                        color: const Color(0xFF3B82F6)),
                    rows: (widget.data["CK_JOB_SERVICESCollection"] as List?)
                                ?.isEmpty ??
                            true
                        ? [RowItem(left: "No Services Listed")]
                        : (widget.data["CK_JOB_SERVICESCollection"] as List)
                            .map((e) => RowItem(
                                  left: e['U_CK_ServiceName'] ?? "N/A",
                                  right: 'USD ${numberFormatCurrency.format(
                                    double.tryParse(
                                            e["U_CK_UnitPrice"].toString()) ??
                                        0,
                                  )} ',
                                  isRightIcon: false,
                                ))
                            .toList()),
                DetailRow(
                  title: "Equipment Details",
                  svg: const Icon(Icons.build_rounded, color: Colors.orange),
                  rows: (widget.data["CK_JOB_EQUIPMENTCollection"] as List?)
                              ?.isEmpty ??
                          true
                      ? [RowItem(left: "No Equipment Listed")]
                      : (widget.data["CK_JOB_EQUIPMENTCollection"] as List)
                          .expand<RowItem>((e) => [
                                RowItem(
                                  left: e["U_CK_EquipName"] ?? "N/A",
                                ),
                                RowItem(
                                    left:
                                        "SN : ${e["U_CK_SerialNum"] == "" || e["U_CK_SerialNum"] == null ? "N/A" : e["U_CK_SerialNum"]}"),
                              ])
                          .toList(),
                ),
                //  const SizedBox(
                //       height: 15,
                //     ),
                DetailRow(
                  title: "Activity:",
                  svg: SvgPicture.asset(
                    'images/svg/activity.svg',
                    colorFilter:
                        const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                    width: 30,
                    height: 30,
                  ),
                  rows: (widget.data["activityLine"] as List?)?.isEmpty ?? true
                      ? [
                          RowItem(
                            left: "No Activity Available",
                            right: "",
                          ),
                        ]
                      : (widget.data["activityLine"] as List)
                          .map<RowItem>((e) => RowItem(
                              left: "${e["Activity"] ?? "N/A"}",
                              right: SvgPicture.asset(
                                'images/svg/task_check.svg',
                                colorFilter: const ColorFilter.mode(
                                    Colors.blue, BlendMode.srcIn),
                                width: 25,
                                height: 25,
                              ),
                              isRightIcon: true))
                          .toList(),
                ),
                DetailRow(
                  title: "Materials",
                  svg: const Icon(Icons.inventory_2_rounded,
                      color: Colors.purple),
                  rows: (widget.data["CK_JOB_MATERIALCollection"] as List?)
                              ?.isEmpty ??
                          true
                      ? [RowItem(left: "No Materials Listed")]
                      : (widget.data["CK_JOB_MATERIALCollection"] as List)
                          .map((e) => RowItem(
                                left: e["U_CK_ItemName"] ?? "N/A",
                                right: '${e["U_CK_Qty"] ?? 0} ',
                              ))
                          .toList(),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(6.w, 1.2.h, 6.w, 1.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            if (status == "Pending" || status == "Open") ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _onRejected,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Color(0xFFFCA5A5)),

                    // 👇 key lines
                    minimumSize: const Size(0, 45),
                    padding: EdgeInsets.symmetric(vertical: 0.8.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "REJECT",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onUpdateStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getActionColor(status),
                  foregroundColor:
                      status == "Accept" ? Colors.black : Colors.white,
                  elevation: 0,

                  // 👇 key lines
                  minimumSize: const Size(0, 45),
                  padding: EdgeInsets.symmetric(vertical: 0.8.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _getActionLabel(status),
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernIconBadge(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration:
          BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 18.sp),
    );
  }

  Widget _buildModernDocBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569))),
    );
  }

  Widget _buildModernInfoItem(IconData icon, String label, String value,
      {bool isBadge = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15.sp, color: const Color(0xFF94A3B8)),
              SizedBox(width: 1.5.w),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5)),
            ],
          ),
          SizedBox(height: 0.6.h),
          if (isBadge)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
              decoration: BoxDecoration(
                  color: const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFDE047))),
              child: Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF854D0E))),
            )
          else
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildModernVerticalDivider() {
    return Container(
        height: 4.h,
        width: 1,
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        color: const Color(0xFFF1F5F9));
  }

  Widget _buildModernSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(6.w, 0, 6.w, 1.h),
      child: Row(
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 1.0)),
          SizedBox(width: 3.w),
          Expanded(child: Divider(color: const Color(0xFFE2E8F0))),
        ],
      ),
    );
  }

  Color _getActionColor(String status) {
    switch (status) {
      case "Pending" || "Open":
        return const Color(0xFF22C55E);
      case "Accept":
        return const Color(0xFFF59E0B);
      case "Travel":
        return const Color(0xFF3B82F6);
      case "Service":
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _getActionLabel(String status) {
    switch (status) {
      case "Pending" || "Open":
        return "ACCEPT JOB";
      case "Accept":
        return "START TRAVEL";
      case "Travel":
        return "START SERVICE";
      case "Service":
        return "CONTINUE SERVICE";
      default:
        return "VIEW DETAILS";
    }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title,
            style: GoogleFonts.inter(
                fontSize: 18.sp, fontWeight: FontWeight.w700)),
        content: Text(content, style: GoogleFonts.inter(fontSize: 14.sp)),
        actions: [
          TextButton(
            child: Text("Cancel", style: GoogleFonts.inter(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
