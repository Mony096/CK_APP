import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:bizd_tech_service/features/service/screens/screen/serviceById.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BlockService extends StatelessWidget {
  const BlockService({super.key, this.onTap, required this.data});
  final VoidCallback? onTap;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final status = data["U_CK_Status"] ?? "Pending";
    final docNum = data["DocNum"] ?? "N/A";
    final customerName = data["CustomerName"] ?? "Unknown Customer";
    final dateStr = data["U_CK_Date"]?.split("T")[0] ?? "";
    final address = (data["CustomerAddress"] as List?)?.isNotEmpty == true
        ? data["CustomerAddress"].first["StreetNo"] ?? "No Address"
        : "No Address";
    final jobType = data["U_CK_JobType"] ?? "Service";
    final startTime = data["U_CK_Time"] ?? "--:--";
    final endTime = data["U_CK_EndTime"] ?? "--:--";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      width: double.infinity,
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
          // 1. Header (Doc Num, Job Type & Status Badge)
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
            child: Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
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
                SizedBox(width: 2.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF9C3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFDE047)),
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
                const Spacer(),
                _buildStatusBadge(status),
              ],
            ),
          ),

          // 2. Customer Info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.4.h),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 14.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        address,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 1.5.h),

          // 3. Status Stepper
          StatusStepper(status: status),

          // 4. Details Row (Date & Time)
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoLabel("DATE"),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 14.sp, color: const Color(0xFF425364)),
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
                  height: 3.h,
                  width: 1,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  color: const Color(0xFFF1F5F9),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoLabel("SCHEDULED TIME"),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Icon(Icons.access_time_filled_rounded,
                              size: 14.sp, color: const Color(0xFF425364)),
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
          ),

          Divider(height: 1, color: const Color(0xFFF1F5F9)),

          // 5. Footer Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    goTo(context, ServiceByIdScreen(data: data));
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "View Details",
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 17.sp),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getActionColor(status),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 40),
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _getActionLabel(status),
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10.5.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF94A3B8),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label = status;

    switch (status) {
      case "Pending":
        color = const Color(0xFF3B82F6);
        break;
      case "Accept":
        color = const Color(0xFF22C55E);
        label = "Accepted";
        break;
      case "Travel":
        color = const Color(0xFFF59E0B);
        label = "Traveling";
        break;
      case "Service":
        color = const Color(0xFF8B5CF6);
        label = "On Site";
        break;
      case "Entry":
        color = const Color(0xFF64748B);
        label = "Finalized";
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 1.5.w),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
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
        return "ACCEPT";
      case "Accept":
        return "START TRAVEL";
      case "Travel":
        return "ON SITE";
      case "Service":
        return "CONTINUE";
      default:
        return "VIEW";
    }
  }
}
