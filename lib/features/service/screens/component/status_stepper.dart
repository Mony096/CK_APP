import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StatusStepper extends StatelessWidget {
  const StatusStepper({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    // Progress logic
    final isAccept = ["Accept", "Travel", "Service", "Entry"].contains(status);
    final isTravel = ["Travel", "Service", "Entry"].contains(status);
    final isService = ["Service", "Entry"].contains(status);
    final isEntry = status == "Entry";

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStep(Icons.check_rounded, isAccept),
          _buildConnector(isTravel),
          _buildStep(Icons.directions_car_rounded, isTravel),
          _buildConnector(isService),
          _buildStep(Icons.build_rounded, isService),
          _buildConnector(isEntry),
          _buildStep(Icons.flag_rounded, isEntry),
        ],
      ),
    );
  }

  Widget _buildStep(IconData icon, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width:9.w,
      height: 9.w,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF22C55E) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1),
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF22C55E).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Icon(
        icon,
        size: 15.sp,
        color: isActive ? Colors.white : const Color(0xFFCBD5E1),
      ),
    );
  }

  Widget _buildConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
