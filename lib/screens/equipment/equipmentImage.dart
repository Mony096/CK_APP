import 'dart:convert';
import 'dart:io';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/provider/equipment_create_provider.dart';
import 'package:bizd_tech_service/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class EquipmentImageScreen extends StatefulWidget {
  const EquipmentImageScreen({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  _EquipmentImageScreenState createState() => _EquipmentImageScreenState();
}

class _EquipmentImageScreenState extends State<EquipmentImageScreen> {
  final DioClient dio = DioClient(); // Your custom Dio client

  Future<void> _downloadImage() async {
    MaterialDialog.loading(context);

    try {
      List<File> sapFiles = [];
      final attachmentEntry = widget.data["U_ck_AttachmentEntry"];
      final offlineProvider =
          Provider.of<EquipmentOfflineProvider>(context, listen: false);

      if (attachmentEntry != null) {
        final attachmentRes =
            await dio.getAttachment("/Attachments2($attachmentEntry)");

        if (attachmentRes.statusCode == 200) {
          final attData = attachmentRes.data;
          final lines = attData["Attachments2_Lines"] as List<dynamic>;
          final token = await LocalStorageManger.getString('SessionId');

          for (var line in lines) {
            final url =
                "/Attachments2(${line["AbsoluteEntry"]})/\$value?filename='${line["FileName"]}.${line["FileExtension"]}'";

            try {
              final imgRes = await http.get(
                Uri.parse(
                    "https://svr10.biz-dimension.com:9093/api/sapIntegration/Attachments2"),
                headers: {
                  'Content-Type': "application/json",
                  "Authorization": 'Bearer $token',
                  'sapUrl': url,
                },
              );

              if (imgRes.statusCode == 200) {
                final tempDir = await getTemporaryDirectory();
                final fileName = "${line["FileName"]}.${line["FileExtension"]}";
                final filePath = "${tempDir.path}/$fileName";
                final file = File(filePath);

                await file.writeAsBytes(imgRes.bodyBytes);
                sapFiles.add(file);
              } else {
                String errorMessage = "Unknown error";
                try {
                  final decoded = jsonDecode(imgRes.body);
                  if (decoded is Map && decoded.containsKey("error")) {
                    errorMessage =
                        decoded["error"]["message"]["value"].toString();
                  }
                } catch (_) {
                  errorMessage = imgRes.body;
                }

                await MaterialDialog.warning(
                  context,
                  title: "Error",
                  body: "Failed to fetch image: $errorMessage",
                );
              }
            } catch (e) {
              print("Failed to fetch image ${line["FileName"]}: $e");
            }
          }

          if (sapFiles.isNotEmpty) {
            // Convert files to base64
            List<Map<String, String>> fileDataList = [];
            for (File file in sapFiles) {
              fileDataList.add(await fileToBase64WithExt(file));
            }

            // Update equipment offline provider
            final updatedPayload = {
              ...widget.data,
              "files": fileDataList,
            };

            await offlineProvider.updateEquipment(updatedPayload);

            // ✅ Update widget and provider immediately
            setState(() {
              widget.data["files"] = fileDataList;
              offlineProvider.setImages(sapFiles);
            });
            await offlineProvider.loadEquipments();
            print("Updated equipment with ${fileDataList.length} files");
          }
        }
      } else {
        throw Exception(
            "No images available for this equipment (${widget.data["Code"]})");
      }
    } catch (e) {
      if (mounted) MaterialDialog.close(context);

      await MaterialDialog.warning(
        context,
        title: "Error",
        body: e.toString(),
      );
    } finally {
      if (mounted) MaterialDialog.close(context);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    // Show dialog to choose source
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Row(
          children: [
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
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
              title: const Text(
                "Take Photo",
                style: TextStyle(fontSize: 16),
              ),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Colors.green,
                size: 25,
              ),
              title: const Text("Choose from Gallery",
                  style: TextStyle(fontSize: 16)),
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
      final provider = context.read<EquipmentOfflineProvider>();

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
      Provider.of<EquipmentOfflineProvider>(context, listen: false)
          .addImages([newFile]); // Pass as list

      // setState(() {
      //   _images.add(newFile);
      // });
      // print(provider.imagesList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 238, 240),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 83, 100),
        // Leading menu icon on the left
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        // Centered title
        title: const Center(
          child: Text(
            'Equipment Image',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        // Right-aligned actions (scan barcode)
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // refresh();
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
              // SizedBox(width: 3),
              // IconButton(
              //   onPressed: () async {
              //     MaterialDialog.loading(context);
              //     await Provider.of<AuthProvider>(context, listen: false)
              //         .logout();
              //     Navigator.of(context).pop();
              //     Navigator.of(context).pushAndRemoveUntil(
              //       MaterialPageRoute(builder: (_) => const LoginScreen()),
              //       (route) => false,
              //     );
              //   },
              //   icon: const Icon(Icons.logout, color: Colors.white),
              // )
            ],
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
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                    // color: const Color.fromARGB(255, 255, 255, 255),

                    borderRadius: BorderRadius.circular(5.0), // Rounded corners
                  ),
                  child: ListView(children: [
                    Menu(
                      data: widget.data,
                      onTap: () {
                        if (widget.data.isEmpty) {
                          // Handle add image
                          pickImage();
                        } else if (!widget.data.containsKey("sync_status")) {
                          // ✅ Call your download function
                          _downloadImage();
                        } else {
                          // Handle normal case (Equipment Photos)
                        }
                      },
                      title: 'Upload Image',
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: SvgPicture.asset(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          'images/svg/image.svg',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    ImageShow(
                        data: widget.data,
                        image: context
                            .watch<EquipmentOfflineProvider>()
                            .imagesList)
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
  const Menu(
      {super.key,
      this.icon,
      required this.title,
      this.onTap,
      required this.data});
  final dynamic icon;
  final VoidCallback? onTap;
  final String title;
  final Map<String, dynamic> data;
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(13),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon

            // Title (will take remaining space automatically if wrapped in Flexible)
            Flexible(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: widget.icon,
                  ),
                  Text(
                    widget.title,
                    style:  TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.032,
                    ),
                    overflow: TextOverflow.ellipsis, // avoid overflow
                    textScaleFactor: 1.0,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8), // spacing between text and button

            // Button
            TextButton(
              onPressed: widget.onTap,
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: Text(
                widget.data.isEmpty
                    ? "Add Image"
                    : (widget.data.containsKey("sync_status")
                        ? "Equipment Image"
                        : "Download Image"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.031,
                ),
              ),
            ),
          ],
        ));
  }
}

class ImageShow extends StatefulWidget {
  const ImageShow({
    super.key,
    required this.image,
    required this.data,
  });
  final List<dynamic> image;
  final Map<String, dynamic> data;

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
      child: widget.image.isEmpty
          ? SizedBox(
              height: 300,
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 100,
                  color: Color.fromARGB(115, 63, 65, 67),
                ),
              ),
            )
          : GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              shrinkWrap: true, // 👈 makes height auto-fit
              physics:
                  const NeverScrollableScrollPhysics(), // 👈 disable inner scroll
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
                        child: Image.file(
                          file,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 300,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: widget.data.isEmpty
                          ? GestureDetector(
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
                            )
                          : Container(),
                    ),
                  ],
                );
              }),
            ),
    );
  }
}
