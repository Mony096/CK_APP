import 'dart:convert';
import 'dart:io';

import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class EquipmentCreateProvider with ChangeNotifier {
  bool _submit = false;
  List<dynamic> _components = [];
  List<dynamic> _parts = [];
  List<dynamic> _imagesList = [];

  bool get submit => _submit;
  List<dynamic> get imagesList => _imagesList;

  List<dynamic> get components => _components;
  List<dynamic> get parts => _parts;
  final DioClient dio = DioClient(); // Custom Dio wrapper

  void addOrEditComponent(Map<String, dynamic> item, {int editIndex = -1}) {
    if (editIndex == -1) {
      _components.add(item);
    } else {
      _components[editIndex] = item;
    }
    notifyListeners();
  }

  void setParts(List<dynamic> collection) {
    _parts = collection;
    notifyListeners();
  }

  void setImages(List<dynamic> images) {
    _imagesList.addAll(images);
    // Correct for single file
    notifyListeners();
  }

  void clearImages() {
    _imagesList.clear();
    // Correct for single file
    notifyListeners();
  }

  void setComponents(List<dynamic> collection) {
    _components = collection;
    notifyListeners();
  }

  void clearCollection() {
    _components = [];
    _parts = [];
    _imagesList = [];
    notifyListeners();
  }

  void addOrEditPart(Map<String, dynamic> item, {int editIndex = -1}) {
    if (editIndex == -1) {
      _parts.add(item);
    } else {
      _parts[editIndex] = item;
    }
    notifyListeners();
  }

  void removeComponent(int index) {
    if (index >= 0 && index < _components.length) {
      _components.removeAt(index);
      notifyListeners();
    }
  }

  void removePart(int index) {
    if (index >= 0 && index < _parts.length) {
      _parts.removeAt(index);
      notifyListeners();
    }
  }

  void clearComponents() {
    _components.clear();
    notifyListeners();
  }

  Future<int?> uploadAttachmentsToSAP(List<dynamic> files) async {
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
      // POST request to create new
      response = await dio.post(
        '/Attachments2',
        false,
        true,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if ([200, 201].contains(response.statusCode)) {
        final absEntry =
            response.data['AbsEntry'] ?? response.data['AbsoluteEntry'];
        return absEntry is int ? absEntry : int.tryParse('$absEntry');
      } else {
        debugPrint(
            "Upload failed: ${response.statusCode} ${response.statusMessage}");
      }
    } catch (e, stack) {
      debugPrint("Upload failed: $e");
      debugPrint(stack.toString());
    }

    return null;
  }

  // Future<void> postToSAP({
  //   required BuildContext context, // ✅ Add BuildContext for UI
  //   required Map<String, dynamic> data,
  // }) async {
  //   _submit = true;
  //   notifyListeners();
  //   MaterialDialog.loading(context); // Show loading dialog

  //   try {
  //     final int? attachmentEntry = await uploadAttachmentsToSAP(_imagesList);
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
  //       return;
  //     }
  //     final payload = {
  //       ...data,
  //       "U_ck_AttachmentEntry": attachmentEntry,
  //       // "CK_CUSEQUI01Collection":
  //       //     _components.map((e) => Map.from(e)..remove("BrandName")).toList(),
  //       // "CK_CUSEQUI02Collection":
  //       //     _parts.map((e) => Map.from(e)..remove("BrandName")).toList(),
  //       "CK_CUSEQUI01Collection": _components,
  //       "CK_CUSEQUI02Collection": _parts,
  //     };
  //     final create = await dio.post(
  //       "/CK_CUSEQUI",
  //       false,
  //       false,
  //       data: payload,
  //     );

  //     if (create.statusCode == 201) {
  //       // ScaffoldMessenger.of(context).showSnackBar(
  //       //   const SnackBar(
  //       //     content: Text("Status updated successfully!"),
  //       //     backgroundColor: Color.fromARGB(255, 53, 55, 53),
  //       //     duration: Duration(seconds: 2),
  //       //   ),
  //       // );
  //       await MaterialDialog.createdSuccess(
  //         context,
  //       );
  //     }
  //   } catch (e) {
  //     await MaterialDialog.warning(
  //       context,
  //       title: "Error",
  //       body: e.toString(),
  //     );
  //   } finally {
  //     _submit = false;
  //     _components = [];
  //     _parts = [];
  //     _imagesList = [];
  //     MaterialDialog.close(context); // Show loading dialog
  //     notifyListeners();
  //   }
  // }

  void deleteTempFiles(List<File> files) {
    for (File file in files) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  ///sync to SAP
  // Future<dynamic> syncAllOfflineEquipmentToSAP(BuildContext context) async {
  //   final offlineProvider =
  //       Provider.of<EquipmentOfflineProvider>(context, listen: false);

  //   List<dynamic> completedEquipment = offlineProvider.equipments;
  //   if (completedEquipment.isEmpty) return false;

  //   for (var equipmentPayload in completedEquipment) {
  //     final code = equipmentPayload['Code'];
  //     final List<dynamic> fileDataList = equipmentPayload['files'] ?? [];

  //     List<File> filesToUpload = [];

  //     try {
  //       // 🔑 Decode {ext, data} into temp files (only if files exist)
  //       if (fileDataList.isNotEmpty) {
  //         final tempDir = await getTemporaryDirectory();
  //         for (var f in fileDataList) {
  //           if (f is Map && f.containsKey('data')) {
  //             final bytes = base64Decode(f['data']);
  //             final ext = f['ext'] ?? "bin";
  //             final fileName =
  //                 "temp_${DateTime.now().millisecondsSinceEpoch}.$ext";
  //             final file = File("${tempDir.path}/$fileName");
  //             await file.writeAsBytes(bytes);
  //             filesToUpload.add(file);
  //           }
  //         }
  //       }

  //       int? attachmentEntry;

  //       // 1. Upload attachments only if files exist
  //       if (filesToUpload.isNotEmpty) {
  //         attachmentEntry = await uploadAttachmentsToSAP(filesToUpload);
  //         if (attachmentEntry == null) {
  //           debugPrint(
  //               "⚠️ Failed to sync attachments for Equipment Code: $code");
  //           continue; // skip this equipment but move on
  //         }
  //       }

  //       // 2. Prepare SAP payload (remove offline-only keys)
  //       final sapPayload = Map<dynamic, dynamic>.from(equipmentPayload);
  //       if (attachmentEntry != null) {
  //         sapPayload['U_ck_AttachmentEntry'] = attachmentEntry;
  //       }
  //       sapPayload.remove('files');
  //       sapPayload.remove('sync_status');
  //       sapPayload.remove('savedAt');

  //       // 3. Send payload to SAP
  //       final response = await dio.post(
  //         "/CK_CUSEQUI",
  //         false,
  //         false,
  //         data: sapPayload,
  //       );

  //       if (response.statusCode == 201) {
  //         debugPrint("✅ Synced Equipment Code: $code");
  //       } else {
  //         throw Exception(
  //             "Failed to sync Equipment Code: $code. Status: ${response.statusCode}");
  //       }

  //       return true;
  //     } catch (e) {
  //       throw Exception("Your Equipment Failed: ${e.toString()}");
  //     } finally {
  //       // Always clean up temp files
  //       deleteTempFiles(filesToUpload);
  //     }
  //   }
  // }
  Future<Map<String, dynamic>> syncAllOfflineEquipmentToSAP(
      BuildContext context) async {
    final offlineProvider =
        Provider.of<EquipmentOfflineProvider>(context, listen: false);

    final pendingEquipment = offlineProvider.equipments
        .where((e) => e['sync_status'] == 'pending')
        .toList();

    List<String> errors = [];
    if (pendingEquipment.isEmpty) {
      debugPrint("No pending offline equipment to sync.");
      return {"total": 0, "errors": errors};
    }

    for (var equipmentPayload in pendingEquipment) {
      final code = equipmentPayload['Code'] ?? 'N/A';
      final List<dynamic> fileDataList = equipmentPayload['files'] ?? [];
      List<File> filesToUpload = [];

      try {
        if (fileDataList.isNotEmpty) {
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
        }

        int? attachmentEntry;
        if (filesToUpload.isNotEmpty) {
          attachmentEntry = await uploadAttachmentsToSAP(filesToUpload);
          if (attachmentEntry == null) {
            throw Exception("Failed to upload attachments");
          }
        }

        final sapPayload = Map<String, dynamic>.from(equipmentPayload);
        if (attachmentEntry != null) {
          sapPayload['U_ck_AttachmentEntry'] = attachmentEntry;
        }
        sapPayload.remove('files');
        sapPayload.remove('sync_status');
        sapPayload.remove('savedAt');

        final response = await dio.post(
          "/CK_CUSEQUI",
          false,
          false,
          data: sapPayload,
        );

        if (response.statusCode == 201) {
          debugPrint("✅ Synced Equipment Code: $code");
          final index = offlineProvider.equipments
              .indexWhere((e) => e['Code'] == equipmentPayload['Code']);
          if (index != -1) {
            final updatedPayload = Map<String, dynamic>.from(equipmentPayload);
            updatedPayload['sync_status'] = 'synced';
            await offlineProvider.updateEquipment(updatedPayload);
          }
        } else {
          throw Exception(
              "Status: ${response.statusCode}. Body: ${response.data}");
        }
      } catch (e) {
        errors.add("Equipment Code #$code: $e");
      } finally {
        deleteTempFiles(filesToUpload);
      }
    }
    await offlineProvider.loadEquipments();
    return {"total": pendingEquipment.length, "errors": errors};
  }
}
