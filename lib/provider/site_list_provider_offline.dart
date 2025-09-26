import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SiteListProviderOffline extends ChangeNotifier {
  List<dynamic> _documents = [];
  bool _isLoading = false;

  List<dynamic> get documents => _documents;
  bool get isLoading => _isLoading;
  String? _filter; // free text filter (e.g., ItemCode)
  String? _custCode; // required filter
  String? get filter => _filter;
  String? get custCode => _custCode;

  late final Box _box;

  SiteListProviderOffline() {
    _initBox();
  }

  Future<void> _initBox() async {
    _box = await Hive.openBox('site_lists');
    await loadDocuments();
  }

  /// Set required Customer Code
  void setCustCode(String customer) {
    _custCode = customer;
    notifyListeners();
  }

  /// Set optional ItemCode filter
  void setFilter(String filter, String customer) {
    _filter = filter;
    _custCode = customer;
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

  /// Load offline documents with required U_CK_CustCode filter
  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawDocs = _box.get('documents', defaultValue: []) as List<dynamic>;
      var docs = rawDocs
          .whereType<Map>()
          .map((doc) => Map<String, dynamic>.from(doc))
          .toList();

      // ✅ Required filter: U_CK_CustCode must match
      if (_custCode != null && _custCode!.isNotEmpty) {
        docs = docs.where((doc) {
          final cust = doc["U_ck_custcode"];
          print(cust);
          return cust != null && cust.toString() == _custCode;
        }).toList();
      }
      // ✅ Optional filter: search ItemCode
      if (_filter != null && _filter!.isNotEmpty) {
        docs = docs.where((doc) {
          final code = doc["Code"];
          final custCode = doc["U_ck_custcode"];
          if (code == null && custCode == null) return false;
          try {
            final filterLower = _filter!.toLowerCase();
            return (code?.toString().toLowerCase().contains(filterLower) ??
                    false) ||
                (custCode?.toString().toLowerCase().contains(filterLower) ??
                    false);
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
