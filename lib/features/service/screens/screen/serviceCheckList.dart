import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/core/widgets/text_remark_dialog.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ServiceCheckListScreen extends StatefulWidget {
  const ServiceCheckListScreen({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  _ServiceCheckListScreenState createState() => _ServiceCheckListScreenState();
}

class _ServiceCheckListScreenState extends State<ServiceCheckListScreen> {
  final remark = TextEditingController();
  int isEditComp = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CompletedServiceProvider>();
      if (provider.checkListLine.isEmpty) {
        final checklist = widget.data["checklistLine"] as List? ?? [];
        provider
            .setCheckList(List<Map<String, dynamic>>.from(checklist.map((e) {
          final map = Map<String, dynamic>.from(e);
          // Map backend status to boolean for Checkbox
          if (map['U_CK_TrueOutput'] == 'Yes') {
            map['U_CK_Checked'] = true;
          } else if (map['U_CK_FalseOutput'] == 'Yes') {
            map['U_CK_Checked'] = false;
          }
          return map;
        })));
      }
    });
  }

  void _showEditFeedback(dynamic item, int index) {
    remark.text = item["U_CK_Feedback"] ?? "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.feedback_rounded,
                  color: const Color(0xFFF59E0B), size: 20.sp),
              SizedBox(width: 3.w),
              Text("Task Feedback",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 17.sp)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item["U_CK_ChecklistTitle"] ?? "Checklist Item",
                style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B)),
              ),
              SizedBox(height: 2.h),
              CustomTextRemarkDialog(
                controller: remark,
                label: 'Comments / Observation',
                star: false,
                detail: false,
              ),
            ],
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
                item["U_CK_Feedback"] = remark.text;
                context
                    .read<CompletedServiceProvider>()
                    .addOrEditOpenCheckList(item, editIndex: index);
                Navigator.of(context).pop();
              },
              
              style: ElevatedButton.styleFrom(
                 minimumSize: const Size(0, 40),
                backgroundColor: const Color(0xFF425364),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Save Feedback",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700,fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  void _showDetail(dynamic data) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: Icon(Icons.assignment_turned_in_rounded,
                          color: Colors.green, size: 20.sp),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        data["U_CK_ChecklistTitle"] ?? "Checklist Detail",
                        style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                const Divider(color: Color(0xFFF1F5F9)),
                _buildRow("Checklist Type", data["U_CK_ChecklistType"]),
                _buildRow("Text Input", data["U_CK_TextInput"]),
                _buildRow("Number Input", data["U_CK_NumInput"]),
                _buildRow("Active",
                    data["U_CK_Active"] == "N" ? "Inactive" : "Active"),
                SizedBox(height: 3.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF475569),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Close",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String title, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(title,
                style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              getDataFromDynamic(value),
              style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
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
        title: Text("Service Checklist",
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
                  child: Text("TASKS & ACTIVITIES",
                      style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.0)),
                ),
                SizedBox(height: 1.5.h),
                Consumer<CompletedServiceProvider>(
                  builder: (context, provider, child) {
                    final items = provider.checkListLine;
                    print(provider);
                    if (items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: Column(
                            children: [
                              Icon(Icons.assignment_late_rounded,
                                  size: 30.sp, color: const Color(0xFFCBD5E1)),
                              SizedBox(height: 1.h),
                              Text("No tasks available",
                                  style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _buildTaskCard(item, index);
                      }).toList(),
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

  Widget _buildTaskCard(dynamic item, int index) {
    bool isChecked = item["U_CK_Checked"] == true;
    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: isChecked
                    ? Colors.green.withOpacity(0.3)
                    : const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.fromLTRB(2.w, 0.5.h, 4.w, 0.h),
                leading: Checkbox(
                  value: isChecked,
                  activeColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  onChanged: (val) {
                    setLocalState(() => isChecked = val!);
                    item["U_CK_Checked"] = val;
                  },
                ),
                title: Text(item["U_CK_ChecklistTitle"] ?? "N/A",
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.3.sp,
                        color: const Color(0xFF1E293B))),
                subtitle: item["U_CK_TextInput"] != null &&
                        item["U_CK_TextInput"].toString().isNotEmpty
                    ? Text(item["U_CK_TextInput"],
                        style: GoogleFonts.inter(
                            fontSize: 13.sp, color: const Color(0xFF64748B)))
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.info_outline_rounded,
                          size: 18.sp, color: const Color(0xFF94A3B8)),
                      onPressed: () => _showDetail(item),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: const Color(0xFFCBD5E1), size: 20.sp),
                  ],
                ),
                onTap: () => _showEditFeedback(item, index),
              ),
              if (item["U_CK_Feedback"] != null &&
                  item["U_CK_Feedback"].toString().isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(14.w, 0, 4.w, 2.h),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 13.sp, color: const Color(0xFFF59E0B)),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          item["U_CK_Feedback"],
                          style: GoogleFonts.inter(
                              fontSize: 12.5.sp,
                              color: const Color(0xFFB45309),
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
