import 'package:bizd_tech_service/screens/auth/login_screen_v2.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';

class PDFViewerScreen extends StatelessWidget {
  final String filePath;

  const PDFViewerScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Colors.white), // 👈 back arrow color
        backgroundColor: const Color.fromARGB(255, 66, 83, 100),
        title: const Text(
          "Signature Here",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255), fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              MaterialDialog.loading(context); // Show loading dialog

              await Provider.of<AuthProvider>(context, listen: false).logout();

              Navigator.of(context)
                  .pop(); // Close loading dialog AFTER logout finishes

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreenV2()),
                (route) => false,
              );
            },
            icon: Icon(Icons.logout, size: 22),
          ),
          SizedBox(width: 12),
        ],
      ),
      body: SfPdfViewer.file(File(filePath)),
    );
  }
}
