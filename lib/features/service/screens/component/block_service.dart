import 'package:bizd_tech_service/core/utils/helper_utils.dart';

import 'package:bizd_tech_service/features/service/screens/component/service_info_card.dart';
import 'package:bizd_tech_service/features/service/screens/screen/serviceById.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class BlockService extends StatelessWidget {
  const BlockService({super.key, this.onTap, required this.data});
  final VoidCallback? onTap;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final status = data["U_CK_Status"] ?? "Open";
    final isAccept = status == "Accept" || status == "Travel" || status == "Service" || status == "Entry";
    final isTravel = status == "Travel" || status == "Service" || status == "Entry";
    final isService = status == "Service" || status == "Entry";
    final isEntry = status == "Entry";

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // 🔹 Header: Status Stepper
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF425364),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStep(context, Icons.check, isAccept),
                _buildConnector(context, isTravel),
                _buildStep(context, Icons.directions_car, isTravel),
                _buildConnector(context, isService),
                _buildStep(context, Icons.build, isService, isSvg: true, svgAsset: 'images/svg/key.svg'),
                _buildConnector(context, isEntry),
                _buildStep(context, Icons.flag, isEntry),
              ],
            ),
          ),

          // 🔹 Body Content
          Padding(
            padding: const EdgeInsets.all(7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Service Info Card
                ServiceInfoCard(data: data),

                const SizedBox(height: 16),
                 Divider(height: 1, color: Colors.grey.shade200),
                 const SizedBox(height: 8             ),


                // 🔹 Action Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // View Details Button
                    TextButton.icon(
                      onPressed: () {
                         goTo(context, ServiceByIdScreen(data: data));
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF425364)),
                      label: Text(
                        "View Details",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF425364),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        backgroundColor: Colors.transparent,
                      ),
                    ),

                    // Main Action Button
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getActionColor(status),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                         _getActionLabel(status),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String status) {
    if (status == "Accept") return Colors.green;
    if (status == "Travel") return Colors.orange;
    if (status == "Service") return Colors.blue;
    if (status == "Entry") return Colors.purple; // Or a completed color
    return Colors.green; // Default for Pending -> Accept
  }
  
  String _getActionLabel(String status) {
     if (status == "Pending") return "Accept";
     if (status == "Accept") return "Start Travel";
     if (status == "Travel") return "Start Service";
     return "Complete";
  }

  Widget _buildStep(BuildContext context, IconData icon, bool isActive, {bool isSvg = false, String? svgAsset}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? Colors.green : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: isSvg && svgAsset != null
            ? SvgPicture.asset(
                svgAsset,
                width: 16,
                height: 16,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              )
            : Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              ),
      ),
    );
  }

  Widget _buildConnector(BuildContext context, bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? Colors.green : Colors.white.withOpacity(0.2),
      ),
    );
  }
}

