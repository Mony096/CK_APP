import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:flutter/material.dart';

class ItemListProvider extends ChangeNotifier {
  List<dynamic> _documents = [];
  List<dynamic> _documentOffline = [];

  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingSetFilter = false;

  int _skip = 0;
  final int _limit = 20;
  String _currentFilter = "";

  final DioClient dio = DioClient();
  List<dynamic> get documentOffline => _documentOffline;

  List<dynamic> get documents => _documents;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isLoadingSetFilter => _isLoadingSetFilter;

  String get currentFilter => _currentFilter;
  Future<void> resfreshFetchDocuments() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await dio
          .get("/script/test/GetCkItemLists?\$top=$_limit&\$skip=$_skip");
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

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
        : "&\$filter=contains(ItemCode,'${_currentFilter}')";

    try {
      final response = await dio.get(
          "/script/test/GetCkItemLists?\$top=$_limit&\$skip=$_skip$filterCondition");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
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

  Future<void> fetchDocumentOffline({
    bool loadMore = false,
    bool isSetFilter = false,
    required BuildContext context,
  }) async {
    if (_isLoading) return;
    if (isSetFilter) {
      if (_isLoadingSetFilter) return;
      _isLoadingSetFilter = true;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final query =
          "/script/test/GetCkItemLists";
      final response = await dio.get(query);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (loadMore) {
          _documentOffline.addAll(data);
        } else {
          _documentOffline = data;
        }

        // _hasMore = data.length == _limit;
        // _skip += _limit;
      } else {
        throw Exception("Failed to Download Item");
      }
    } catch (e) {
      await MaterialDialog.warning(
        context,
        title: "Error",
        body: e.toString(),
      );
      print("Error fetching documents Item offline: $e");
    } finally {
      if (isSetFilter) _isLoadingSetFilter = false;
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
