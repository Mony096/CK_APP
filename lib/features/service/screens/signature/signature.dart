import 'package:bizd_tech_service/features/service/screens/signature/signature_preview_edit.dart';
import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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

  Future<void> _exportAsPNG() async {
    try {
      final Uint8List? imageBytes = await _controller.toPngBytes();
      if (imageBytes == null) return;

      // Save directly as PNG (no PDF wrapper)
      final outputDir = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : Directory('/storage/emulated/0/Download');

      final file = File(
        '${outputDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(imageBytes); // Save PNG bytes directly

      Navigator.pop(context, file); // 👈 Return the PNG file to the previous screen
    } catch (e) {
      print('PNG export error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to export PNG")),
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

    return SafeArea(
      top: false,
      child: Scaffold(
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
                  MaterialPageRoute(builder: (_) => const LoginScreenV2()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, size: 22),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: Container(
          color: const Color(0xFFF1F5F9), // Light grey background
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 40 : 24,
                      vertical: isLandscape ? 20 : 40,
                    ),
                    child: AspectRatio(
                      aspectRatio: isLandscape ? 16 / 9 : 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF425364),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Signature(
                            controller: _controller,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: isLandscape ? 12 : 16,
                  horizontal: 20,
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _controller.clear(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(
                              vertical: isLandscape ? 12 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.clear_rounded, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Clear",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _exportAsPNG,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 78, 178, 24),
                            padding: EdgeInsets.symmetric(
                              vertical: isLandscape ? 12 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Save Signature",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
