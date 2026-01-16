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

  /// Batch size for fetching records
  static const int _batchSize = 2000;

  /// Progress tracking for UI feedback
  int _fetchedCount = 0;
  int _totalCount = 0;

  int get fetchedCount => _fetchedCount;
  int get totalCount => _totalCount;

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
    _fetchedCount = 0;
    _totalCount = 0;
    notifyListeners();

    try {
      // Step 1: Get total count first
      final countResponse = await dio
          .get("/CK_CUSTSITE/\$count?\$filter=U_ck_type eq 'Customer Site'");

      if (countResponse.statusCode != 200) {
        throw Exception("Failed to get site count");
      }

      _totalCount = int.tryParse(countResponse.data.toString()) ?? 0;
      debugPrint("🏢 Total site count: $_totalCount");
      notifyListeners();

      if (_totalCount == 0) {
        _documentOffline = [];
        return;
      }

      // Step 2: Calculate number of batches needed
      final int totalBatches = (_totalCount / _batchSize).ceil();
      debugPrint(
          "🏢 Will fetch in $totalBatches batches of $_batchSize records");

      // Step 3: Fetch in batches
      List<dynamic> allRecords = [];

      for (int batch = 0; batch < totalBatches; batch++) {
        final int skip = batch * _batchSize;

        debugPrint(
            "🏢 Fetching batch ${batch + 1}/$totalBatches (skip=$skip, top=$_batchSize)");

        final response = await dio.get(
            "/CK_CUSTSITE?\$filter=U_ck_type eq 'Customer Site'&\$select=Code,Name,U_ck_type,U_ck_custcode&\$top=$_batchSize&\$skip=$skip");

        if (response.statusCode == 200) {
          final List<dynamic> batchData = response.data["value"] ?? [];
          allRecords.addAll(batchData);

          // Update progress
          _fetchedCount = allRecords.length;
          notifyListeners();

          debugPrint(
              "🏢 Batch ${batch + 1} fetched: ${batchData.length} records. Total so far: $_fetchedCount");

          // If we got less than batch size, we've reached the end
          if (batchData.length < _batchSize) {
            debugPrint(
                "🏢 Reached end of records (got ${batchData.length} < $_batchSize)");
            break;
          }
        } else {
          throw Exception("Failed to fetch batch ${batch + 1}");
        }
      }

      // Step 4: Set the final result
      if (loadMore) {
        _documentOffline.addAll(allRecords);
      } else {
        _documentOffline = allRecords;
      }

      debugPrint(
          "✅ Successfully fetched ${_documentOffline.length} site records");
    } catch (e) {
      debugPrint("❌ Error fetching sites: $e");
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
