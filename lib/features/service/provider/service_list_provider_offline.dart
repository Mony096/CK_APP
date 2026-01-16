import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart' show DateFormat;

class ServiceListProviderOffline extends ChangeNotifier {
  List<dynamic> _documents = [];
  List<dynamic> _completedServices = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<dynamic> get documents => _documents;
  List<dynamic> get completedServices => _completedServices;
  bool get isLoading => _isLoading;
  DateTime? _currentDate;
  DateTime? get currentDate => _currentDate;
  Box? _box;
  Box? _completedBox;

  ServiceListProviderOffline() {
    _initBox();
  }

  Future<void> _initBox() async {
    if (_isInitialized) return;
    _box = await Hive.openBox('service_lists');
    _completedBox = await Hive.openBox('offlineCompleted');
    _isInitialized = true;
    await loadCompletedServices();
    await loadDocuments();
  }

  void setDate(DateTime date) {
    _currentDate = date;
    notifyListeners();
  }

  void clearCurrentDate() {
    _currentDate = null;
    notifyListeners();
  }

  Future<void> refreshDocuments() async {
    clearCurrentDate();
    await loadDocuments();
  }

  /// Load offline documents

  Future<void> loadDocuments() async {
    if (_box == null) {
      await _initBox();
    }
    _isLoading = true;
    notifyListeners();
    try {
      final rawDocs = _box!.get('documents', defaultValue: []) as List<dynamic>;
      var docs = rawDocs
          .whereType<Map>()
          .map((doc) => Map<String, dynamic>.from(doc))
          .toList();

      // Apply date filter if set
      if (_currentDate != null) {
        docs = docs.where((doc) {
          if (doc["U_CK_Date"] == null) return false;
          try {
            final docDate =
                DateFormat("yyyy-MM-ddTHH:mm:ss").parse(doc["U_CK_Date"]);
            return docDate.year == _currentDate!.year &&
                docDate.month == _currentDate!.month &&
                docDate.day == _currentDate!.day;
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

  /// Get list of existing DocEntries from offline storage
  Future<List<int>> getExistingDocEntries() async {
    if (_box == null) await _initBox();
    try {
      final rawDocs = _box!.get('documents', defaultValue: []) as List<dynamic>;
      final entries = rawDocs
          .whereType<Map>()
          .map((doc) => doc['DocEntry'] as int?)
          .where((entry) => entry != null)
          .cast<int>()
          .toList();
      return entries;
    } catch (e) {
      debugPrint("Error getting existing DocEntries: $e");
      return [];
    }
  }

  /// Merge new documents with existing ones (avoids duplicates)
  Future<void> mergeNewDocuments(List<dynamic> newDocs) async {
    if (_box == null) await _initBox();
    if (newDocs.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final rawDocs = _box!.get('documents', defaultValue: []) as List<dynamic>;
      final existingDocs = rawDocs
          .whereType<Map>()
          .map((doc) => Map<String, dynamic>.from(doc))
          .toList();
      
      // Get existing DocEntries
      final existingEntries = existingDocs
          .map((doc) => doc['DocEntry'] as int?)
          .where((entry) => entry != null)
          .toSet();
      
      // Filter out duplicates and add only new ones
      final uniqueNewDocs = newDocs.where((doc) {
        final entry = doc['DocEntry'] as int?;
        return entry != null && !existingEntries.contains(entry);
      }).map((doc) => Map<String, dynamic>.from(doc as Map)).toList();
      
      if (uniqueNewDocs.isNotEmpty) {
        existingDocs.addAll(uniqueNewDocs);
        await _box!.put('documents', existingDocs);
        debugPrint("✅ Merged ${uniqueNewDocs.length} new documents");
      }
      
      // Reload to apply any filters
      await loadDocuments();
    } catch (e) {
      debugPrint("Error merging new documents: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save documents
  Future<void> saveDocuments(List<dynamic> docs) async {
    if (_box == null) await _initBox();
    _isLoading = true;
    notifyListeners();
    try {
      await _box!.put('documents', docs);
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
    if (_box == null) await _initBox();
    _isLoading = true;
    notifyListeners();
    try {
      await _box!.delete('documents');
      _documents = [];
      await _box!.delete('completed');
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
    if (_completedBox == null) await _initBox();
    final raw =
        _completedBox!.get('completed', defaultValue: []) as List<dynamic>;
    _completedServices = List<dynamic>.from(raw);
    notifyListeners();
  }

  /// Add new completed payload and store it in Hive
  Future<void> addCompletedService(Map<dynamic, dynamic> payload) async {
    if (_completedBox == null) await _initBox();
    // Add a status to the payload for sync tracking
    final Map<dynamic, dynamic> payloadWithStatus = Map<dynamic, dynamic>.from(payload);
    payloadWithStatus['sync_status'] = 'pending';

    _completedServices.add(payloadWithStatus);
    await _completedBox!.put('completed', _completedServices);
    notifyListeners();
  }

  /// Mark a service as completed in offline docs
  Future<void> markServiceCompleted(int docEntry) async {
    if (_box == null) await _initBox();
    List<dynamic> docs =
        List<dynamic>.from(_box!.get('documents', defaultValue: []));

    final now = DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now());

    for (var doc in docs) {
      if (doc['DocEntry'] == docEntry) {
        doc['U_CK_Status'] = 'Entry';
        doc['U_CK_EndTime'] = now.split("T")[1];
      }
    }

    await _box!.put('documents', docs);
    _documents = docs;
    notifyListeners();
  }

  // 👇 New functions for sync management
  /// Get list of services that are pending sync
  Future<List<Map<dynamic, dynamic>>> getCompletedServicesToSync() async {
    if (_completedBox == null) await _initBox();
    final raw =
        _completedBox!.get('completed', defaultValue: []) as List<dynamic>;
    final pendingServices =
        raw.where((service) => service['sync_status'] == 'pending').toList();
    return pendingServices.cast<Map<dynamic, dynamic>>();
  }

  Future<void> updateDocumentAndStatusOffline(
      {required int docEntry,
      required String status,
      required BuildContext context}) async {
    if (_box == null) await _initBox();
    List<dynamic> docs =
        List<dynamic>.from(_box!.get('documents', defaultValue: []));

    final now = DateTime.now();
    final timeStamp = DateFormat("HH:mm:ss").format(now);

    for (var doc in docs) {
      if (doc['DocEntry'] == docEntry) {
        doc['U_CK_Status'] = status;

        if (status == "Accept") {
          doc["U_CK_Time"] = timeStamp;
        } else {
          doc["U_CK_EndTime"] = timeStamp;
        }
      }
    }
    await _box!.put('documents', docs);
    _documents = docs;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: const Color.fromARGB(255, 66, 83, 100),
      behavior: SnackBarBehavior.floating,
      elevation: 10,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      content: const Row(
        children: [
          Icon(Icons.remove_circle, color: Colors.white, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status updated successfully!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 4),
    ));
  }

  /// Mark a service as successfully synced
  Future<void> markServiceSynced(dynamic docEntry) async {
    if (_completedBox == null) await _initBox();
    final List<dynamic> services =
        _completedBox!.get('completed', defaultValue: []);
    final index =
        services.indexWhere((service) => service['DocEntry'] == docEntry);

    if (index != -1) {
      // Remove the service instead of updating status
      services.removeAt(index);

      // Save back to Hive
      await _completedBox!.put('completed', services);

      // Update listeners
      notifyListeners();
    }
  }
}
