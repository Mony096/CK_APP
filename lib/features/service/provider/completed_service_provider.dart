import 'dart:convert';
import 'dart:io';

import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:bizd_tech_service/core/error/failure.dart';
import 'package:bizd_tech_service/core/utils/html_pdf_generator.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

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

  File? get signature =>
      _signatureList.isNotEmpty ? _signatureList.first : null;
  List<File> get images => _imagesList.cast<File>();
  final DioClient dio = DioClient(); // Custom Dio wrapper

  void addOrEditOpenIssue(dynamic item, {int editIndex = -1}) {
    if (editIndex == -1) {
      _openIssues.add(item);
    } else {
      _openIssues[editIndex] = item;
    }
    notifyListeners();
  }

  void addOrEditOpenCheckList(dynamic item, {int editIndex = -1}) {
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
    if (editIndex == -1) {
      _timeEntry.add(item);
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

  void addImage(File file) {
    _imagesList.add(file);
    notifyListeners();
  }

  void removeImage(int index) {
    if (index >= 0 && index < _imagesList.length) {
      _imagesList.removeAt(index);
      notifyListeners();
    }
  }

  void removeSignature() {
    _signatureList.clear();
    notifyListeners();
  }

  void removeTimeEntry(int index) {
    if (index >= 0 && index < _timeEntry.length) {
      _timeEntry.removeAt(index);
      notifyListeners();
    }
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
    _checkListLine = [];
    notifyListeners();
  }

  void clearOpenIssues() {
    _openIssues.clear();
    notifyListeners();
  }

  void deleteTempFiles(List<File> files) {
    for (File file in files) {
      if (file.existsSync()) {
        file.deleteSync();
      }
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

  String calculateSpentTimeHM({
    required String travelTime,
    required String completeTime,
  }) {
    final now = DateTime.now();

    DateTime parseTime(String time) {
      final parts = time.split(":");
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }

    DateTime travel = parseTime(travelTime);
    DateTime complete = parseTime(completeTime);

    // Handle cross-midnight case
    if (complete.isBefore(travel)) {
      complete = complete.add(const Duration(days: 1));
    }

    final duration = complete.difference(travel);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return "${hours}h ${minutes}m";
  }

  String calculateDuration({
    required String start,
    required String end,
  }) {
    if (start.isEmpty || end.isEmpty || start == "--:--" || end == "--:--") {
      return "00:00";
    }
    try {
      DateTime parseTime(String time) {
        // Try 24h format first (HH:mm)
        try {
          final parts = time.split(':');
          return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
        } catch (_) {}

        // Fallback to 12h format (h:mm AM/PM)
        final format = DateFormat('h:mm a');
        return format.parse(time);
      }

      final startTime = parseTime(start);
      final endTime = parseTime(end);

      Duration diff = endTime.difference(startTime);

      // Handle overnight case
      if (diff.isNegative) {
        diff += const Duration(days: 1);
      }

      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');

      return "$hours:$minutes";
    } catch (e) {
      return "00:00";
    }
  }

  Future<int?> uploadAttachmentsToSAP(
      List<File> files, int? existingAttachmentEntry) async {
    // print(existingAttachmentEntry);
    // return 0;
    try {
      final formData = FormData();

      for (var file in files) {
        final fileName = file.path.split('/').last;
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        ));
      }
      // print("Attachment Entryyyyy $existingAttachmentEntry");
      // return null;
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
      // response = await dio.post(
      //   '/Attachments2',
      //   false,
      //   true,
      //   data: formData,
      //   options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      // );
      debugPrint("📎 SAP Attachment Response for DocEntry:");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");

      if ([200, 201].contains(response.statusCode)) {
        final absEntry =
            response.data['AbsEntry'] ?? response.data['AbsoluteEntry'];
        return absEntry is int ? absEntry : int.tryParse('$absEntry');
      }

      if (response.statusCode == 204 && existingAttachmentEntry != null) {
        return existingAttachmentEntry;
      }

      debugPrint(
          "❌ Upload failed: ${response.statusCode} ${response.statusMessage}. Body: ${response.data}");
    } catch (e, stack) {
      debugPrint("Upload failed: $e");
      debugPrint(stack.toString());
    }

    return null;
  }

  Future<Map<String, dynamic>> syncAllOfflineServicesToSAP(
      BuildContext context) async {
    final offlineProvider =
        Provider.of<ServiceListProviderOffline>(context, listen: false);

    List<Map<dynamic, dynamic>> completedServices =
        await offlineProvider.getCompletedServicesToSync();

    List<String> errors = [];
    if (completedServices.isEmpty) {
      return {"total": 0, "errors": errors};
    }

    for (var servicePayload in completedServices) {
      try {
        await _syncServicePayload(servicePayload, offlineProvider);
      } catch (e) {
        final docEntry = servicePayload['DocEntry'];
        // Get DocNum for error tracking
        final dynamic doc = offlineProvider.documents.firstWhere(
          (d) => d['DocEntry'].toString() == docEntry.toString(),
          orElse: () => <String, dynamic>{},
        );
        final docNum = doc['DocNum'] ?? doc['id'] ?? 'N/A';

        // Extract error message properly
        String errorMsg;
        if (e is Failure) {
          errorMsg = e.message;
        } else {
          errorMsg = e.toString();
        }
        errors.add("Service Ticket #$docNum: $errorMsg");
      }
    }
    return {"total": completedServices.length, "errors": errors};
  }

  /// Sync a SINGLE service by DocEntry
  Future<void> syncSingleServiceToSAP(
      BuildContext context, dynamic docEntry) async {
    final offlineProvider =
        Provider.of<ServiceListProviderOffline>(context, listen: false);

    // Get all pending services
    List<Map<dynamic, dynamic>> completedServices =
        await offlineProvider.getCompletedServicesToSync();

    // Find the specific one
    final servicePayload = completedServices.firstWhere(
      (s) => s['DocEntry'].toString() == docEntry.toString(),
      orElse: () => {},
    );

    if (servicePayload.isEmpty) {
      // If not found in pending list, maybe it's already synced or not completed offline yet
      // We can just return silently or throw an error depending on desired behavior.
      // For now, let's assume if it's not pending, we don't need to do anything.
      debugPrint("⚠️ Service $docEntry not found in pending sync list.");
      return;
    }

    // Sync just this one
    await _syncServicePayload(servicePayload, offlineProvider);
  }

  /// Internal helper to sync a single service payload
  Future<void> _syncServicePayload(Map<dynamic, dynamic> servicePayload,
      ServiceListProviderOffline offlineProvider) async {
    final docEntry = servicePayload['DocEntry'];
    final attachmentEntryExisting = servicePayload['U_CK_AttachmentEntry'];
    final List<dynamic> fileDataList = servicePayload['files'] ?? [];

    List<File> filesToUpload = [];
    try {
      if (fileDataList.isNotEmpty) {
        final tempDir = await getTemporaryDirectory();
        int i = 0;
        for (var f in fileDataList) {
          if (f is Map && f.containsKey('data')) {
            final bytes = base64Decode(f['data']);
            final ext = f['ext'] ?? "bin";
            final type = f['type'] ?? "image";
            final fileName =
                "${type}_${DateTime.now().millisecondsSinceEpoch}_$i.$ext";
            final file = File("${tempDir.path}/$fileName");
            await file.writeAsBytes(bytes);
            filesToUpload.add(file);
            i++;
          }
        }
      }

      int? attachmentEntry;
      if (filesToUpload.isNotEmpty) {
        attachmentEntry = await uploadAttachmentsToSAP(
          filesToUpload,
          attachmentEntryExisting,
        );

        if (attachmentEntry == null) {
          throw Exception("Failed to upload attachments");
        }
      }

      final sapPayload = Map<dynamic, dynamic>.from(servicePayload);
      if (attachmentEntry != null) {
        sapPayload['U_CK_AttachmentEntry'] = attachmentEntry;
      }
      sapPayload.remove('files');
      sapPayload.remove('sync_status');

      final response = await dio.patch(
        "/script/test/CK_CompleteStatus($docEntry)",
        false,
        false,
        data: sapPayload,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        await offlineProvider.markServiceSynced(docEntry);
      } else {
        throw Exception(
            "Status: ${response.statusCode}. Body: ${response.data}");
      }
    } finally {
      deleteTempFiles(filesToUpload);
    }
  }

  Future<bool> onCompletedServiceOffline({
    required BuildContext context,
    required int? attachmentEntryExisting,
    required dynamic docEntry,
    required dynamic startTime,
    required dynamic endTime,
    required String customerName,
    required String date,
    required dynamic timeAction,
    required dynamic activityType,
    required dynamic docNum,
    required dynamic serviceCallId,
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

    // Generate timestamp to check against startTime
    final now = DateTime.now();
    final timeStamp = DateFormat("HH:mm:ss").format(now);

    // Format times to HH:mm (without seconds) for comparison
    final timeStampWithoutSeconds = timeStamp.substring(0, 5);
    final startTimeWithoutSeconds = startTime.substring(0, 5);

    // Check if U_CK_EndTime equals startTime (no time spent - compare only hours and minutes)
    if (timeStampWithoutSeconds == startTimeWithoutSeconds) {
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
                      "Service end time cannot be the same as start time",
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
    // MaterialDialog.loading(context);

    // 1. Convert all files into List<Map<String, String>>
    List<Map<String, String>> fileDataList = [];

    for (File imageFile in imagesList) {
      final fileMap = await fileToBase64WithExt(imageFile);
      fileMap['type'] = 'image';
      fileDataList.add(fileMap);
    }

    for (File signatureFile in signatureList) {
      final fileMap = await fileToBase64WithExt(signatureFile);
      fileMap['type'] = 'signature';
      fileDataList.add(fileMap);
    }

    // Generate PDF report and add to files
    try {
      // Build data for PDF generation (need to include images/signatures for the PDF template)
      final pdfData = Map<String, dynamic>.from({
        'DocEntry': docEntry,
        'DocNum': docNum,
        'U_CK_Date': date,
        'U_CK_Cardname': customerName,
        'CustomerName': customerName,
        'U_CK_Time': startTime,
        'U_CK_EndTime': endTime,
        'U_CK_JobType': activityType,
        'U_CK_ServiceCall': serviceCallId,
        'CK_JOB_ISSUECollection': _openIssues,
        'CK_JOB_TASKCollection': _checkListLine,
        'files': fileDataList, // Include images/signature for PDF template
      });

      final File pdfFile =
          await HtmlServiceReportGenerator.generateServiceReport(pdfData);
      final pdfBytes = await pdfFile.readAsBytes();
      final pdfBase64 = base64Encode(pdfBytes);

      fileDataList.add({
        'ext': 'pdf',
        'data': pdfBase64,
        'type': 'report',
      });

      // Clean up temp PDF file
      if (pdfFile.existsSync()) {
        pdfFile.deleteSync();
      }

      debugPrint('✅ PDF report generated and added to files');
    } catch (e) {
      debugPrint('⚠️ Failed to generate PDF report: $e');
      // Continue without PDF - don't block the completion
    }

    // String formatSpentTime(Duration duration) {
    //   final hours = duration.inHours;
    //   final minutes = duration.inMinutes.remainder(60);

    //   return "${hours}h ${minutes}m";
    // }
    final spentTime = calculateSpentTimeHM(
      travelTime: timeAction["TravelTime"],
      completeTime: timeAction["CompleteTime"],
    );
    // 2. Build the payload
    final payload = {
      "DocEntry": docEntry,
      "U_CK_Cardname": customerName,
      "U_CK_Date": date,
      "U_CK_Status": "Completed",
      "U_CK_AttachmentEntry": attachmentEntryExisting,
      "U_CK_Time": startTime,
      "U_CK_EndTime": timeStamp,
      "U_CK_TravelTime": timeAction["TravelTime"],
      "U_CK_AcceptTime": timeAction["AcceptTime"],
      "U_CK_ServiceCall": serviceCallId,
      "CK_JOB_TIMECollection": [
        {
          "U_CK_Date": date,
          "U_CK_StartTime": startTime,
          "U_CK_EndTime": timeStamp,
          "U_CK_Effort": spentTime,
          "U_CK_AcceptedTime": timeAction["AcceptTime"],
          "U_CK_RejectedTime": timeAction["RejectTime"],
          "U_CK_TraveledTime": _timeEntry[0]["U_CK_TraveledTime"],
          "U_CK_TraveledEndTime": _timeEntry[0]["U_CK_TraveledEndTime"],
          "U_CK_TraveledEffortTime": _timeEntry[0]["total_travel_time"],
          "U_CK_ServiceStartTime": _timeEntry[0]["U_CK_ServiceStartTime"],
          "U_CK_SerEndTime": _timeEntry[0]["U_CK_SerEndTime"],
          "U_CK_ServiceEffortTime": _timeEntry[0]["total_service_time"],
          "U_CK_BreakTime": _timeEntry[0]["U_CK_BreakTime"],
          "U_CK_BreakEndTime": _timeEntry[0]["U_CK_BreakEndTime"],
          "U_CK_BreakEffortTime": _timeEntry[0]["total_break_time"],
        },
      ],
      "CK_JOB_ISSUECollection": _openIssues,
      "CK_JOB_TASKCollection": _checkListLine.map((item) {
        return {
          ...item,
          'U_CK_Checked': item['U_CK_Checked'] == true ? 'Y' : 'N',
        };
      }).toList(),

      "files": fileDataList, // ✅ Each file has {ext, data}
    };

    final firstName = await LocalStorageManger.getString('FirstName');
    final lastName = await LocalStorageManger.getString('LastName');
    final userId = await LocalStorageManger.getString('UserId');
    final userCode = await LocalStorageManger.getString('UserName');

    // calculate break time (HH:mm)
    final breakTime = calculateDuration(
      start: _timeEntry[0]["U_CK_BreakTime"],
      end: _timeEntry[0]["U_CK_BreakEndTime"],
    );
    payload["timeSheet"] = {
      "TimeSheetType": "tsh_Employee",
      "UserID": userId,
      "LastName": lastName,
      "FirstName": firstName,
      "DateFrom": date,
      "DateTo": date,
      "SAPPassport": null,
      "UserCode": userCode,
      "PM_TimeSheetLineDataCollection": [
        {
          "LineID": null,
          "Date": date,
          "StartTime": startTime,
          "EndTime": timeStamp,
          "Break": breakTime,
          "U_CK_JobType": activityType,
          "U_CK_JobOrder": docNum,
          "NonBillableTime": "00:00"
        }
      ]
    };

    // print(payload["CK_JOB_TIMECollection"]);
    // return false;
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
              // Icon(Icons.remove_circle,
              //     color: Colors.white, size: 28),
              // SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "✅ Service completed.",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.031,
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
      clearData();
      // MaterialDialog.close(context);
      return true;
    } catch (e) {
      MaterialDialog.close(context);
      await MaterialDialog.warning(context, title: "Error", body: e.toString());
      return false;
    } finally {
      _submit = false;
      _openIssues = [];
      MaterialDialog.close(context);
    }
  }

  Future<bool> onReject({
    required BuildContext context,
    required dynamic docEntry,
    required String customerName,
    required String date,
    bool offline = false,
  }) async {
    final now = DateTime.now();
    final timeStamp = DateFormat("HH:mm:ss").format(now);
    // 2. Build the payload
    final payload = {
      "DocEntry": docEntry,
      "U_CK_Cardname": customerName,
      "U_CK_Date": date,
      "U_CK_Status": "Rejected",
      "CK_JOB_TIMECollection": [
        {
          "U_CK_Date": date,
          "U_CK_RejectedTime": timeStamp,
        },
      ],
    };

    // print(timeAction);
    // return false;
    // 3. Offline saving
    _submit = true;
    notifyListeners();
    MaterialDialog.loading(context);

    try {
      final offlineProvider =
          Provider.of<ServiceListProviderOffline>(context, listen: false);

      await offlineProvider.addCompletedReject(payload);
      await offlineProvider.markServiceCompletedReject(docEntry);
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
              // Icon(Icons.remove_circle,
              //     color: Colors.white, size: 28),
              // SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "✅ Service Rejected in offline mode.",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.031,
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
