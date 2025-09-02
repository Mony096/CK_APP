import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdateStatusProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final DioClient dio = DioClient(); // Custom Dio wrapper

  Future<void> updateDocumentAndStatus({
    required int docEntry,
    required String status,
    required BuildContext context, // ✅ Add BuildContext for UI
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // final now = DateTime.now();
      // final timeStamp = DateFormat("HH:mm:ss").format(now); // 24-hour format

      final data = {
        "DocEntry": docEntry,
        "U_CK_Status": status,
      };

      // if (remarks != null) {
      //   data["U_lk_podremark"] = remarks;
      // }
      // if (attachmentEntry != null) {
      //   data["AttachmentEntry"] = attachmentEntry;
      // }
      // if (status == "Started") {
      //   data["U_lk_delacctim"] = timeStamp; // fixed timestamp format
      // }
      // if (status == "On the Way") {
      //   data["U_lk_delpictim"] = timeStamp; // fixed timestamp format
      // }
      // if (status == "Delivered") {
      //   data["U_lk_delcomtim"] = timeStamp; // fixed timestamp format
      // }
      final documentStatus = await dio.patch(
        "/CK_JOBORDER($docEntry)",
        false,
        false,
        data: data,
      );

      // final alertToWebData = {
      //   "ReceiveType": 'Status',
      //   "DocEntry": docEntry,
      // };

      if (documentStatus.statusCode == 201) {
        // await dio.postNotification("", data: alertToWebData);
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
                        "Status updated successfully!",
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
