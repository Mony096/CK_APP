import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/network/dio_client.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServiceListProvider extends ChangeNotifier {
  List<dynamic> _documents = [];
  List<dynamic> _documentTicket = [];

  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingSetFilter = false;

  int _skip = 0;
  final int _limit = 10;
  String _currentFilter = "";
  DateTime? _currentDate; // 👈 Add date filter

  final DioClient dio = DioClient();

  List<dynamic> get documents => _documents;
  List<dynamic> get documentsTicket => _documentTicket;

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isLoadingSetFilter => _isLoadingSetFilter;
  String get currentFilter => _currentFilter;
  DateTime? get currentDate => _currentDate;

  Future<void> resfreshFetchDocuments(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final query = await _buildQuery();
      final response = await dio.get(query);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _documents = data;
      } else {
        throw Exception("Failed to load documents");
      }
    } catch (e) {
      await MaterialDialog.warning(
        context,
        title: "Error",
        body: e.toString(),
      );
      print("Error fetching documents: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDocuments({
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
      final query = await _buildQuery();
      final response = await dio.get(query);

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
      await MaterialDialog.warning(
        context,
        title: "Error",
        body: e.toString(),
      );
      print("Error fetching documents: $e");
    } finally {
      if (isSetFilter) _isLoadingSetFilter = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatusDirectToSAP({
    required dynamic updatePayload,
    required BuildContext context,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    int retryCount = 0;
    const int maxRetries = 3;
    bool success = false;
    dynamic lastError;

    while (retryCount < maxRetries && !success) {
      try {
        if (retryCount > 0) {
          debugPrint(
              "🔄 Retrying SAP status update (Try ${retryCount + 1}/$maxRetries)...");
          await Future.delayed(const Duration(milliseconds: 500));
        }

        final response = await dio.patch(
          "/CK_JOBORDER(${updatePayload['DocEntry']})",
          false,
          false,
          data: updatePayload,
        );

        if (response.statusCode == 204) {
          debugPrint("✅ Status updated to SAP successfully");
          success = true;
        } else {
          throw Exception(
              "SAP responded with status code ${response.statusCode}");
        }
      } catch (e) {
        lastError = e;
        retryCount++;
        debugPrint("❌ Try $retryCount failed: $e");
      }
    }

    if (!success) {
      if (context.mounted) {
        await MaterialDialog.warning(
          context,
          title: "Update Failed",
          body:
              "We couldn't update the status to SAP after $maxRetries attempts. Please check your connection and try again.",
        );
      }
      print("Error updating status after $maxRetries attempts: $lastError");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDocumentTicket({
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
      final query = await _buildQueryTicket();
      final response = await dio.get(query);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (loadMore) {
          _documentTicket.addAll(data);
        } else {
          _documentTicket = data;
        }

        // _hasMore = data.length == _limit;
        // _skip += _limit;
      } else {
        throw Exception("Failed to Download Service");
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      if (isSetFilter) _isLoadingSetFilter = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Build query dynamically
  Future<String> _buildQuery() async {
    final userId = await LocalStorageManger.getString('UserId');
    final String dateNow = DateFormat("yyyy-MM-dd").format(DateTime.now());

    String filter =
        // "U_CK_TechnicianId eq $userId and U_CK_Status ne 'Open' and U_CK_Status ne 'Entry' and U_CK_Date ge '$dateNow'";
        // "U_CK_TechnicianId eq $userId and U_CK_Status ne 'Open' and U_CK_Status ne 'Entry'";
        "U_CK_TechnicianId eq $userId and U_CK_Status ne 'Completed'";

    // Add text filter
    if (_currentFilter.isNotEmpty) {
      filter += " and contains(Code,'$_currentFilter')";
    }

    // Add date filter (if selected)
    if (_currentDate != null) {
      final dateStr = DateFormat("yyyy-MM-dd").format(_currentDate!);
      filter += " and U_CK_Date eq '$dateStr'";
    }

    print("Final Filter: $filter");
    return "/script/test/GetCkServiceLists?\$filter=$filter&\$top=$_limit&\$skip=$_skip";
  }

  void resetPagination() {
    _skip = 0;
    _hasMore = true;
    _documents.clear();
  }

  /// Build query dynamically Ticket
  Future<String> _buildQueryTicket() async {
    final userId = await LocalStorageManger.getString('UserId');
    final String dateNow = DateFormat("yyyy-MM-dd").format(DateTime.now());

    // String filter = "U_CK_TechnicianId eq $userId and U_CK_Date ge '$dateNow'";
    String filter = "U_CK_TechnicianId eq $userId";

    // Add text filter
    if (_currentFilter.isNotEmpty) {
      filter += " and contains(Code,'$_currentFilter')";
    }

    // Add date filter (if selected)
    if (_currentDate != null) {
      final dateStr = DateFormat("yyyy-MM-dd").format(_currentDate!);
      filter += " and U_CK_Date eq '$dateStr'";
    }

    print("Final Filter: $filter");
    return "/script/test/GetCkServiceLists?\$filter=$filter";
  }

  void setFilter(String filter, BuildContext context) {
    _currentFilter = filter;
    resetPagination();
    fetchDocuments(isSetFilter: true, context: context);
  }

  void setDate(DateTime date, BuildContext context) {
    _currentDate = date;
    resetPagination();
    fetchDocuments(isSetFilter: true, context: context);
  }

  void clearCurrentDate() {
    _currentDate = null;
  }

  /// Fetch NEW services from API that don't exist in offline storage
  /// Returns the list of new documents fetched (or empty list if offline/error)
  Future<List<dynamic>> fetchNewServicesForSync({
    required List<int> existingDocEntries,
  }) async {
    if (_isLoading) return [];
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await LocalStorageManger.getString('UserId');

      // Build filter to exclude existing DocEntries
      String today = DateTime.now().toIso8601String().split('T')[0];

      String filter = "U_CK_TechnicianId eq $userId "
          "and (U_CK_Status eq 'Open' or U_CK_Status eq 'Pending' or U_CK_Status eq 'Accept' or U_CK_Status eq 'Travel' or U_CK_Status eq 'Service') "
          "and U_CK_Date ge '$today'";
      // Add DocEntry exclusion filter if there are existing entries
      if (existingDocEntries.isNotEmpty) {
        // Build filter like: DocEntry ne 1 and DocEntry ne 2 and DocEntry ne 3
        final excludeFilter = existingDocEntries
            .map((entry) => "DocEntry ne $entry")
            .join(" and ");
        filter += " and $excludeFilter";
      }

      int retryCount = 0;
      const int maxRetries = 3;
      dynamic lastError;

      while (retryCount < maxRetries) {
        try {
          debugPrint(
              "📡 Fetching new services with filter: $filter (Attempt ${retryCount + 1}/$maxRetries)");

          final response =
              await dio.get("/script/test/GetCkServiceLists?\$filter=$filter");

          if (response.statusCode == 200) {
            final List<dynamic> data = response.data;
            debugPrint("✅ Fetched ${data.length} new services from API");
            return data;
          } else {
            debugPrint(
                "❌ Failed to fetch services: ${response.statusCode} (Attempt ${retryCount + 1})");
            lastError = "Status code: ${response.statusCode}";
            // If it's the last attempt, we let the loop finish and return empty
          }
        } catch (e) {
          debugPrint(
              "❌ Error fetching new services: $e (Attempt ${retryCount + 1})");
          lastError = e;
        }

        retryCount++;
        if (retryCount < maxRetries) {
          // Wait a bit before retrying
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      debugPrint("❌ All $maxRetries attempts failed. Last error: $lastError");
      return [];
    } catch (e) {
      debugPrint("❌ Critical error in fetchNewServicesForSync: $e");
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
