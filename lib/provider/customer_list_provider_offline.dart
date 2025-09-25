import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CustomerListProviderOffline extends ChangeNotifier {
  List<dynamic> _documents = [];
  bool _isLoading = false;

  List<dynamic> get documents => _documents;
  bool get isLoading => _isLoading;
  String? _filter;
  String? get filter => _filter;
  late final Box _box;

  CustomerListProviderOffline() {
    _initBox();
  }

  Future<void> _initBox() async {
    _box = await Hive.openBox('customer_lists');
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

  /// Load offline documents

  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawDocs = _box.get('documents', defaultValue: []) as List<dynamic>;
      var docs = rawDocs
          .whereType<Map>()
          .map((doc) => Map<String, dynamic>.from(doc))
          .toList();

      // ✅ Apply date filter if set
      if (_filter != null) {
        docs = docs.where((doc) {
          if (doc["CardCode"] == null) return false;
          try {
            final code = doc["CardCode"];

            return code == _filter;
          } catch (e) {
            return false;
          }
        }).toList();
      }

      _documents = docs;
    } catch (e) {
      debugPrint("Error loading offline docs: $e");
      _documents = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save documents
  Future<void> saveDocuments(List<dynamic> docs) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _box.put('documents', docs);
      _documents = docs;
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
    } catch (e) {
      debugPrint("Error clearing offline docs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
