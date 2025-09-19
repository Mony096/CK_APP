// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';

// class ServiceListProviderOffline extends ChangeNotifier {
//   List<dynamic> _documents = [];
//   bool _isLoading = false;

//   List<dynamic> get documents => _documents;
//   bool get isLoading => _isLoading;

//   Box get _box => Hive.box('service_lists');

//   /// Load docs from Hive
//   Future<void> loadDocuments() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       _documents = _box.get('documents', defaultValue: []);
//     } catch (e) {
//       debugPrint("Error loading offline docs: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Save docs into Hive (called after download from API)
//   Future<void> saveDocuments(List<dynamic> docs) async {
//     await _box.put('documents', docs);
//     _documents = docs;
//     notifyListeners();
//   }

//   /// Clear offline docs
//   Future<void> clearDocuments() async {
//     await _box.delete('documents');
//     _documents = [];
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ServiceListProviderOffline extends ChangeNotifier {
  // Use a specific type for the list to ensure type safety.
  List<dynamic> _documents = [];
  bool _isLoading = false;

  // The getter now returns the correct type.
  List<dynamic> get documents => _documents; 
  bool get isLoading => _isLoading;

  // Use a late final box to ensure it's initialized before use.
  late final Box _box;

  // Constructor to open the box when the provider is created.
  ServiceListProviderOffline() {
    _initBox();
  }

  Future<void> _initBox() async {
    _box = await Hive.openBox('service_lists');
    // Load documents immediately after the box is opened.
    await loadDocuments();
  }

  /// Load documents from Hive.
  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();

    try {
      // The as List<dynamic> is safe because Hive returns a dynamic list.
      final rawDocs = _box.get('documents', defaultValue: []) as List<dynamic>;

      // Map the dynamic list to our specific type, handling potential nulls or incorrect types.
      _documents = rawDocs
          .whereType<Map>()
          .map((doc) => Map<String, dynamic>.from(doc))
          .toList();
      
    } catch (e) {
      debugPrint("Error loading offline docs: $e");
      // On error, clear the list to avoid displaying partial or corrupted data.
      _documents = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save documents into Hive (called after download from API).
  /// Expects a List<Map<String, dynamic>> to maintain type consistency.
  Future<void> saveDocuments(List<dynamic> docs) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use put to save the list. Hive handles the serialization.
      await _box.put('documents', docs);
      // Update the in-memory list with the new data.
      _documents = docs;
    } catch (e) {
      debugPrint("Error saving offline docs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all offline documents from the Hive box.
  Future<void> clearDocuments() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Use delete to remove the key 'documents'.
      await _box.delete('documents');
      // Clear the in-memory list.
      _documents = [];
    } catch (e) {
      debugPrint("Error clearing offline docs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}