import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MaterialReserveScreen extends StatefulWidget {
  const MaterialReserveScreen({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  _MaterialReserveScreenState createState() => _MaterialReserveScreenState();
}

class _MaterialReserveScreenState extends State<MaterialReserveScreen> {
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
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: Icon(Icons.inventory_2_rounded,
                          color: Colors.blue, size: 20.sp),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        data["U_CK_ItemName"] ?? "Material Detail",
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
                _buildRow("Item Code", data["U_CK_ItemCode"]),
                _buildRow("Brand", data["U_CK_Brand"]),
                _buildRow("Part", data["U_CK_Part"]),
                _buildRow("Quantity", data["U_CK_Qty"]),
                // _buildRow("Warehouse", data["U_CK_WhsCode"]),
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
        title: Text("Material Reserve",
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
                  child: Text("RESERVED MATERIALS",
                      style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.0)),
                ),
                SizedBox(height: 1.5.h),
                Builder(
                  builder: (context) {
                    final items =
                        (widget.data["CK_JOB_MATERIALCollection"] as List?) ??
                            [];
                    if (items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: Column(
                            children: [
                              Icon(Icons.inventory_rounded,
                                  size: 30.sp, color: const Color(0xFFCBD5E1)),
                              SizedBox(height: 1.h),
                              Text("No materials reserved",
                                  style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: items
                          .map((item) => _buildMaterialCard(item))
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

  Widget _buildMaterialCard(dynamic item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
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
        onTap: () => _showDetail(item),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        leading: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: SvgPicture.asset('images/svg/material.svg',
              color: Colors.blue, width: 22.sp, height: 22.sp),
        ),
        title: Text(item["U_CK_ItemName"] ?? "N/A",
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
                color: const Color(0xFF1E293B))),
        subtitle: Text(
            "Qty: ${item["U_CK_Qty"] ?? 0} | Whs: ${item["U_CK_WhsCode"] ?? "N/A"}",
            style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right_rounded,
            color: const Color(0xFFCBD5E1), size: 20.sp),
      ),
    );
  }
}
