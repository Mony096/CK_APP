import 'package:bizd_tech_service/features/service/screens/component/row_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.title,
    required this.rows,
    required this.svg,
  });

  final String title;
  final List<RowItem> rows;
  final Widget svg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              width: 6.w,
              height: 6.w,
              child: svg,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5.sp,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 1.5.h),
                ...rows.map((row) => Padding(
                      padding: EdgeInsets.only(bottom: 1.5.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              row.left,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: const Color(0xFF475569),
                                height: 1.2,
                                fontWeight: FontWeight.w500,
                              ),
                              textScaler: const TextScaler.linear(1.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (row.right != null)
                            Padding(
                              padding: EdgeInsets.only(left: 3.w, right: 3.w),
                              child: row.isRightIcon
                                  ? SizedBox(
                                      height: 15
                                          .sp, // Constrain height to text height range
                                      child: (row.right is Widget
                                          ? row.right
                                          : Text(row.right.toString())),
                                    )
                                  : Flexible(
                                      child: Text(
                                        row.right.toString(),
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.inter(
                                          fontSize: 13.sp,
                                          color: const Color.fromARGB(
                                              255, 91, 99, 113),
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                        ),
                                        textScaler:
                                            const TextScaler.linear(1.0),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                            ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
