import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
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

  Future<void> _onReject() async {
    try {
      MaterialDialog.loading(context);
      await Future.delayed(const Duration(seconds: 1));

      await Provider.of<ServiceListProviderOffline>(context, listen: false)
          .updateDocumentAndStatusOffline(
        docEntry: widget.data["DocEntry"],
        status: "Open",
        context: context,
      );
      final provider = context.read<ServiceListProviderOffline>();
      provider.refreshDocuments();
      MaterialDialog.close(context);
      MaterialDialog.close(context);
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

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
      goTo(context, ServiceEntryScreen(data: widget.data));
      return;
    }

    try {
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
      provider.refreshDocuments();
      MaterialDialog.close(context);
      MaterialDialog.close(context);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
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
                  rows: (widget.data["CustomerContact"] as List).isEmpty
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
                    rows: (widget.data["CK_JOB_SERVICESCollection"] as List)
                            .isEmpty
                        ? [RowItem(left: "No Services Listed")]
                        : (widget.data["CK_JOB_SERVICESCollection"] as List)
                            // .map((e) =>
                            //     RowItem(left: e["U_CK_ServiceName"] ?? "N/A"))
                            // .toList(),
                            .expand<RowItem>((e) => [
                                  RowItem(
                                    left: e['U_CK_ServiceName'] ?? "N/A",
                                    right: 'USD ${numberFormatCurrency.format(
                                      double.tryParse(
                                              e["U_CK_UnitPrice"].toString()) ??
                                          0,
                                    )} ',
                                    isRightIcon: false,
                                  ),
                                ])
                            .toList()),
                DetailRow(
                  title: "Equipment Details",
                  svg: const Icon(Icons.build_rounded, color: Colors.orange),
                  rows: (widget.data["CK_JOB_EQUIPMENTCollection"] as List)
                          .isEmpty
                      ? [RowItem(left: "No Equipment Listed")]
                      : (widget.data["CK_JOB_EQUIPMENTCollection"] as List)
                          .expand<RowItem>((e) => [
                                RowItem(
                                  left: e["U_CK_EquipName"] ?? "N/A",
                                ),
                                RowItem(
                                    left:
                                        "SN : ${e["U_CK_SerialNum"] == "" ? "N/A" : e["U_CK_SerialNum"]}"),
                                // RowItem(
                                //     left: "Model : ${e["U_CK_Model"] == "" ? "N/A" : e["U_CK_Model"]}"),
                              ])
                          .toList(),
                ),
                //  const SizedBox(
                //       height: 15,
                //     ),
                DetailRow(
                  title: "Activity:",
                  svg: SvgPicture.asset(
                    color: Colors.blue,
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
                                      color: Colors.blue,
                                      'images/svg/task_check.svg',
                                      width: 25,
                                      height: 25,
                                    ),
                                    isRightIcon: true),
                              ])
                          .toList(),
                ),
                DetailRow(
                  title: "Materials",
                  svg: const Icon(Icons.inventory_2_rounded,
                      color: Colors.purple),
                  rows:
                      (widget.data["CK_JOB_MATERIALCollection"] as List).isEmpty
                          ? [RowItem(left: "No Materials Listed")]
                          : (widget.data["CK_JOB_MATERIALCollection"] as List)
                              .expand<RowItem>((e) => [
                                    RowItem(
                                      left: e["U_CK_ItemName"] ?? "N/A",
                                      right: '${e["U_CK_Qty"] ?? 0} ',
                                    ),
                                    // RowItem(left: "Qty: ${e["U_CK_Qty"] ?? 0}"),
                                  ])
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
            if (status == "Pending") ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _onReject,
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
      case "Pending":
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
      case "Pending":
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
