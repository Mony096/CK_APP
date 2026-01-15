import 'dart:io';

import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/core/providers/helper_provider.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:bizd_tech_service/features/service/screens/component/service_info_card.dart';
import 'package:bizd_tech_service/features/service/screens/signature/signature.dart';
import 'package:bizd_tech_service/features/service/screens/signature/signature_preview_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  @override
  // late List<File> _pdf = [];
  final SignatureController _signatureController =
      SignatureController(penStrokeWidth: 3);
  Future<void> _goToSignature() async {
    final provider = context.read<CompletedServiceProvider>();

    final file = await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder: (_) => SignatureCaptureScreen(
          prevFile: provider.signatureList.isNotEmpty
              ? provider.signatureList[0]
              : null,
          existingSignature: provider.signatureList.isNotEmpty
              ? provider.signatureList.first
              : null,
        ),
      ),
    );

    if (file != null) {
      setState(() {
        provider.setSignature(file);
        print(provider.signatureList);
      });
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF425364),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Signature',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                StatusStepper(status: widget.data["U_CK_Status"] ?? "Open"),
                const SizedBox(
                  height: 5,
                ),
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                    // color: const Color.fromARGB(255, 255, 255, 255),

                    borderRadius: BorderRadius.circular(5.0), // Rounded corners
                  ),
                  child: ListView(children: [
                    ServiceInfoCard(data: widget.data),
/////endddddddddddddddddddddddddddddd
                    const SizedBox(
                      height: 10,
                    ),
                    Menu(
                        signature: context
                            .read<CompletedServiceProvider>()
                            .signatureList,
                        title: 'Upload Signature',
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: SvgPicture.asset(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            'images/svg/signature.svg',
                            width: 30,
                            height: 30,
                          ),
                        ),
                        onTap: _goToSignature),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(13),
                      color: Colors.white,
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              flex: 5,
                              child: Text(
                                  context
                                          .read<CompletedServiceProvider>()
                                          .signatureList
                                          .isNotEmpty
                                      ? "Signature Captured Successfully"
                                      : "Opps, Not Signature yet",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                  textScaleFactor: 1.0)),
                          Expanded(
                            flex: 2,
                            child: TextButton(
                              onPressed: () {
                                final provider =
                                    context.read<CompletedServiceProvider>();

                                if (provider.signatureList.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PDFViewerScreen(
                                        filePath:
                                            provider.signatureList.isNotEmpty
                                                ? provider.signatureList[0].path
                                                : '',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: context
                                        .read<CompletedServiceProvider>()
                                        .signatureList
                                        .isNotEmpty
                                    ? Colors.green
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: const Text(
                                "View",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    /////do somthing
                  ]),
                )),
              ],
            )),
      ),
    );
  }
}

class Menu extends StatefulWidget {
  const Menu({
    super.key,
    this.icon,
    required this.title,
    this.onTap,
    required this.signature,
  });

  final Widget? icon;
  final String title;
  final VoidCallback? onTap;
  final List<dynamic> signature;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
           BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
           ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            widget.icon!,
            const SizedBox(width: 12),
          ],
          
          Expanded(
            child: Text(
              widget.title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.blueGrey.shade800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: widget.onTap,
            child: Text(
              widget.signature.isNotEmpty ? "Edit" : "Add",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
