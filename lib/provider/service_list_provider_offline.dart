
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';

// class ServiceListProviderOffline extends ChangeNotifier {
//   List<dynamic> _documents = [];
//   List<dynamic> _completedServices = [];
//   bool _isLoading = false;

//   List<dynamic> get documents => _documents;
//   List<dynamic> get completedServices => _completedServices;
//   bool get isLoading => _isLoading;

//   late final Box _box;
//   late final Box _completedBox;

//   ServiceListProviderOffline() {
//     _initBox();
//   }

//   Future<void> _initBox() async {
//     _box = await Hive.openBox('service_lists');
//     _completedBox = await Hive.openBox('offlineCompleted');
//     await loadDocuments();
//     // await loadCompletedServices();
//   }

//   /// Load offline documents
//   Future<void> loadDocuments() async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       final rawDocs = _box.get('documents', defaultValue: []) as List<dynamic>;
//       _documents = rawDocs
//           .whereType<Map>()
//           .map((doc) => Map<String, dynamic>.from(doc))
//           .toList();
//     } catch (e) {
//       debugPrint("Error loading offline docs: $e");
//       _documents = [];
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Save documents
//   Future<void> saveDocuments(List<dynamic> docs) async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       await _box.put('documents', docs);
//       _documents = docs;
//     } catch (e) {
//       debugPrint("Error saving offline docs: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Clear documents
//   Future<void> clearDocuments() async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       await _box.delete('documents');
//       _documents = [];
//       await _box.delete('completed');
//       _completedServices = [];
//     } catch (e) {
//       debugPrint("Error clearing offline docs: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Load completed services
//   // Future<void> loadCompletedServices() async {
//   //   final raw =
//   //       _completedBox.get('completed', defaultValue: []) as List<dynamic>;
//   //   _completedServices = raw
//   //       .whereType<Map>()
//   //       .map((doc) => Map<String, dynamic>.from(doc))
//   //       .toList();
//   //   notifyListeners();
//   // }

//   /// Add new completed payload
//   Future<void> addCompletedService(Map<dynamic, dynamic> payload) async {
//     _completedServices.add(payload);
//     await _completedBox.put('completed', _completedServices);
//     notifyListeners();
//   }

//   /// Mark a service as completed in offline docs
//   Future<void> markServiceCompleted(int docEntry) async {
//     List<dynamic> docs =
//         List<dynamic>.from(_box.get('documents', defaultValue: []));
//     for (var doc in docs) {
//       if (doc['DocEntry'] == docEntry) {
//         doc['U_CK_Status'] = 'Entry';
//       }
//     }
//     await _box.put('documents', docs);
//     _documents = docs; // keep in sync with memory
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ServiceListProviderOffline extends ChangeNotifier {
  List<dynamic> _documents = [];
  List<dynamic> _completedServices = [];
  bool _isLoading = false;

  List<dynamic> get documents => _documents;
  List<dynamic> get completedServices => _completedServices;
  bool get isLoading => _isLoading;

  late final Box _box;
  late final Box _completedBox;

  ServiceListProviderOffline() {
    _initBox();
  }

  Future<void> _initBox() async {
    _box = await Hive.openBox('service_lists');
    _completedBox = await Hive.openBox('offlineCompleted');
    await loadDocuments();
    await loadCompletedServices(); // ✅ Ensure this is called
  }

  /// Load offline documents
  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawDocs = _box.get('documents', defaultValue: []) as List<dynamic>;
      _documents = rawDocs
          .whereType<Map>()
          .map((doc) => Map<String, dynamic>.from(doc))
          .toList();
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

  /// Clear documents
  Future<void> clearDocuments() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _box.delete('documents');
      _documents = [];
      await _box.delete('completed');
      _completedServices = [];
    } catch (e) {
      debugPrint("Error clearing offline docs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load completed services from Hive box
  Future<void> loadCompletedServices() async {
    final raw =
        _completedBox.get('completed', defaultValue: []) as List<dynamic>;
    _completedServices = raw
        .whereType<Map>()
        .map((doc) => Map<String, dynamic>.from(doc))
        .toList();
    notifyListeners();
  }

  /// Add new completed payload and store it in Hive
  Future<void> addCompletedService(Map<dynamic, dynamic> payload) async {
    // Add a status to the payload for sync tracking
    final payloadWithStatus = Map<dynamic, dynamic>.from(payload);
    payloadWithStatus['sync_status'] = 'pending';

    _completedServices.add(payloadWithStatus);
    await _completedBox.put('completed', _completedServices);
    notifyListeners();
  }

  /// Mark a service as completed in offline docs
  Future<void> markServiceCompleted(int docEntry) async {
    List<dynamic> docs =
        List<dynamic>.from(_box.get('documents', defaultValue: []));
    for (var doc in docs) {
      if (doc['DocEntry'] == docEntry) {
        doc['U_CK_Status'] = 'Entry';
      }
    }
    await _box.put('documents', docs);
    _documents = docs; // keep in sync with memory
    notifyListeners();
  }

  // 👇 New functions for sync management
  /// Get list of services that are pending sync
  Future<List<Map<dynamic, dynamic>>> getCompletedServicesToSync() async {
    final raw =
        _completedBox.get('completed', defaultValue: []) as List<dynamic>;
    final pendingServices =
        raw.where((service) => service['sync_status'] == 'pending').toList();
    return pendingServices.cast<Map<dynamic, dynamic>>();
  }

  /// Mark a service as successfully synced
  Future<void> markServiceSynced(dynamic docEntry) async {
    final List<dynamic> services =
        _completedBox.get('completed', defaultValue: []);
    final index =
        services.indexWhere((service) => service['DocEntry'] == docEntry);
    if (index != -1) {
      services[index]['sync_status'] = 'synced';
      await _completedBox.put('completed', services);
      notifyListeners();
    }
  }
}
