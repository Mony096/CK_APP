import 'package:bizd_tech_service/core/network/dio_client.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:flutter/material.dart';

class DeliveryNoteProvider extends ChangeNotifier {
  List<dynamic> _documents = [];
  bool _isLoading = false;
  final DioClient dio = DioClient(); // Your custom Dio client

  List<dynamic> get documents => _documents;
  bool get isLoading => _isLoading;

  Future<void> fetchDocuments() async {
    _isLoading = true;
    notifyListeners();

    final userId = await LocalStorageManger.getString('UserId');
    final select =
        "DocumentLines,CardName,DocDate,DocTime,U_lk_delstat,DocEntry,CardCode,DocNum,U_lk_reqdeltim,U_lk_duration";
    try {
      // final response = await dio.get(
      //     "/DeliveryNotes?\$filter=(U_lk_delstat eq 'Started' or U_lk_delstat eq 'On the Way') and U_lk_driver eq $userId & \$select=$select");
      final response = await dio.get("/DeliveryNotes?\$top=3");
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["value"];
        _documents = data;
      } else {
        throw Exception("Failed to load documents");
      }
    } catch (e) {
      print("Error fetching documents: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
