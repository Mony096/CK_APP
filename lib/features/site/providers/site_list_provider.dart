import 'package:bizd_tech_service/core/network/dio_client.dart';
import 'package:flutter/material.dart';

class SiteListProvider extends ChangeNotifier {
  List<dynamic> _documents = [];
    List<dynamic> _documentOffline = [];

  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingSetFilter = false;

  int _skip = 0;
  final int _limit = 20;
  String _currentFilter = "";

  final DioClient dio = DioClient();

  List<dynamic> get documents => _documents;
    List<dynamic> get documentOffline => _documentOffline;

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isLoadingSetFilter => _isLoadingSetFilter;

  String get currentFilter => _currentFilter;
  Future<void> resfreshFetchDocuments({String customer = ''}) async {
    _isLoading = true;
    notifyListeners();
    final String filterCondition = _currentFilter == ""
        ? "&\$filter = U_ck_custcode eq '$customer' and U_ck_type eq 'Customer Site'"
        : "&\$filter=contains(Code,'$_currentFilter') and U_ck_custcode eq '$customer' and U_ck_type eq 'Customer Site'";
    try {
      final response = await dio.get(
          "/CK_CUSTSITE?\$top=$_limit&\$skip=$_skip$filterCondition&\$select=Code,Name,U_ck_type,U_ck_custcode");
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
      {bool loadMore = false,
      bool isSetFilter = false,
      String customer = ''}) async {
    if (_isLoading) return;
    if (isSetFilter) {
      if (_isLoadingSetFilter) return;
      _isLoadingSetFilter = true;
    }
    _isLoading = true;
    notifyListeners();

    final String filterCondition = _currentFilter == ""
        ? "&\$filter = U_ck_custcode eq '$customer' and U_ck_type eq 'Customer Site'"
        : "&\$filter=contains(Code,'$_currentFilter') and U_ck_custcode eq '$customer' and U_ck_type eq 'Customer Site'";
    // print(filterCondition);
    // print(customer);
    // print(_limit);
    // print(_skip);
    try {
      final response = await dio.get(
          "/CK_CUSTSITE?$filterCondition &\$select=Code,Name,U_ck_type,U_ck_custcode &\$top=$_limit&\$skip=$_skip");

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
      {bool loadMore = false,
      bool isSetFilter = false,
      String customer = ''}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

   
    try {
      final response = await dio.get(
          "/CK_CUSTSITE?&\$filter = U_ck_type eq 'Customer Site' &\$select=Code,Name,U_ck_type,U_ck_custcode");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["value"];
        if (loadMore) {
          _documentOffline.addAll(data);
        } else {
          _documentOffline = data;
        }
      } else {
        throw Exception("Failed to Download Site");
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

  void setFilter(String filter, String customer) {
    // if (_currentFilter == filter) return;
    _currentFilter = filter;
    resetPagination();
    fetchDocuments(
        isSetFilter: true, customer: customer); // Re-fetch with new filter
  }
}

