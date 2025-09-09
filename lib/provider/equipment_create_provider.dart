import 'dart:io';

import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  Future<void> postToSAP({
    required BuildContext context, // ✅ Add BuildContext for UI
    required Map<String, dynamic> data,
  }) async {
    _submit = true;
    notifyListeners();
    MaterialDialog.loading(context); // Show loading dialog

    try {
      final int? attachmentEntry = await uploadAttachmentsToSAP(_imagesList);
      if (attachmentEntry == null) {
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
            content: Row(
              children: [
                const Icon(Icons.remove_circle, color: Colors.white, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Failed to upload attachments",
                        style: const TextStyle(
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
        return;
      }
      final payload = {
        ...data,
        "U_ck_AttachmentEntry": attachmentEntry,
        // "CK_CUSEQUI01Collection":
        //     _components.map((e) => Map.from(e)..remove("BrandName")).toList(),
        // "CK_CUSEQUI02Collection":
        //     _parts.map((e) => Map.from(e)..remove("BrandName")).toList(),
        "CK_CUSEQUI01Collection": _components,
        "CK_CUSEQUI02Collection": _parts,
      };
      final create = await dio.post(
        "/CK_CUSEQUI",
        false,
        false,
        data: payload,
      );

      if (create.statusCode == 201) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text("Status updated successfully!"),
        //     backgroundColor: Color.fromARGB(255, 53, 55, 53),
        //     duration: Duration(seconds: 2),
        //   ),
        // );
        await MaterialDialog.createdSuccess(
          context,
        );
      }
    } catch (e) {
      await MaterialDialog.warning(
        context,
        title: "Error",
        body: e.toString(),
      );
    } finally {
      _submit = false;
      _components = [];
      _parts = [];
      _imagesList = [];
      MaterialDialog.close(context); // Show loading dialog
      notifyListeners();
    }
  }
}
