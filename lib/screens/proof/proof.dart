// import 'dart:async';
// import 'dart:io';
// import 'package:bizd_tech_service/provider/service_provider.dart';
// import 'package:bizd_tech_service/provider/live_location_provider.dart';
// import 'package:crypto/crypto.dart';
// import 'package:bizd_tech_service/screens/auth/LoginScreen.dart';
// import 'package:bizd_tech_service/provider/auth_provider.dart';
// import 'package:bizd_tech_service/provider/update_status_provider.dart';
// import 'package:bizd_tech_service/screens/signature/signature.dart';
// import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
// import 'package:bizd_tech_service/utilities/dio_client.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:signature/signature.dart';
// import 'package:uuid/uuid.dart';

// class ProofOfDeliveryScreen extends StatefulWidget {
//   ProofOfDeliveryScreen(
//       {super.key, required this.entry, required this.documents});
//   dynamic entry;
//   List<dynamic> documents;
//   @override
//   State<ProofOfDeliveryScreen> createState() => _ProofOfDeliveryScreenState();
// }

// class _ProofOfDeliveryScreenState extends State<ProofOfDeliveryScreen> {
//   final SignatureController _signatureController =
//       SignatureController(penStrokeWidth: 3);
//   late final List<File> _images = [];
//   late List<File> _pdf = [];

//   final DioClient dio = DioClient(); // Your custom Dio client
//   final TextEditingController _remarkController = TextEditingController();

//   // Future<void> _pickImage() async {
//   //   final picker = ImagePicker();
//   //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//   //   if (pickedFile != null) {
//   //     final newFile = File(pickedFile.path);
//   //     final newBytes = await newFile.readAsBytes();
//   //     final newHash = sha256.convert(newBytes).toString();

//   //     bool isDuplicate = false;

//   //     for (final file in _images) {
//   //       final existingBytes = await file.readAsBytes();
//   //       final existingHash = sha256.convert(existingBytes).toString();
//   //       if (existingHash == newHash) {
//   //         isDuplicate = true;
//   //         break;
//   //       }
//   //     }

//   //     if (isDuplicate) {
//   //       showDialog(
//   //         context: context,
//   //         builder: (ctx) => AlertDialog(
//   //           title: const Text("Duplicate Image"),
//   //           content: const Text("This image has already been selected."),
//   //           actions: [
//   //             TextButton(
//   //               onPressed: () => Navigator.of(ctx).pop(),
//   //               child: const Text("OK"),
//   //             ),
//   //           ],
//   //         ),
//   //       );
//   //       return;
//   //     }

//   //     setState(() {
//   //       _images.add(newFile);
//   //     });
//   //   }
//   // }
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();

//     // Show dialog to choose source
//     final ImageSource? source = await showDialog<ImageSource>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(
//               Icons.library_add,
//               size: 18,
//             ),
//             SizedBox(
//               width: 7,
//             ),
//             Text(
//               'Image Option',
//               style: TextStyle(fontSize: 19),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(ImageSource.camera),
//             child: const Text(
//               'Camera',
//               style: TextStyle(fontSize: 15),
//             ),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(ImageSource.gallery),
//             child: const Text(
//               'Gallery',
//               style: TextStyle(fontSize: 15),
//             ),
//           ),
//           // TextButton(
//           //   onPressed: () => Navigator.of(ctx).pop(null),
//           //   child: const Text('Cancel'),
//           // ),
//         ],
//       ),
//     );

//     if (source == null) return; // User canceled

//     final pickedFile = await picker.pickImage(source: source);

//     if (pickedFile != null) {
//       final newFile = File(pickedFile.path);
//       final newBytes = await newFile.readAsBytes();
//       final newHash = sha256.convert(newBytes).toString();

//       bool isDuplicate = false;

//       for (final file in _images) {
//         final existingBytes = await file.readAsBytes();
//         final existingHash = sha256.convert(existingBytes).toString();
//         if (existingHash == newHash) {
//           isDuplicate = true;
//           break;
//         }
//       }

//       if (isDuplicate) {
//         showDialog(
//           context: context,
//           builder: (ctx) => AlertDialog(
//             title: const Text(
//               "Duplicate Image",
//               style: TextStyle(fontSize: 21),
//             ),
//             content: const Text("This image has already been selected."),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(ctx).pop(),
//                 child: const Text("OK"),
//               ),
//             ],
//           ),
//         );
//         return;
//       }

//       setState(() {
//         _images.add(newFile);
//       });
//     }
//   }

//   void _removeImage(int index) {
//     setState(() {
//       _images.removeAt(index);
//     });
//   }

//   Future<void> stopLocationUpdates() async {
//     final dnProvider =
//         Provider.of<DeliveryNoteProvider>(context, listen: false);

//     print(dnProvider.documents.length);
//     if (dnProvider.documents.length == 1) {
//       // final locationProvider =
//       //     Provider.of<LocationProvider>(context, listen: false);
//       // locationProvider.stopTracking();
//     }
//   }

//   // Future<void> onCompletedDelivery() async {
//   //   if (_signatureController.isEmpty) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text('Please provide a signature')),
//   //     );
//   //     return;
//   //   }
//   //   MaterialDialog.loading(context); // Show loading dialog
//   //   await Provider.of<UpdateStatusProvider>(context, listen: false)
//   //       .updateDocumentAndStatus(
//   //           docEntry: widget.entry, status: "Delivered", remarks: "");

//   //   final Uint8List? signature = await _signatureController.toPngBytes();
//   //   final Directory dir = await getApplicationDocumentsDirectory();
//   //   final File sigFile = File('${dir.path}/signature.png');
//   //   await sigFile.writeAsBytes(signature!);
//   //   Navigator.of(context).pop();

//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     const SnackBar(content: Text('POD Submitted Successfully')),
//   //   );
//   // }
//   Future<int?> uploadAttachmentsToSAP(
//       List<File> files, int? existingAttachmentEntry) async {
//     try {
//       final formData = FormData();
//       const uuid = Uuid();

//       for (var file in files) {
//         final extension = file.path.split('.').last;
//         final newFileName = '${uuid.v4()}.$extension';
//         formData.files.add(MapEntry(
//           'file',
//           await MultipartFile.fromFile(
//             file.path,
//             filename: newFileName,
//           ),
//         ));
//       }

//       late Response response;

//       if (existingAttachmentEntry != null) {
//         // PATCH request to update existing
//         response = await dio.patch(
//           '/Attachments2($existingAttachmentEntry)',
//           true,
//           false,
//           data: formData,
//           options: Options(headers: {'Content-Type': 'multipart/form-data'}),
//         );
//       } else {
//         // POST request to create new
//         response = await dio.post(
//           '/Attachments2',
//           false,
//           true,
//           data: formData,
//           options: Options(headers: {'Content-Type': 'multipart/form-data'}),
//         );
//       }

//       if ([200, 201].contains(response.statusCode)) {
//         final absEntry =
//             response.data['AbsEntry'] ?? response.data['AbsoluteEntry'];
//         return absEntry is int ? absEntry : int.tryParse('$absEntry');
//       }

//       if (response.statusCode == 204 && existingAttachmentEntry != null) {
//         return existingAttachmentEntry;
//       }

//       debugPrint(
//           "Upload failed: ${response.statusCode} ${response.statusMessage}");
//     } catch (e, stack) {
//       debugPrint("Upload failed: $e");
//       debugPrint(stack.toString());
//     }

//     return null;
//   }

//   Future<void> onCompletedDelivery() async {
//     if (_pdf.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please provide a signature')),
//       );
//       return;
//     }
//     MaterialDialog.loading(context);

//     try {
//       final deliveryNoteResponse =
//           await dio.get('/DeliveryNotes(${widget.entry})');

//       final existingAttachmentEntry =
//           deliveryNoteResponse.data['AttachmentEntry'];
//       final allFiles = [..._images, ..._pdf];

//       final int? attachmentEntry =
//           await uploadAttachmentsToSAP(allFiles, existingAttachmentEntry);

//       if (attachmentEntry == null) {
//         Navigator.of(context).pop(); // Close loading
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to upload attachments')),
//         );
//         return;
//       }

//       await Provider.of<UpdateStatusProvider>(context, listen: false)
//           .updateDocumentAndStatus(
//         docEntry: widget.entry,
//         status: "Delivered",
//         remarks: _remarkController.text,
//         attachmentEntry: attachmentEntry, context: context, // ✅ Corrected here
//       );
//       await stopLocationUpdates();
//       Navigator.of(context).pop(); // Close loading
//       Navigator.of(context).pop(); // Go back

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('POD Submitted Successfully')),
//       );
//     } catch (e) {
//       Navigator.of(context).pop(); // Close loading
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ Error: $e')),
//       );
//     }
//   }

//   Future<void> _goToSignature() async {
//     final file = await Navigator.push<File?>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SignatureCaptureScreen(
//           prevFile: _pdf.isNotEmpty ? _pdf[0] : null,
//           existingSignature: _pdf.isNotEmpty ? _pdf.first : null,
//         ),
//       ),
//     );

//     if (file != null) {
//       setState(() {
//         _pdf = [file];
//         print(_pdf);
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _signatureController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme:
//             const IconThemeData(color: Colors.white), // 👈 back arrow color
//         backgroundColor: const Color.fromARGB(255, 33, 107, 243),
//         title: const Text(
//           "Proof of Delivery",
//           style: TextStyle(
//               color: Color.fromARGB(255, 255, 255, 255), fontSize: 18),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () async {
//               MaterialDialog.loading(context); // Show loading dialog

//               await Provider.of<AuthProvider>(context, listen: false).logout();

//               Navigator.of(context)
//                   .pop(); // Close loading dialog AFTER logout finishes

//               Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (_) => const LoginScreen()),
//                 (route) => false,
//               );
//             },
//             icon: const Icon(
//               Icons.logout,
//               size: 22,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(
//             width: 12,
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.only(bottom: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 📸 Image Grid
//             Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color.fromARGB(255, 41, 84, 185)
//                           .withOpacity(0.1),
//                       spreadRadius: 2,
//                       blurRadius: 2,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 margin: const EdgeInsets.all(15),
//                 padding: const EdgeInsets.all(5),
//                 height: 258,
//                 child: _images.isEmpty
//                     ? const Center(
//                         child: Icon(
//                           Icons.image,
//                           size: 100,
//                           color: Color.fromARGB(115, 63, 65, 67),
//                         ),
//                       )
//                     : GridView.count(
//                         crossAxisCount: 3,
//                         mainAxisSpacing: 8,
//                         crossAxisSpacing: 8,
//                         children: List.generate(_images.length, (index) {
//                           final file = _images[index];
//                           return Stack(
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   border:
//                                       Border.all(color: Colors.grey.shade300),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.1),
//                                       spreadRadius: 1,
//                                       blurRadius: 5,
//                                       offset: const Offset(2, 2),
//                                     ),
//                                   ],
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.file(file,
//                                       fit: BoxFit.cover,
//                                       width: double.infinity,
//                                       height: double.infinity),
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 4,
//                                 right: 4,
//                                 child: GestureDetector(
//                                   onTap: () => _removeImage(index),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.black.withOpacity(0.5),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     padding: const EdgeInsets.all(4),
//                                     child: const Icon(Icons.close,
//                                         size: 16, color: Colors.white),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           );
//                         }),
//                       )),

//             // ➕ Buttons
//             Container(
//               width: MediaQuery.of(context).size.width,
//               margin: const EdgeInsets.symmetric(horizontal: 15),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     onPressed: _pickImage,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 78, 178, 24),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Row(
//                       children: [
//                         Icon(Icons.add_photo_alternate,
//                             size: 18, color: Colors.white),
//                         SizedBox(width: 5),
//                         Text(
//                           "Add Delivery Image",
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // const SizedBox(width: 15),
//                   ElevatedButton(
//                     onPressed: _goToSignature,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 78, 178, 24),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.edit, size: 18, color: Colors.white),
//                         const SizedBox(width: 5),
//                         Text(
//                           _pdf.isNotEmpty
//                               ? "Edit Signature (${_pdf.length})"
//                               : "Add Signature (${_pdf.length})",
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 15,
//             ),
//             const Center(
//               child: Text(
//                 "Write Note or Comments :",
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 26, 27, 27), fontSize: 15),
//               ),
//             ),

//             // 📝 Remark Field
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               child: TextFormField(
//                 controller: _remarkController,
//                 decoration: InputDecoration(
//                   // hintText: 'Enter remark here...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 maxLines: 6,
//                 keyboardType: TextInputType.multiline,
//                 // onChanged: (value) {
//                 //   print('Remark: $value');
//                 // },
//               ),
//             ),

//             // 📤 Submit Button
//             Container(
//               margin: const EdgeInsets.fromLTRB(17, 0, 17, 0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   onCompletedDelivery();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 78, 178, 24),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Center(
//                   child: Text(
//                     "Complete the Delivery",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
