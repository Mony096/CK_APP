import 'dart:io';

import 'dart:io';

import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompletedServiceProvider extends ChangeNotifier {
  bool _submit = false;
  List<dynamic> _openIssues = [];
  final List<dynamic> _imagesList = [];
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

  // void removePart(int index) {
  //   if (index >= 0 && index < _parts.length) {
  //     _parts.removeAt(index);
  //     notifyListeners();
  //   }
  // }

  void clearOpenIssues() {
    _openIssues.clear();
    notifyListeners();
  }

  Future<void> postToSAP({
    required BuildContext context, // ✅ Add BuildContext for UI
    required Map<String, dynamic> data,
  }) async {
    _submit = true;
    notifyListeners();
    MaterialDialog.loading(context); // Show loading dialog

    try {
      final payload = {
        ...data,
        "CK_JOB_ISSUECollection": _openIssues,
      };
      final completed = await dio.patch(
        "/CK_JOBORDER(${data["DocEntry"]})",
        false,
        false,
        data: payload,
      );

      if (completed.statusCode == 204) {
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
      _openIssues = [];
      MaterialDialog.close(context); // Show loading dialog
    }
  }
}
