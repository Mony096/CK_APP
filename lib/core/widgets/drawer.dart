import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DrawerItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int? badgeCount;

  const DrawerItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badgeCount,
  });
}

class ModernDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<DrawerItem> items;
  final String userName;
  final String userEmail;

  const ModernDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    required this.userName,
    required this.userEmail,
  });

  // --- Design System (Clean & Modern) ---
  static const Color primaryColor = Color(0xFF2563EB); // Royal Blue
  static const Color bgColor = Colors.white;
  static const Color headerBg = Color(0xFFF8FAFC);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subTextColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 82.w,
      backgroundColor: bgColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(child: _buildMenu(context)),
          _buildFooter(),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24.sp,
        MediaQuery.of(context).padding.top + 20.sp,
        24.sp,
        28.sp,
      ),
      decoration: const BoxDecoration(
        color: headerBg,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Color(0xFF10B981).withOpacity(0.12), width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 24.sp,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_rounded,
                    size: 26.sp,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.settings_rounded,
                    color: subTextColor, size: 18),
              ),
            ],
          ),
          SizedBox(height: 18.sp),
          Text(
            userName,
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4.sp),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981), // Solid Emerald
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  userEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: subTextColor,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= MENU =================
Widget _buildMenu(BuildContext context) {
  return ListView.builder(
    padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 15.sp),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      final isSelected = selectedIndex == index;

      return Padding(
        padding: EdgeInsets.only(bottom: 6.sp),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            onItemSelected(index);
            Navigator.pop(context);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(
              horizontal: 12.sp,
              vertical: 14.5.sp,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? Color(0xFF10B981).withOpacity(0.08)
                  : Colors.transparent,

              // LEFT ACTIVE ACCENT + SHADOW
              // boxShadow: isSelected
              //     ? [
              //         BoxShadow(
              //           color: Color(0xFF10B981).withOpacity(0.50),
              //           blurRadius: 12,
              //           offset: const Offset(0, 5),
              //         ),
              //       ]
              //     : [],
              border: isSelected
                  ? Border(
                      left: BorderSide(
                        color: Color(0xFF10B981),
                        width: 4,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 20.sp,
                  color: isSelected ? Color(0xFF10B981) : subTextColor,
                ),
                SizedBox(width: 16.sp),
                Expanded(
                  child: Text(
                    item.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5.sp,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Color(0xFF10B981)
                          : textColor.withOpacity(0.8),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18.sp,
                    color: Color(0xFF10B981).withOpacity(0.4),
                  )
                else if (item.badgeCount != null &&
                    item.badgeCount! > 0)
                  _buildBadge(item.badgeCount!),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildBadge(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 2.sp),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        count.toString(),
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFFEF4444),
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ================= FOOTER =================
  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.sp, 16.sp, 24.sp, 24.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BIZD Tech Service',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: textColor.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 2.sp),
          Text(
            'Version 1.0.4',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
