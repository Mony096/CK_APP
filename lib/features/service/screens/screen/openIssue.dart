import 'package:bizd_tech_service/core/widgets/DatePickerDialog.dart';
import 'package:bizd_tech_service/core/widgets/text_field_dialog.dart';
import 'package:bizd_tech_service/core/widgets/text_remark_dialog.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class OpenIssueScreen extends StatefulWidget {
  const OpenIssueScreen({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  _OpenIssueScreenState createState() => _OpenIssueScreenState();
}

class _OpenIssueScreenState extends State<OpenIssueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CompletedServiceProvider>();
      if (provider.openIssues.isEmpty) {
        final issues = widget.data["CK_JOB_ISSUECollection"] as List? ?? [];
        provider.setOpenIssues(List<dynamic>.from(issues));
      }
    });
  }

  final area = TextEditingController();
  final desc = TextEditingController();
  final critical = TextEditingController();
  final date = TextEditingController();
  final status = TextEditingController();
  final handleBy = TextEditingController();
  final remark = TextEditingController();

  final areaFieldNotifier = ValueNotifier<Map<String, dynamic>>(
      {"missing": false, "value": "Area is required!", "isAdded": 1});
  final descFieldNotifier = ValueNotifier<Map<String, dynamic>>(
      {"missing": false, "value": "Description is required!", "isAdded": 1});

  int isEditIndex = -1;

  void _showIssueDialog({int? index}) {
    if (index != null) {
      final item = context.read<CompletedServiceProvider>().openIssues[index];
      area.text = item["U_CK_IssueType"] ?? "";
      desc.text = item["U_CK_IssueDesc"] ?? "";
      critical.text = item["U_CK_RaisedBy"] ?? "";
      date.text = item["U_CK_CreatedDate"] ??
          DateFormat('yyyy-MM-dd').format(DateTime.now());
      status.text = item["U_CK_Status"] ?? "";
      handleBy.text = item["U_CK_HandledBy"] ?? "";
      remark.text = item["U_CK_Comment"] ?? "";
      isEditIndex = index;
    } else {
      area.clear();
      desc.clear();
      critical.clear();
      date.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      status.clear();
      handleBy.clear();
      remark.clear();
      isEditIndex = -1;
    }

    areaFieldNotifier.value = {
      "missing": false,
      "value": "Area is required!",
      "isAdded": 1
    };
    descFieldNotifier.value = {
      "missing": false,
      "value": "Description is required!",
      "isAdded": 1
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.report_problem_rounded,
                  color: const Color(0xFFEF4444), size: 18.sp),
              SizedBox(width: 3.w),
              Text(isEditIndex == -1 ? "Log New Issue" : "Edit Issue",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 16.sp)),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 60.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFieldDialog(
                      controller: area,
                      label: 'Area',
                      star: true,
                      isMissingFieldNotifier: areaFieldNotifier),
                  SizedBox(height: 1.5.h),
                  CustomTextRemarkDialog(
                      controller: desc,
                      label: 'Description',
                      star: true,
                      detail: false,
                      isMissingFieldNotifier: descFieldNotifier),
                  SizedBox(height: 1.5.h),
                  CustomDatePickerFieldDialog(
                      controller: date,
                      label: 'Date',
                      star: true,
                      detail: false),
                  SizedBox(height: 1.5.h),
                  CustomTextFieldDialog(
                      controller: critical, label: 'Critical', star: false),
                  SizedBox(height: 1.5.h),
                  CustomTextFieldDialog(
                      controller: status, label: 'Status', star: false),
                  SizedBox(height: 1.5.h),
                  CustomTextFieldDialog(
                      controller: handleBy, label: 'Handle By', star: false),
                  SizedBox(height: 1.5.h),
                  CustomTextRemarkDialog(
                      controller: remark,
                      label: 'Remarks',
                      star: false,
                      detail: false),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel",
                  style: GoogleFonts.inter(
                      color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                if (area.text.isEmpty || desc.text.isEmpty) {
                  areaFieldNotifier.value = {
                    "missing": area.text.isEmpty,
                    "value": "Area is required!",
                    "isAdded": 1
                  };
                  descFieldNotifier.value = {
                    "missing": desc.text.isEmpty,
                    "value": "Description is required!",
                    "isAdded": 1
                  };
                  return;
                }
                final item = {
                  "U_CK_IssueType": area.text,
                  "U_CK_IssueDesc": desc.text,
                  "U_CK_RaisedBy": critical.text,
                  "U_CK_CreatedDate": date.text,
                  "U_CK_Status": status.text,
                  "U_CK_HandledBy": handleBy.text,
                  "U_CK_Comment": remark.text,
                };
                Provider.of<CompletedServiceProvider>(context, listen: false)
                    .addOrEditOpenIssue(item, editIndex: isEditIndex);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                                 minimumSize: const Size(0, 40),

                backgroundColor: const Color(0xFF425364),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isEditIndex == -1 ? "Report Issue" : "Update Issue",
                  style: TextStyle(fontSize: 14.5.sp)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.data["U_CK_Status"] ?? "Pending";
    final docNum = widget.data["DocNum"] ?? "N/A";
    final customerName = widget.data["CustomerName"] ?? "Unknown Customer";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Open Issues",
            style: GoogleFonts.inter(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF425364),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("DOCUMENTED ISSUES",
                          style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 1.0)),
                      ElevatedButton.icon(
                        onPressed: () => _showIssueDialog(),
                        icon: const Icon(Icons.add_circle_outline_rounded,
                            size: 16),
                        label: Text("LOG ISSUE",style: TextStyle(fontSize: 12.7.sp),),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 0.8.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          textStyle: GoogleFonts.inter(
                              fontSize: 12.sp, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.5.h),
                Consumer<CompletedServiceProvider>(
                  builder: (context, provider, child) {
                    final issues = provider.openIssues;
                    if (issues.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Column(
                            children: [
                              Icon(Icons.assignment_turned_in_rounded,
                                  size: 30.sp, color: const Color(0xFFCBD5E1)),
                              SizedBox(height: 1.h),
                              Text("No issues reported",
                                  style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: issues
                          .asMap()
                          .entries
                          .map((entry) => _buildIssueCard(entry.value))
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

  Widget _buildIssueCard(dynamic item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      padding: EdgeInsets.only(left: 4.w,right: 4.w,top: 1.w,bottom: 2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFEE2E2)),
        boxShadow: [
          BoxShadow(
              color: Colors.red.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(item["U_CK_IssueType"] ?? "N/A",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          color: const Color(0xFF1E293B)))),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_note_rounded,
                        color: Colors.blue, size: 20.sp),
                    onPressed: () {
                      final index = context
                          .read<CompletedServiceProvider>()
                          .openIssues
                          .indexOf(item);
                      _showIssueDialog(index: index);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: Colors.red, size: 20.sp),
                    onPressed: () {
                      final index = context
                          .read<CompletedServiceProvider>()
                          .openIssues
                          .indexOf(item);
                      context
                          .read<CompletedServiceProvider>()
                          .removeOpenIssue(index);
                    },
                  ),
                ],
              ),
            ],
          ),
          if (item["U_CK_IssueDesc"] != null &&
              item["U_CK_IssueDesc"].toString().isNotEmpty) ...[
            SizedBox(height: 0.2.h),
            Text(item["U_CK_IssueDesc"],
                style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF64748B),
                    height: 1.4)),
          ],
          if (item["U_CK_Status"] != null &&
              item["U_CK_Status"].toString().isNotEmpty) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text("Status: ${item["U_CK_Status"]}",
                      style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569))),
                ),
                SizedBox(width: 2.w),
                if (item["U_CK_HandledBy"] != null &&
                    item["U_CK_HandledBy"].toString().isNotEmpty)
                  Text("By: ${item["U_CK_HandledBy"]}",
                      style: GoogleFonts.inter(
                          fontSize: 12.sp, color: const Color(0xFF94A3B8))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
