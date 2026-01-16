import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:typed_data';

class PDFViewerScreen extends StatelessWidget {
  final String? filePath;
  final Uint8List? memoryData;
  final String title;

  const PDFViewerScreen({
    Key? key,
    this.filePath,
    this.memoryData,
    this.title = "Document Viewer",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: memoryData != null
          ? SfPdfViewer.memory(memoryData!)
          : filePath != null
              ? SfPdfViewer.file(File(filePath!))
              : const Center(child: Text("No document to display")),
    );
  }
}
