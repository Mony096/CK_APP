import 'dart:io';

import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:bizd_tech_service/features/service/screens/screen/image.dart';
import 'package:bizd_tech_service/features/service/screens/screen/materialReserve.dart';
import 'package:bizd_tech_service/features/service/screens/screen/openIssue.dart';
import 'package:bizd_tech_service/features/service/screens/screen/serviceCheckList.dart';
import 'package:bizd_tech_service/features/service/screens/screen/signature.dart';
import 'package:bizd_tech_service/features/service/screens/screen/time.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider_offline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ServiceEntryScreen extends StatefulWidget {
  const ServiceEntryScreen({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  __ServiceEntryScreenState createState() => __ServiceEntryScreenState();
}

class __ServiceEntryScreenState extends State<ServiceEntryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompletedServiceProvider>().clearData();
    });
  }

  void onCompletedService() async {
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
    print(widget.data);
    final now = DateTime.now();
    final timeStamp = DateFormat("HH:mm:ss").format(now);
    final res = await Provider.of<CompletedServiceProvider>(context,
            listen: false)
        .onCompletedServiceOffline(
            context: context,
            attachmentEntryExisting: widget.data["U_CK_AttachmentEntry"],
            docEntry: widget.data["DocEntry"],
            startTime: widget.data["U_CK_Time"],
            endTime: widget.data["U_CK_EndTime"],
            customerName: widget.data["U_CK_Cardname"],
            date: widget.data["U_CK_Date"] ?? "",
            timeAction: {
              "AcceptTime":
                  widget.data["AcceptTime"] ?? widget.data["U_CK_AcceptTime"],
              "TravelTime":
                  widget.data["TravelTime"] ?? widget.data["U_CK_TravelTime"],
              "ServiceTime": widget.data["ServiceTime"],
              "CompleteTime": timeStamp
            },
            activityType: widget.data["U_CK_JobType"]);

    if (res && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  /// Save offline and sync to SAP
  Future<void> _saveAndSyncToSAP() async {
    final now = DateTime.now();
    final timeStamp = DateFormat("HH:mm:ss").format(now);
    final res = await Provider.of<CompletedServiceProvider>(context,
            listen: false)
        .onCompletedServiceOffline(
            context: context,
            attachmentEntryExisting: widget.data["U_CK_AttachmentEntry"],
            docEntry: widget.data["DocEntry"],
            startTime: widget.data["U_CK_Time"],
            endTime: widget.data["U_CK_EndTime"],
            customerName: widget.data["U_CK_Cardname"],
            date: widget.data["U_CK_Date"] ?? "",
            timeAction: {
              "AcceptTime":
                  widget.data["AcceptTime"] ?? widget.data["U_CK_AcceptTime"],
              "TravelTime":
                  widget.data["TravelTime"] ?? widget.data["U_CK_TravelTime"],
              "ServiceTime": widget.data["ServiceTime"],
              "CompleteTime": timeStamp
            },
            activityType: widget.data["U_CK_JobType"]);

    if (res) {
      if (mounted) MaterialDialog.loading(context);
      try {
        debugPrint("📡 Internet available - triggering immediate sync...");
        await Provider.of<CompletedServiceProvider>(context, listen: false)
            .syncAllOfflineServicesToSAP(context);
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
  }

  void onBackScreen() {
    MaterialDialog.warningBackScreen(
      context,
      title: 'Discard Changes?',
      body: "Are you sure you want to go back without completing the service?",
      confirmLabel: "Yes, Discard",
      cancelLabel: "No, Stay",
      onConfirm: () {
        context.read<CompletedServiceProvider>().clearData();
        Navigator.of(context).pop();
      },
      onCancel: () {},
      icon: Icons.warning_amber_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.data["U_CK_Status"] ?? "Entry";
    final docNum = widget.data["DocNum"] ?? "N/A";
    final customerName = widget.data["CustomerName"] ?? "Unknown Customer";
    final jobType = widget.data["U_CK_JobType"] ?? "Service";
    final dateStr = widget.data["U_CK_Date"]?.split("T")[0] ?? "";
    final startTime = widget.data["U_CK_Time"] ?? "--:--";
    final endTime = widget.data["U_CK_EndTime"] ?? "--:--";

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        onBackScreen();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text("Service Entry"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: onBackScreen,
          ),
          actions: [
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
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
                  // Enhanced JOB Summary Card
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
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.w, vertical: 0.6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "JOB #$docNum",
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF9C3),
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: const Color(0xFFFDE047)),
                              ),
                              child: Text(
                                jobType.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF854D0E),
                                ),
                              ),
                            ),
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
                        SizedBox(height: 2.h),
                        Divider(height: 1, color: const Color(0xFFF1F5F9)),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "DATE",
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF94A3B8),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded,
                                          size: 14.sp,
                                          color: const Color(0xFF64748B)),
                                      SizedBox(width: 1.5.w),
                                      Text(
                                        showDateOnService(dateStr),
                                        style: GoogleFonts.inter(
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 3.5.h,
                              width: 1,
                              color: const Color(0xFFF1F5F9),
                              margin: EdgeInsets.symmetric(horizontal: 3.w),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "SCHEDULED",
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF94A3B8),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded,
                                          size: 14.sp,
                                          color: const Color(0xFF64748B)),
                                      SizedBox(width: 1.5.w),
                                      Text(
                                        "$startTime - $endTime",
                                        style: GoogleFonts.inter(
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  _buildSectionTitle("SERVICE COMPONENTS"),
                  _buildMenuEntry(
                    title: "Checklist",
                    subtitle: "Pre-service verification",
                    iconPath: 'images/svg/activity.svg',
                    color: const Color(0xFF3B82F6),
                    onTap: () => goTo(
                        context, ServiceCheckListScreen(data: widget.data)),
                  ),
                  _buildMenuEntry(
                    title: "Material Reserve",
                    subtitle: "Log used parts & materials",
                    iconPath: 'images/svg/material.svg',
                    color: const Color(0xFF8B5CF6),
                    onTap: () =>
                        goTo(context, MaterialReserveScreen(data: widget.data)),
                  ),
                  _buildMenuEntry(
                    title: "Image Upload",
                    subtitle: "Capture service evidence",
                    iconPath: 'images/svg/image.svg',
                    color: const Color(0xFFEC4899),
                    onTap: () => goTo(context, ImageScreen(data: widget.data)),
                  ),
                  _buildMenuEntry(
                    title: "Time Entry",
                    subtitle: "Log service duration",
                    iconPath: 'images/svg/clock.svg',
                    color: const Color(0xFFF59E0B),
                    onTap: () => goTo(context, TimeScreen(data: widget.data)),
                  ),
                  _buildMenuEntry(
                    title: "Signature",
                    subtitle: "Customer verification",
                    iconPath: 'images/svg/signature.svg',
                    color: const Color(0xFF10B981),
                    onTap: () =>
                        goTo(context, SignatureScreen(data: widget.data)),
                  ),
                  _buildMenuEntry(
                    title: "Open Issue",
                    subtitle: "Report pending problems",
                    iconPath: 'images/svg/report.svg',
                    color: const Color(0xFFEF4444),
                    onTap: () =>
                        goTo(context, OpenIssueScreen(data: widget.data)),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
        bottomSheet: Container(
          padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5))
            ],
          ),
          child: ElevatedButton(
            onPressed: onCompletedService,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: Size(double.infinity, 5.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "COMPLETE SERVICE",
              style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(6.w, 0, 6.w, 1.5.h),
      child: Text(
        title,
        style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF94A3B8),
            letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildMenuEntry({
    required String title,
    required String subtitle,
    required String iconPath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.h),
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: SvgPicture.asset(iconPath,
              color: color, width: 22.sp, height: 22.sp),
        ),
        title: Text(title,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
                color: const Color(0xFF1E293B))),
        subtitle: Text(subtitle,
            style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right_rounded,
            color: const Color(0xFFCBD5E1), size: 20.sp),
      ),
    );
  }
}
