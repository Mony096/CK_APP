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
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ServiceEntryScreen extends StatefulWidget {
  const ServiceEntryScreen({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  __ServiceEntryScreenState createState() => __ServiceEntryScreenState();
}

class __ServiceEntryScreenState extends State<ServiceEntryScreen> {
  void onCompletedService() async {
    final res =
        await Provider.of<CompletedServiceProvider>(context, listen: false)
            .onCompletedServiceOffline(
      context: context,
      attachmentEntryExisting: widget.data["U_CK_AttachmentEntry"],
      docEntry: widget.data["DocEntry"],
      startTime: widget.data["U_CK_Time"],
      endTime: widget.data["U_CK_EndTime"],
      customerName: widget.data["U_CK_Cardname"],
      date: widget.data["U_CK_Date"] ?? "",
    );
    if (res) {
      Navigator.of(context).pop(true);
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
          title: Text(
            "Service Entry",
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
                                  fontSize: 12.5.sp,
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
                                  fontSize: 10.5.sp,
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
                                      fontSize: 10.5.sp,
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
                                          fontSize: 13.sp,
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
                                      fontSize: 10.5.sp,
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
                                          fontSize: 13.sp,
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
