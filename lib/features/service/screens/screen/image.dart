import 'dart:io';
import 'package:bizd_tech_service/features/service/screens/component/service_info_card.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  Future<void> pickImage() async {
    final picker = ImagePicker();

    // Show dialog to choose source
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Row(
          children: [
            // SizedBox(width: 15),
            // Icon(
            //   Icons.add_box,
            //   size: 25,
            //   color: Color.fromARGB(255, 118, 121, 123),
            // ),
            // SizedBox(width: 15),
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.042,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: Colors.blue,
                size: 25,
              ),
              title: Text(
                "Take Photo",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.038),
              ),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Colors.green,
                size: 25,
              ),
              title: Text("Choose from Gallery",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.038)),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return; // User canceled

    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final newFile = File(pickedFile.path);
      final newBytes = await newFile.readAsBytes();
      final newHash = sha256.convert(newBytes).toString();

      bool isDuplicate = false;
      final provider = context.read<CompletedServiceProvider>();

      for (final file in provider.imagesList) {
        final existingBytes = await file.readAsBytes();
        final existingHash = sha256.convert(existingBytes).toString();
        if (existingHash == newHash) {
          isDuplicate = true;
          break;
        }
      }

      if (isDuplicate) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text(
              "Duplicate Image",
              style: TextStyle(fontSize: 21),
            ),
            content: const Text("This image has already been selected."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }
      Provider.of<CompletedServiceProvider>(context, listen: false)
          .setImages([newFile]); // Pass as list

      // setState(() {
      //   _images.add(newFile);
      // });
      // print(provider.imagesList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        backgroundColor: const Color(0xFF425364),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Image',
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
                // Status Stepper
                StatusStepper(status: widget.data["U_CK_Status"] ?? "Open"),
                
                const SizedBox(height: 10),
                const SizedBox(
                  height: 5,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    children: [
                       // Service Info Card
                       ServiceInfoCard(data: widget.data),
                       const SizedBox(height: 16),
                       
                       // Menu (Upload Button)
                       Menu(
                        onTap: pickImage,
                        title: 'Upload Image',
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: SvgPicture.asset(
                            'images/svg/image.svg', 
                             width: 30, height: 30, 
                             colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)
                          ),
                        ),
                       ),
                       const SizedBox(height: 16),
                       
                       // Image Show
                       ImageShow(
                        image: context.watch<CompletedServiceProvider>().imagesList
                       ),
                       const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}

class Menu extends StatefulWidget {
  const Menu({super.key, this.icon, required this.title, this.onTap});
  final dynamic icon;
  final VoidCallback? onTap;
  final String title;
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
           BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
           ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: widget.icon),
          Expanded(
              flex: 4,
              child: Text(widget.title,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.blueGrey.shade800
                  ),
            )),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: widget.onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                "Add Image",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageShow extends StatefulWidget {
  const ImageShow({
    super.key,
    required this.image,
  });
  final List<dynamic> image;
  @override
  State<ImageShow> createState() => _ImageShowState();
}

class _ImageShowState extends State<ImageShow> {
  void _removeImage(int index) {
    setState(() {
      widget.image.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 41, 84, 185).withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(5),
        height: 265,
        child: widget.image.isEmpty
            ? const Center(
                child: Icon(
                  Icons.image,
                  size: 100,
                  color: Color.fromARGB(115, 63, 65, 67),
                ),
              )
            : GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(widget.image.length, (index) {
                  final file = widget.image[index];
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(2, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(file,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ));
  }
}
