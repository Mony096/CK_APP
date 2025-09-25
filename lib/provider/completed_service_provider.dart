import 'dart:convert';
import 'dart:io';

import 'dart:io';

import 'package:bizd_tech_service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CompletedServiceProvider extends ChangeNotifier {
  bool _submit = false;
  List<dynamic> _openIssues = [];
  List<dynamic> _imagesList = [];
  List<dynamic> _signatureList = [];
  List<dynamic> _timeEntry = [];
  List<dynamic> _checkListLine = [];

  bool get submit => _submit;
  List<dynamic> get openIssues => _openIssues;
  List<dynamic> get imagesList => _imagesList;
  List<dynamic> get signatureList => _signatureList;
  List<dynamic> get timeEntry => _timeEntry;
  List<dynamic> get checkListLine => _checkListLine;
  final DioClient dio = DioClient(); // Custom Dio wrapper

  void addOrEditOpenIssue(Map<String, dynamic> item, {int editIndex = -1}) {
    if (editIndex == -1) {
      _openIssues.add(item);
    } else {
      _openIssues[editIndex] = item;
    }
    notifyListeners();
  }

  void addOrEditOpenCheckList(Map<String, dynamic> item, {int editIndex = -1}) {
    if (editIndex >= 0) {
      // Edit existing checklist
      _checkListLine[editIndex] = item;
    } else {
      // Add new checklist
      _checkListLine.add(item);
    }
    notifyListeners();
  }

  void setCheckList(List<dynamic> collection) {
    _checkListLine = collection;
    notifyListeners();
  }

  void addOrEditTimeEntry(Map<String, dynamic> item, {int editIndex = -1}) {
    // Calculate durations
    item['total_travel_time'] = calculateSpentTime(
      (item['U_CK_TraveledTime']).split(" ")[0],
      item['U_CK_TraveledEndTime'].split(" ")[0],
    );
    item['total_service_time'] = calculateSpentTime(
      item['U_CK_ServiceStartTime'].split(" ")[0],
      item['U_CK_SerEndTime'].split(" ")[0],
    );
    item['total_break_time'] = calculateSpentTime(
      item['U_CK_BreakTime'].split(" ")[0],
      item['U_CK_BreakEndTime'].split(" ")[0],
    );
    print(timeEntry);
    if (editIndex == -1) {
      _timeEntry = [item];
    } else {
      _timeEntry[editIndex] = item;
    }

    notifyListeners();
  }

  String calculateSpentTime(String start, String end) {
    try {
      final now = DateTime.now();
      final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

      // Use today's date dynamically
      final dateString = DateFormat("yyyy-MM-dd").format(now);
      final startTime = dateFormat.parse("$dateString $start:00");
      var endTime = dateFormat.parse("$dateString $end:00");

      // Handle overnight time (end < start)
      if (endTime.isBefore(startTime)) {
        endTime = endTime.add(const Duration(days: 1));
      }

      final duration = endTime.difference(startTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);

      return "${hours}h ${minutes}m";
    } catch (e) {
      // Return empty string or a default value if parsing fails
      print("Error calculating spent time: $e");
      return "0h 0m";
    }
  }

  void setImages(List<File> images) {
    _imagesList.addAll(images);
    // Correct for single file
    notifyListeners();
  }

  void setSignature(File signature) {
    _signatureList = [signature];
    // Correct for single file
    notifyListeners();
  }

  void setTimeEntry(File timeEntry) {
    _timeEntry = [timeEntry];
    // Correct for single file
    notifyListeners();
  }

  void setOpenIssues(List<dynamic> collection) {
    _openIssues = collection;
    notifyListeners();
  }

  void clearCollection() {
    _openIssues = [];
    notifyListeners();
  }

  // void addOrEditPart(Map<String, dynamic> item, {int editIndex = -1}) {
  //   if (editIndex == -1) {
  //     _parts.add(item);
  //   } else {
  //     _parts[editIndex] = item;
  //   }
  //   notifyListeners();
  // }

  void removeOpenIssue(int index) {
    if (index >= 0 && index < _openIssues.length) {
      _openIssues.removeAt(index);
      notifyListeners();
    }
  }

  void clearData() {
    _openIssues = [];
    _imagesList = [];
    _signatureList = [];
    _timeEntry = [];
    notifyListeners();
  }

  void clearOpenIssues() {
    _openIssues.clear();
    notifyListeners();
  }

  Future<int?> uploadAttachmentsToSAP(
      List<File> files, int? existingAttachmentEntry) async {
    // print(existingAttachmentEntry);
    // return 0;
    try {
      final formData = FormData();
      const uuid = Uuid();

      for (var file in files) {
        final extension = file.path.split('.').last;
        final newFileName = '${uuid.v4()}.$extension';
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(
            file.path,
            filename: newFileName,
          ),
        ));
      }

      late Response response;
      if (existingAttachmentEntry != null) {
        // PATCH request to update existing
        response = await dio.patch(
          '/Attachments2($existingAttachmentEntry)',
          true,
          false,
          data: formData,
          options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        );
      } else {
        // POST request to create new
        response = await dio.post(
          '/Attachments2',
          false,
          true,
          data: formData,
          options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        );
      }

      if ([200, 201].contains(response.statusCode)) {
        final absEntry =
            response.data['AbsEntry'] ?? response.data['AbsoluteEntry'];
        return absEntry is int ? absEntry : int.tryParse('$absEntry');
      }

      if (response.statusCode == 204 && existingAttachmentEntry != null) {
        return existingAttachmentEntry;
      }

      debugPrint(
          "Upload failed: ${response.statusCode} ${response.statusMessage}");
    } catch (e, stack) {
      debugPrint("Upload failed: $e");
      debugPrint(stack.toString());
    }

    return null;
  }

  // Future<bool> onCompletedServiceSyncToSAP({
  //   required BuildContext context, // ✅ Add BuildContext for UI
  //   required int? attachmentEntryExisting,
  //   required dynamic docEntry,
  // }) async {
  //   if (_timeEntry.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: const Color.fromARGB(255, 66, 83, 100),
  //         behavior: SnackBarBehavior.floating,
  //         elevation: 10,
  //         margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(9),
  //         ),
  //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  //         content: const Row(
  //           children: [
  //             Icon(Icons.remove_circle, color: Colors.white, size: 28),
  //             SizedBox(width: 16),
  //             Expanded(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     "Please provide a Time Entry",
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //         duration: const Duration(seconds: 4),
  //       ),
  //     );
  //     return false;
  //   }
  //   if (_signatureList.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: const Color.fromARGB(255, 66, 83, 100),
  //         behavior: SnackBarBehavior.floating,
  //         elevation: 10,
  //         margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(9),
  //         ),
  //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  //         content: const Row(
  //           children: [
  //             Icon(Icons.remove_circle, color: Colors.white, size: 28),
  //             SizedBox(width: 16),
  //             Expanded(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     "Please provide a signature",
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //         duration: const Duration(seconds: 4),
  //       ),
  //     );
  //     return false;
  //   }

  //   _submit = true;
  //   notifyListeners();
  //   MaterialDialog.loading(context); // Show loading dialog

  //   try {
  //     List<File> allFiles = [..._imagesList, ..._signatureList];

  //     final int? attachmentEntry =
  //         await uploadAttachmentsToSAP(allFiles, attachmentEntryExisting);
  //     if (attachmentEntry == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: const Color.fromARGB(255, 66, 83, 100),
  //           behavior: SnackBarBehavior.floating,
  //           elevation: 10,
  //           margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(9),
  //           ),
  //           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  //           content: const Row(
  //             children: [
  //               Icon(Icons.remove_circle, color: Colors.white, size: 28),
  //               SizedBox(width: 16),
  //               Expanded(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "Failed to upload attachments",
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //           duration: const Duration(seconds: 4),
  //         ),
  //       );
  //       return false;
  //     }
  //     final payload = {
  //       "DocEntry": docEntry,
  //       "U_CK_Status": "Entry",
  //       "U_CK_AttachmentEntry": attachmentEntry,
  //       "CK_JOB_TIMECollection": [
  //         {
  //           "U_CK_Description": "Travel Time",
  //           "U_CK_StartTime": _timeEntry[0]["U_CK_TraveledTime"],
  //           "U_CK_EndTime": _timeEntry[0]["U_CK_TraveledEndTime"],
  //           "U_CK_Effort": _timeEntry[0]["total_travel_time"],
  //         },
  //         {
  //           "U_CK_Description": "Service Time",
  //           "U_CK_StartTime": _timeEntry[0]["U_CK_ServiceStartTime"],
  //           "U_CK_EndTime": _timeEntry[0]["U_CK_SerEndTime"],
  //           "U_CK_Effort": _timeEntry[0]["total_service_time"],
  //         },
  //         {
  //           "U_CK_Description": "Break Time",
  //           "U_CK_StartTime": _timeEntry[0]["U_CK_BreakTime"],
  //           "U_CK_EndTime": _timeEntry[0]["U_CK_BreakEndTime"],
  //           "U_CK_Effort": _timeEntry[0]["total_break_time"],
  //         }
  //       ],
  //       "CK_JOB_ISSUECollection": _openIssues,
  //       "feedbackChecklistLine": _checkListLine
  //     };

  //     // print(payload);
  //     // return true;
  //     final completed = await dio.patch(
  //       "/script/test/CK_CompleteStatus($docEntry)",
  //       false,
  //       false,
  //       data: payload,
  //     );

  //     if (completed.statusCode == 204) {
  //       clearData();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: const Color.fromARGB(255, 66, 83, 100),
  //           behavior: SnackBarBehavior.floating,
  //           elevation: 10,
  //           margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(9),
  //           ),
  //           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  //           content: const Row(
  //             children: [
  //               Icon(Icons.remove_circle, color: Colors.white, size: 28),
  //               SizedBox(width: 16),
  //               Expanded(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "Service Completed!",
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //           duration: const Duration(seconds: 4),
  //         ),
  //       );
  //     }
  //     clearData();
  //     return true;
  //   } catch (e) {
  //     await MaterialDialog.warning(
  //       context,
  //       title: "Error",
  //       body: e.toString(),
  //     );
  //     return false;
  //   } finally {
  //     _submit = false;
  //     _openIssues = [];
  //     MaterialDialog.close(context); // Show loading dialog
  //   }
  // }

// // Helper function to decode Base64 strings back to temporary files
//   Future<List<File>> decodeBase64Files(List<String> base64List) async {
//     List<File> files = [];
//     try {
//       final tempDir = await getTemporaryDirectory();
//       for (String base64String in base64List) {
//         final bytes = base64Decode(base64String);
//         // Use a unique filename to avoid conflicts
//         final fileName =
//             'temp_file_${DateTime.now().millisecondsSinceEpoch}.png';
//         final file = File('${tempDir.path}/$fileName');
//         await file.writeAsBytes(bytes);
//         files.add(file);
//       }
//     } catch (e) {
//       debugPrint("Error decoding Base64 file: $e");
//     }
//     return files;
//   }

  void deleteTempFiles(List<File> files) {
    for (File file in files) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  Future<dynamic> syncAllOfflineServicesToSAP(BuildContext context) async {
    MaterialDialog.loading(context);

    final offlineProvider =
        Provider.of<ServiceListProviderOffline>(context, listen: false);

    try {
      List<Map<dynamic, dynamic>> completedServices =
          await offlineProvider.getCompletedServicesToSync();
      if (completedServices.isEmpty) {
        MaterialDialog.close(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(255, 66, 83, 100),
            behavior: SnackBarBehavior.floating,
            elevation: 10,
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            content: const Row(
              children: [
                Icon(Icons.remove_circle, color: Colors.white, size: 28),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "No offline services to sync.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        return false;
      }

      for (var servicePayload in completedServices) {
        final docEntry = servicePayload['DocEntry'];
        final attachmentEntryExisting = servicePayload['U_CK_AttachmentEntry'];
        final List<dynamic> fileDataList = servicePayload['files'] ?? [];

        List<File> filesToUpload = [];

        try {
          // 🔑 Decode {ext, data} into temp files
          final tempDir = await getTemporaryDirectory();
          for (var f in fileDataList) {
            if (f is Map && f.containsKey('data')) {
              final bytes = base64Decode(f['data']);
              final ext = f['ext'] ?? "bin";
              final fileName =
                  "temp_${DateTime.now().millisecondsSinceEpoch}.$ext";
              final file = File("${tempDir.path}/$fileName");
              await file.writeAsBytes(bytes);
              filesToUpload.add(file);
            }
          }

          // 1. Upload attachments to SAP
          final int? attachmentEntry = await uploadAttachmentsToSAP(
            filesToUpload,
            attachmentEntryExisting,
          );

          if (attachmentEntry == null) {
            debugPrint("Failed to sync attachments for DocEntry: $docEntry");
            continue; // skip to next service
          }

          // 2. Prepare SAP payload (remove offline-only keys)
          final sapPayload = Map<dynamic, dynamic>.from(servicePayload);
          sapPayload['U_CK_AttachmentEntry'] = attachmentEntry;
          sapPayload.remove('files');
          sapPayload.remove('sync_status');

          // 3. Send payload to SAP
          final response = await dio.patch(
            "/script/test/CK_CompleteStatus($docEntry)",
            false,
            false,
            data: sapPayload,
          );

          if (response.statusCode == 200) {
            await offlineProvider.markServiceSynced(docEntry);
            debugPrint("✅ Synced DocEntry: $docEntry");
          } else {
            debugPrint(
                "❌ Failed to sync DocEntry: $docEntry. Status: ${response.statusCode}");
          }
        } catch (e) {
          debugPrint("⚠️ Error syncing DocEntry: $docEntry. Error: $e");
        } finally {
          // Always clean up temp files
          deleteTempFiles(filesToUpload);
        }
      }

      // MaterialDialog.close(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Offline sync process completed.")),
      // );
      MaterialDialog.close(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: const Color.fromARGB(255, 66, 83, 100),
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        content: const Row(
          children: [
            Icon(Icons.remove_circle, color: Colors.white, size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Offline sync process completed.!.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ));
      return true;
    } catch (e) {
      MaterialDialog.close(context);
      await MaterialDialog.warning(context,
          title: "Batch Sync Error", body: e.toString());
    }
  }

  // Helper function: convert File → { ext, data }
  Future<Map<String, String>> fileToBase64WithExt(File file) async {
    final bytes = await file.readAsBytes();
    final base64Data = base64Encode(bytes);

    // Detect extension safely
    final path = file.path.toLowerCase();
    String ext = "bin"; // fallback
    if (path.endsWith(".png"))
      ext = "png";
    else if (path.endsWith(".jpg") || path.endsWith(".jpeg"))
      ext = "jpg";
    else if (path.endsWith(".pdf"))
      ext = "pdf";
    else if (path.endsWith(".gif")) ext = "gif";

    return {"ext": ext, "data": base64Data};
  }

  Future<bool> onCompletedServiceOffline({
    required BuildContext context,
    required int? attachmentEntryExisting,
    required dynamic docEntry,
    bool offline = false,
  }) async {
    if (_timeEntry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 66, 83, 100),
          behavior: SnackBarBehavior.floating,
          elevation: 10,
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          content: const Row(
            children: [
              Icon(Icons.remove_circle, color: Colors.white, size: 28),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Please provide a Time Entry",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return false;
    }
    if (_signatureList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 66, 83, 100),
          behavior: SnackBarBehavior.floating,
          elevation: 10,
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          content: const Row(
            children: [
              Icon(Icons.remove_circle, color: Colors.white, size: 28),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Please provide a signature",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return false;
    }

    // 1. Convert all files into List<Map<String, String>>
    List<Map<String, String>> fileDataList = [];

    for (File imageFile in imagesList) {
      fileDataList.add(await fileToBase64WithExt(imageFile));
    }

    for (File signatureFile in signatureList) {
      fileDataList.add(await fileToBase64WithExt(signatureFile));
    }

    // 2. Build the payload
    final payload = {
      "DocEntry": docEntry,
      "U_CK_Status": "Entry",
      "U_CK_AttachmentEntry": attachmentEntryExisting ?? 0,
      "CK_JOB_TIMECollection": [
        {
          "U_CK_Description": "Travel Time",
          "U_CK_StartTime": _timeEntry[0]["U_CK_TraveledTime"],
          "U_CK_EndTime": _timeEntry[0]["U_CK_TraveledEndTime"],
          "U_CK_Effort": _timeEntry[0]["total_travel_time"],
        },
        {
          "U_CK_Description": "Service Time",
          "U_CK_StartTime": _timeEntry[0]["U_CK_ServiceStartTime"],
          "U_CK_EndTime": _timeEntry[0]["U_CK_SerEndTime"],
          "U_CK_Effort": _timeEntry[0]["total_service_time"],
        },
        {
          "U_CK_Description": "Break Time",
          "U_CK_StartTime": _timeEntry[0]["U_CK_BreakTime"],
          "U_CK_EndTime": _timeEntry[0]["U_CK_BreakEndTime"],
          "U_CK_Effort": _timeEntry[0]["total_break_time"],
        }
      ],
      "CK_JOB_ISSUECollection": _openIssues,
      "feedbackChecklistLine": _checkListLine,
      "files": fileDataList, // ✅ Each file has {ext, data}
    };

    print(payload);

    // 3. Offline saving
    _submit = true;
    notifyListeners();
    MaterialDialog.loading(context);

    try {
      final offlineProvider =
          Provider.of<ServiceListProviderOffline>(context, listen: false);

      await offlineProvider.addCompletedService(payload);
      await offlineProvider.markServiceCompleted(docEntry);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Service saved offline!")),
      );

      clearData();
      return true;
    } catch (e) {
      await MaterialDialog.warning(context, title: "Error", body: e.toString());
      return false;
    } finally {
      _submit = false;
      _openIssues = [];
      MaterialDialog.close(context);
    }
  }
}
