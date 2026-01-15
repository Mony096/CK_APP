
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceInfoCard extends StatelessWidget {
  const ServiceInfoCard({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
       decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
                ),
    
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Ticket ID & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Ticket #${data["DocNum"]}",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    "${data["U_CK_Time"] ?? "--:--"} - ${data["U_CK_EndTime"] ?? "--:--"}",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
      
          // Customer Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle
                ),
                child: const Icon(Icons.person, color: Colors.green, size: 18)
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["CustomerName"] ?? "Unknown Customer",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ((data["CustomerAddress"] as List?)?.isNotEmpty == true)
                          ? (data["CustomerAddress"].first["StreetNo"] ?? "No Address")
                          : "No Address Available",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
      
          // Job & Equipment Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200)
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.work_outline, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      "Job Type: ",
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    Text(
                      "${data["U_CK_JobType"] ?? "N/A"}",
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.build_circle_outlined, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      "SN: ",
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    Text(
                      (data["CK_JOB_EQUIPMENTCollection"] as List?)?.isNotEmpty == true
                       ? (data["CK_JOB_EQUIPMENTCollection"].first["U_CK_SerialNum"]?.toString().isEmpty ?? true
                           ? "N/A"
                           : data["CK_JOB_EQUIPMENTCollection"].first["U_CK_SerialNum"])
                       : "N/A",
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
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
}
