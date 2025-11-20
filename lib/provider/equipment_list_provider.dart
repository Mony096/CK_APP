import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
import 'package:flutter/material.dart';

class EquipmentListProvider extends ChangeNotifier {
  List<dynamic> _documents = [];
  List<dynamic> _documentOffline = [];

  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingSetFilter = false;

  int _skip = 0;
  final int _limit = 10;
  String _currentFilter = "";

  final DioClient dio = DioClient();

  List<dynamic> get documents => _documents;
  List<dynamic> get documentOffline => _documentOffline;

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isLoadingSetFilter => _isLoadingSetFilter;

  String get currentFilter => _currentFilter;
  Future<void> resfreshFetchDocuments() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await dio.get(
          "/CK_CUSEQUI?\$top=$_limit&\$skip=$_skip&\$select=U_ck_CusCode,U_ck_CusName,U_ck_eqSerNum,Code,Name,DocEntry &\$orderby=DocEntry desc");

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

  Future<void> fetchDocuments(
      {bool loadMore = false, bool isSetFilter = false}) async {
    if (_isLoading) return;
    if (isSetFilter) {
      if (_isLoadingSetFilter) return;
      _isLoadingSetFilter = true;
    }
    _isLoading = true;
    notifyListeners();

    final String filterCondition = _currentFilter == ""
        ? ""
        : "&\$filter=contains(Code,'$_currentFilter')";

    try {
      final response = await dio.get(
          "/CK_CUSEQUI?\$top=$_limit&\$skip=$_skip$filterCondition &\$select=U_ck_CusCode,U_ck_CusName,U_ck_eqSerNum,Code,Name,DocEntry &\$orderby=DocEntry desc");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["value"];
        if (loadMore) {
          _documents.addAll(data);
        } else {
          _documents = data;
        }

        _hasMore = data.length == _limit;
        _skip += _limit;
      } else {
        throw Exception("Failed to load documents");
      }
    } catch (e) {
      print("Error fetching documents: $e");
    } finally {
      if (isSetFilter) {
        _isLoadingSetFilter = false;
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOfflineDocuments(
      {bool loadMore = false, bool isSetFilter = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await dio.get(
          "/CK_CUSEQUI?\$select=U_ck_AttachmentEntry,U_ck_CusCode,U_ck_CusName,U_ck_eqSerNum,Code,Name,DocEntry,U_ck_siteCode,U_ck_eqStatus,U_ck_eqBrand,U_ck_Remark,U_ck_InstalDate,U_ck_NsvDate,U_ck_WarExpDate,CK_CUSEQUI01Collection,CK_CUSEQUI02Collection &\$orderby=DocEntry desc &\$top=50");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["value"] ;
        if (loadMore) {
          _documentOffline.addAll(data);
        } else {
          _documentOffline = data;
        }
      } else {
        throw Exception("Failed to Download Equipment");
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      if (isSetFilter) {
        _isLoadingSetFilter = false;
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetPagination() {
    _skip = 0;
    _hasMore = true;
    _documents.clear();
  }

  void setFilter(String filter) {
    // if (_currentFilter == filter) return;
    _currentFilter = filter;
    resetPagination();
    fetchDocuments(isSetFilter: true); // Re-fetch with new filter
  }
}
