import 'package:bizd_tech_service/shared/dialogs/dialog.dart';
import 'package:bizd_tech_service/core/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdateStatusProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final DioClient dio = DioClient(); // Custom Dio wrapper

  Future<void> updateDocumentAndStatus({
    required int docEntry,
    required String status,
    required BuildContext context, // âœ… Add BuildContext for UI
  }) async {
    _isLoading = true;
    notifyListeners();
    print(status);
    try {
      final now = DateTime.now();
      final timeStamp = DateFormat("HH:mm:ss").format(now); // 24-hour format

      // final now = DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now());

      final data = {
        "DocEntry": docEntry,
        "U_CK_Status": status,
      };

      if (status == "Accept") {
        data["U_CK_Time"] = timeStamp;
      } else {
        data["U_CK_EndTime"] = timeStamp;
      }

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

