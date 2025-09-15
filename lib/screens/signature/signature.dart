import 'dart:typed_data';
import 'package:bizd_tech_service/main.dart';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/screens/signature/signature_preview_edit.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

Future<bool> _requestPermission() async {
  if (await Permission.storage.request().isGranted) {
    return true;
  }
  return false;
}

class SignatureCaptureScreen extends StatefulWidget {
  final File? existingSignature;
  final File? prevFile;

  const SignatureCaptureScreen(
      {super.key, this.existingSignature, this.prevFile});

  @override
  _SignatureCaptureScreenState createState() => _SignatureCaptureScreenState();
}

class _SignatureCaptureScreenState extends State<SignatureCaptureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _isLandscape = false;

  Future<void> _exportAsPDF() async {
    try {
      final Uint8List? imageBytes = await _controller.toPngBytes();
      if (imageBytes == null) return;

      final pdf = pw.Document();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image));
          },
        ),
      );

      final outputDir = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : Directory('/storage/emulated/0/Download');

      final file = File(
        '${outputDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      await file.writeAsBytes(await pdf.save());

      Navigator.pop(context, file); // 👈 Return the file to the previous screen
    } catch (e) {
      print('PDF generation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to export PDF")),
      );
    }
  }

  void _toggleOrientation() async {
    setState(() {
      _isLandscape = !_isLandscape;
    });

    if (_isLandscape) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Colors.white), // 👈 back arrow color
        backgroundColor: const Color.fromARGB(255, 66, 83, 100),
        title: const Text(
          "Signature Capture",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255), fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          widget.prevFile != null && widget.prevFile!.existsSync()
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PDFViewerScreen(filePath: widget.prevFile!.path),
                      ),
                    );
                  },
                  icon: const Icon(Icons.remove_red_eye, size: 22),
                )
              : const SizedBox.shrink(),
// returns empty widget

          IconButton(
            onPressed: _toggleOrientation,
            icon: const Icon(Icons.screen_rotation, size: 22),
          ),
          IconButton(
            onPressed: () async {
              MaterialDialog.loading(context); // Show loading dialog

              await Provider.of<AuthProvider>(context, listen: false).logout();

              Navigator.of(context)
                  .pop(); // Close loading dialog AFTER logout finishes

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, size: 22),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: isLandscape ? 1 : 3,
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.grey[200]!,
            ),
          ),
          // SizedBox(height: 10),
          isLandscape ? const SizedBox(height: 5) : const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _controller.clear(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Clear",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _exportAsPDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 78, 178, 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Save Signature",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          isLandscape ? const SizedBox(height: 5) : const SizedBox(height: 50),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
