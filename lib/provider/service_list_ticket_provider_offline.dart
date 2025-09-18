import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ServiceTicketListProviderOffline extends ChangeNotifier {
  List<dynamic> _documents = [];
  bool _isLoading = false;

  List<dynamic> get documents => _documents;
  bool get isLoading => _isLoading;

  Box get _box => Hive.box('service_ticket_lists');

  /// Load docs from Hive
  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _documents = _box.get('documents', defaultValue: []);
    } catch (e) {
      debugPrint("Error loading offline docs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save docs into Hive (called after download from API)
  Future<void> saveDocuments(List<dynamic> docs) async {
    await _box.put('documents', docs);
    _documents = docs;
    notifyListeners();
  }

  /// Clear offline docs
  Future<void> clearDocuments() async {
    await _box.delete('documents');
    _documents = [];
    notifyListeners();
  }
}
