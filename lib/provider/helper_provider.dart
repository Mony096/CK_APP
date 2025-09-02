import 'package:bizd_tech_service/utilities/dio_client.dart';
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

  Future<void> fetchCustomer() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await dio
          .get("/BusinessPartners?\$select=Phone1,CardCode,BPAddresses,CardName");
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["value"];
        _customer = data;

        print(customer);
      } else {
        throw Exception("Failed to load customer");
      }
    } catch (e) {
      print("Error fetching customer: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
