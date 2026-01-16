import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ItemListProviderOffline extends ChangeNotifier {
  List<dynamic> _documents = [];
  bool _isLoading = false;

  List<dynamic> get documents => _documents;
  bool get isLoading => _isLoading;
  String? _filter;
  String? get filter => _filter;
  late final Box _box;

  // Pagination State
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMore = true;
  List<dynamic> _allFilteredDocuments = [];

  bool get hasMore => _hasMore;
  int get totalRecords => _allFilteredDocuments.length;
  int get currentCount => _documents.length;
  int get currentPage => _currentPage;
  int get totalPages => (_allFilteredDocuments.length / _pageSize).ceil();
  bool get canNext => _currentPage < totalPages;
  bool get canPrev => _currentPage > 1;

  ItemListProviderOffline() {
    _initBox();
  }

  Future<void> _initBox() async {
    _box = await Hive.openBox('item_lists');
    await loadDocuments();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void clearFilter() {
    _filter = null;
    notifyListeners();
  }

  Future<void> refreshDocuments() async {
    clearFilter();
    await loadDocuments();
  }

  /// Load offline documents with pagination
  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawDocs = _box.get('documents', defaultValue: []) as List<dynamic>;
      var allDocs = rawDocs
          .whereType<Map>()
          .map((doc) => Map<String, dynamic>.from(doc))
          .toList();

      // Apply filter if set
      if (_filter != null && _filter!.isNotEmpty) {
        final query = _filter!.toLowerCase();
        allDocs = allDocs.where((doc) {
          final code = doc["ItemCode"]?.toString().toLowerCase() ?? "";
          final name = doc["ItemName"]?.toString().toLowerCase() ?? "";
          return code.contains(query) || name.contains(query);
        }).toList();
      }

      // Sort by ItemCode
      allDocs
          .sort((a, b) => (a["ItemCode"] ?? "").compareTo(b["ItemCode"] ?? ""));

      _allFilteredDocuments = allDocs;
      _currentPage = 1;

      _updateVisibleDocuments();
    } catch (e) {
      debugPrint("Error loading offline docs: $e");
      _documents = [];
      _allFilteredDocuments = [];
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateVisibleDocuments() {
    final int startIndex = (_currentPage - 1) * _pageSize;
    final int endIndex = (startIndex + _pageSize) < _allFilteredDocuments.length
        ? (startIndex + _pageSize)
        : _allFilteredDocuments.length;

    if (startIndex < _allFilteredDocuments.length) {
      _documents = _allFilteredDocuments.sublist(startIndex, endIndex);
    } else {
      _documents = [];
    }
    _hasMore = _currentPage < totalPages;
    notifyListeners();
  }

  void nextPage() {
    if (canNext) {
      _currentPage++;
      _updateVisibleDocuments();
    }
  }

  void previousPage() {
    if (canPrev) {
      _currentPage--;
      _updateVisibleDocuments();
    }
  }

  void firstPage() {
    if (_currentPage != 1) {
      _currentPage = 1;
      _updateVisibleDocuments();
    }
  }

  void lastPage() {
    if (_currentPage != totalPages && totalPages > 0) {
      _currentPage = totalPages;
      _updateVisibleDocuments();
    }
  }

  /// Save documents
  Future<void> saveDocuments(List<dynamic> docs) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _box.put('documents', docs);
      await loadDocuments();
    } catch (e) {
      debugPrint("Error saving offline docs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearDocuments() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _box.delete('documents');
      _documents = [];
      _allFilteredDocuments = [];
      _hasMore = false;
    } catch (e) {
      debugPrint("Error clearing offline docs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
