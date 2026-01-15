
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StatusStepper extends StatelessWidget {
  const StatusStepper({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    // Determine active states based on the current status
    // Assuming the progression is: Open -> Accept -> Travel -> Service -> Entry (or Completed)
    final isAccept = status == "Accept" || status == "Travel" || status == "Service" || status == "Entry" || status == "Completed";
    final isTravel = status == "Travel" || status == "Service" || status == "Entry" || status == "Completed";
    final isService = status == "Service" || status == "Entry" || status == "Completed";
    final isEntry = status == "Entry" || status == "Completed";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: const Color(0xFF425364),
      width: double.infinity,
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
    );
  }

  Widget _buildStep(BuildContext context, IconData icon, bool isActive, {bool isSvg = false, String? svgAsset}) {
    return Container(
      width: 38, // Slightly larger for better touch target visibility if needed, or stick to 37/32
      height: 38,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : const Color(0xFF425364),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? Colors.green : Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: isSvg && svgAsset != null
            ? SvgPicture.asset(
                svgAsset,
                width: 20, // Adjusted size
                height: 20,
                color: isActive ? Colors.white : Colors.white,
              )
            : Icon(
                icon,
                size: 20,
                color: isActive ? Colors.white : Colors.white,
              ),
      ),
    );
  }

  Widget _buildConnector(BuildContext context, bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: isActive ? Colors.green : Colors.white.withOpacity(0.3),
      ),
    );
  }
}
