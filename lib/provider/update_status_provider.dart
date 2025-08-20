import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdateStatusProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final DioClient dio = DioClient(); // Custom Dio wrapper

  Future<void> updateDocumentAndStatus({
    required BuildContext context, // ✅ Add BuildContext for UI
    required int docEntry,
    required String status,
    required dynamic remarks,
    dynamic attachmentEntry,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final timeStamp = DateFormat("HH:mm:ss").format(now); // 24-hour format

      final data = {
        "DocEntry": docEntry,
        "U_lk_delstat": status,
      };

      if (remarks != null) {
        data["U_lk_podremark"] = remarks;
      }
      if (attachmentEntry != null) {
        data["AttachmentEntry"] = attachmentEntry;
      }
      if (status == "Started") {
        data["U_lk_delacctim"] = timeStamp; // fixed timestamp format
      }
      if (status == "On the Way") {
        data["U_lk_delpictim"] = timeStamp; // fixed timestamp format
      }
      if (status == "Delivered") {
        data["U_lk_delcomtim"] = timeStamp; // fixed timestamp format
      }
      final documentStatus = await dio.post(
        "/script/test/LK_Status_Update",
        false,
        false,
        data: data,
      );

      final alertToWebData = {
        "ReceiveType": 'Status',
        "DocEntry": docEntry,
      };

      if (documentStatus.statusCode == 201) {
        await dio.postNotification("", data: alertToWebData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Status updated successfully!"),
            backgroundColor: Color.fromARGB(255, 53, 55, 53),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      await MaterialDialog.warning(
        context,
        title: "Error",
        body: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
