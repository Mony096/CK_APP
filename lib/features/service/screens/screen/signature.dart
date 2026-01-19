import 'dart:io';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:bizd_tech_service/features/service/screens/signature/signature.dart';
import 'package:bizd_tech_service/features/service/screens/signature/signature_preview_edit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  void _goToSignature() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (builder) => const SignatureCaptureScreen()),
    );
    if (result != null && result is File) {
      if (!mounted) return;
      Provider.of<CompletedServiceProvider>(context, listen: false)
          .setSignature(result);
    }
  }

  void _viewSignature(File? file) {
    if (file == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(
          filePath: file.path,
          title: "Signature Preview",
        ),
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
        title: const Text("Field Signature"),
        centerTitle: true,
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
                SizedBox(height: 5.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5))
                            ]),
                        child: Icon(Icons.gesture_rounded,
                            size: 40.sp, color: const Color(0xFF425364)),
                      ),
                      SizedBox(height: 3.h),
                      Text("Client Acknowledgement",
                          style: GoogleFonts.inter(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B))),
                      SizedBox(height: 1.h),
                      Text(
                          "Please obtain the customer's signature to confirm service completion and satisfaction.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                              height: 1.4)),
                      SizedBox(height: 6.h),
                      Consumer<CompletedServiceProvider>(
                        builder: (context, provider, child) {
                          final signature = provider.signature;
                          if (signature == null) {
                            return SizedBox(
                              width: double.infinity,
                              height: 6.h,
                              child: ElevatedButton.icon(
                                onPressed: _goToSignature,
                                icon: const Icon(Icons.edit_note_rounded),
                                label: Text("Provide Signature",
                                    style: GoogleFonts.inter(
                                        fontSize: 15.5.sp,
                                        fontWeight: FontWeight.w700)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF425364),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  elevation: 0,
                                ),
                              ),
                            );
                          }

                          // If signature exists, show preview concept
                          final isPDF =
                              signature.path.toLowerCase().endsWith('.pdf');
                          final isPNG =
                              signature.path.toLowerCase().endsWith('.png');

                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () => _viewSignature(signature),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(6.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4))
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      if (isPDF)
                                        Column(
                                          children: [
                                            Icon(Icons.picture_as_pdf_rounded,
                                                size: 35.sp,
                                                color: Colors.redAccent),
                                            SizedBox(height: 2.h),
                                            Text("digital_signature.pdf",
                                                style: GoogleFonts.inter(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                        0xFF475569))),
                                            SizedBox(height: 1.h),
                                            Text("Tap to View Full Preview",
                                                style: GoogleFonts.inter(
                                                    fontSize: 12.sp,
                                                    color: Colors.blue,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ],
                                        )
                                      else if (isPNG)
                                        Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.file(signature,
                                                  fit: BoxFit.contain,
                                                  height: 120.sp,
                                                  width: double.infinity),
                                            ),
                                            SizedBox(height: 1.h),
                                            Text("digital_signature.png",
                                                style: GoogleFonts.inter(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                        0xFF475569))),
                                          ],
                                        )
                                      else
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(signature,
                                              fit: BoxFit.contain),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          provider.removeSignature(),
                                      icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.red),
                                      label: Text("Clear",
                                          style: GoogleFonts.inter(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600)),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 1.5.h),
                                        side:
                                            const BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _goToSignature,
                                      icon: const Icon(Icons.edit_rounded),
                                      label: const Text("Resign"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF425364),
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 1.5.h),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
