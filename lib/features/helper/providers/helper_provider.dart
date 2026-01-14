import 'package:bizd_tech_service/shared/dialogs/dialog.dart';
import 'package:bizd_tech_service/core/network/dio_client.dart';
import 'package:flutter/material.dart';

class HelperProvider extends ChangeNotifier {
  List<dynamic> _warehouses = [];
  List<dynamic> _customer = [];
  bool _isLoading = false;
  final DioClient dio = DioClient(); // Your custom Dio client

  List<dynamic> get warehouses => _warehouses;
  List<dynamic> get customer => _customer;

  bool get isLoading => _isLoading;
  Future<void> fetchWarehouse() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await dio.get(
          "/Warehouses?\$select=WarehouseCode, WarehouseName,U_LK_LatLong");
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["value"];
        _warehouses = data;
      } else {
        throw Exception("Failed to load warehouse");
      }
    } catch (e) {
      print("Error fetching warehosue: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCustomer(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await dio
          .get("/BusinessPartners?\$select=ContactEmployees,CardCode,BPAddresses,CardName");
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["value"];
        _customer = data;

      } else {
        throw Exception("Failed to load customer");
      }
    } catch (e) {
       await MaterialDialog.warning(
        context,
        title: "Error",
        body: e.toString(),
      );
      print("Error fetching customer: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

