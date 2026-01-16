import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/network/dio_client.dart';
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

  /// Batch size for fetching records
  static const int _batchSize = 2000;

  /// Progress tracking for UI feedback
  int _fetchedCount = 0;
  int _totalCount = 0;

  int get fetchedCount => _fetchedCount;
  int get totalCount => _totalCount;

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

  bool _isCancelled = false;

  void cancelDownload() {
    _isCancelled = true;
    _isLoading = false;
    notifyListeners();
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
    _isCancelled = false;
    _fetchedCount = 0;
    _totalCount = 0;
    notifyListeners();

    try {
      // Step 1: Get total count first
      final countResponse = await dio.get("/Items/\$count");

      if (countResponse.statusCode != 200) {
        throw Exception("Failed to get item count");
      }

      _totalCount = int.tryParse(countResponse.data.toString()) ?? 0;
      debugPrint("📦 Total item count: $_totalCount");
      notifyListeners();

      if (_totalCount == 0) {
        _documentOffline = [];
        return;
      }

      // Step 2: Calculate number of batches needed
      final int totalBatches = (_totalCount / _batchSize).ceil();
      debugPrint(
          "📦 Will fetch in $totalBatches batches of $_batchSize records");

      // Step 3: Fetch in batches
      List<dynamic> allRecords = [];

      for (int batch = 0; batch < totalBatches; batch++) {
        if (_isCancelled) {
          debugPrint("📦 Download cancelled by user");
          _isCancelled = false; // Reset for next time
          throw Exception("cancelled");
        }

        final int skip = batch * _batchSize;

        debugPrint(
            "📦 Fetching batch ${batch + 1}/$totalBatches (skip=$skip, top=$_batchSize)");

        final response = await dio
            .get("/script/test/GetCkItemLists?\$top=$_batchSize&\$skip=$skip");

        if (response.statusCode == 200) {
          final List<dynamic> batchData = response.data is List
              ? response.data
              : (response.data["value"] ?? []);
          allRecords.addAll(batchData);

          // Update progress
          _fetchedCount = allRecords.length;
          notifyListeners();

          debugPrint(
              "📦 Batch ${batch + 1} fetched: ${batchData.length} records. Total so far: $_fetchedCount");

          // If we got less than batch size, we've reached the end
          if (batchData.length < _batchSize) {
            debugPrint(
                "📦 Reached end of records (got ${batchData.length} < $_batchSize)");
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
          "✅ Successfully fetched ${_documentOffline.length} item records");
    } catch (e) {
      if (e.toString().contains("cancelled")) {
        debugPrint("📦 Cleaning up after cancellation...");
        _documentOffline = [];
        throw Exception("cancelled");
      }
      debugPrint("❌ Error fetching items: $e");
      await MaterialDialog.warning(
        context,
        title: "Error",
        body: e.toString(),
      );
      throw Exception(e.toString());
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
