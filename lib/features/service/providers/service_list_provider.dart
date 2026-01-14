import 'package:bizd_tech_service/shared/dialogs/dialog.dart';
import 'package:bizd_tech_service/core/network/dio_client.dart';
import 'package:bizd_tech_service/core/storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServiceListProvider extends ChangeNotifier {
  List<dynamic>_documents = [];
  List<dynamic> _documentTicket = [];

  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingSetFilter = false;

  int _skip = 0;
  final int _limit = 10;
  String _currentFilter = "";
  DateTime? _currentDate; // ðŸ‘ˆ Add date filter

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
 "U_CK_TechnicianId eq $userId and U_CK_Status ne 'Open' and U_CK_Status ne 'Entry'";
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
}

