import 'dart:io';

import 'dart:io';

import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CompletedServiceProvider extends ChangeNotifier {
  bool _submit = false;
  List<dynamic> _openIssues = [];
  List<dynamic> _imagesList = [];
  List<dynamic> _signatureList = [];
  List<dynamic> _timeEntry = [];
  bool get submit => _submit;
  List<dynamic> get openIssues => _openIssues;
  List<dynamic> get imagesList => _imagesList;
  List<dynamic> get signatureList => _signatureList;
  List<dynamic> get timeEntry => _timeEntry;
  final DioClient dio = DioClient(); // Custom Dio wrapper

  void addOrEditOpenIssue(Map<String, dynamic> item, {int editIndex = -1}) {
    if (editIndex == -1) {
      _openIssues.add(item);
    } else {
      _openIssues[editIndex] = item;
    }
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
        endTime = endTime.add(Duration(days: 1));
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

  Future<bool> onCompletedService({
    required BuildContext context, // ✅ Add BuildContext for UI
    required int? attachmentEntryExisting,
    required dynamic docEntry,
  }) async {
    if (_imagesList.isEmpty) {
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
                      "Please provide an image",
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
      return false;
    }
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
                      "Please provide a Time Entry",
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
                      "Please provide a signature",
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
      return false;
    }

    _submit = true;
    notifyListeners();
    MaterialDialog.loading(context); // Show loading dialog

    try {
      List<File> allFiles = [..._imagesList, ..._signatureList];

      final int? attachmentEntry =
          await uploadAttachmentsToSAP(allFiles, attachmentEntryExisting);
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
        return false;
      }
      print(attachmentEntry);
      print(openIssues);
      final payload = {
        "U_CK_Status": "Entry",
        "U_CK_AttachmentEntry": attachmentEntry,
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
      };

      // print(payload);
      // return true;
      final completed = await dio.patch(
        "/CK_JOBORDER($docEntry)",
        false,
        false,
        data: payload,
      );

      if (completed.statusCode == 204) {
        clearData();
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
                        "Service Completed!",
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
      }
      clearData();
      return true;
    } catch (e) {
      await MaterialDialog.warning(
        context,
        title: "Error",
        body: e.toString(),
      );
      return false;
    } finally {
      _submit = false;
      _openIssues = [];
      MaterialDialog.close(context); // Show loading dialog
    }
  }
}
