import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart' show DateFormat;

class ServiceListProviderOffline extends ChangeNotifier {
  List<dynamic> _documents = [];
  List<dynamic> _completedServices = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isSyncing = false;

  List<dynamic> get documents => _documents;
  List<dynamic> get completedServices => _completedServices;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;

  void setSyncing(bool value) {
    _isSyncing = value;
    notifyListeners();
  }

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

  Future<Map<String, dynamic>?> getDocumentByDocEntry(int docEntry) async {
    if (_box == null) await _initBox();
    try {
      final rawDocs = _box!.get('documents', defaultValue: []) as List<dynamic>;
      final docs = rawDocs
          .whereType<Map>()
          .map((doc) => Map<String, dynamic>.from(doc))
          .toList();
      return docs.firstWhere((doc) => doc['DocEntry'] == docEntry);
    } catch (e) {
      debugPrint("Error getting document by DocEntry: $e");
      return null;
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
      final uniqueNewDocs = newDocs
          .where((doc) {
            final entry = doc['DocEntry'] as int?;
            return entry != null && !existingEntries.contains(entry);
          })
          .map((doc) => Map<String, dynamic>.from(doc as Map))
          .toList();

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
    if (_box == null || _completedBox == null) await _initBox();
    _isLoading = true;
    notifyListeners();
    try {
      await _box!.delete('documents');
      _documents = [];
      await _completedBox!.delete('completed');
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
    await autoCleanupSyncedServices();
    notifyListeners();
  }

  /// Automatically remove synced services that are older than today
  Future<void> autoCleanupSyncedServices() async {
    if (_completedBox == null) await _initBox();

    final List<dynamic> services =
        List<dynamic>.from(_completedBox!.get('completed', defaultValue: []));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool changed = false;
    final List<dynamic> filteredServices = services.where((service) {
      if (service['sync_status'] == 'synced') {
        final dateStr = service['U_CK_Date'];
        if (dateStr != null) {
          try {
            // Handle both YYYY-MM-DD and YYYY-MM-DDTHH:mm:ss
            final date = DateTime.parse(dateStr.toString().split('T')[0]);
            if (date.isBefore(today)) {
              changed = true;
              return false; // Remove this synced service
            }
          } catch (e) {
            debugPrint("Error parsing date for cleanup: $e");
          }
        }
      }
      return true;
    }).toList();

    if (changed) {
      await _completedBox!.put('completed', filteredServices);
      _completedServices = filteredServices;
      debugPrint(
          "🧹 Auto-cleaned ${services.length - filteredServices.length} old synced services");
    }
  }

  /// Add new completed payload and store it in Hive
  Future<void> addCompletedService(Map<dynamic, dynamic> payload) async {
    if (_completedBox == null) await _initBox();

    final Map<dynamic, dynamic> payloadWithStatus =
        Map<dynamic, dynamic>.from(payload);
    payloadWithStatus['sync_status'] = 'pending';

    // Remove old entry if same DocEntry exists to avoid duplicates
    _completedServices.removeWhere(
        (s) => s['DocEntry'].toString() == payload['DocEntry'].toString());

    _completedServices.add(payloadWithStatus);
    await _completedBox!.put('completed', _completedServices);
    notifyListeners();
    debugPrint("📂 Added DocEntry ${payload['DocEntry']} to pending sync list");
  }

  /// Mark a service as completed in offline docs
  Future<void> markServiceCompleted(dynamic docEntry) async {
    if (_box == null) await _initBox();
    List<dynamic> docs =
        List<dynamic>.from(_box!.get('documents', defaultValue: []));

    final now = DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now());
    bool found = false;

    for (var doc in docs) {
      if (doc['DocEntry'].toString() == docEntry.toString()) {
        doc['U_CK_Status'] = 'Entry';
        doc['U_CK_EndTime'] = now.split("T")[1];
        found = true;
      }
    }

    if (found) {
      await _box!.put('documents', docs);
      _documents = docs;
      notifyListeners();
      debugPrint("✅ Marked DocEntry $docEntry as 'Entry' offline");
    } else {
      debugPrint("⚠️ Could not find DocEntry $docEntry to mark as completed");
    }
  }
  /// Add new completed payload and store it in Hive
  Future<void> addCompletedReject(Map<dynamic, dynamic> payload) async {
    if (_completedBox == null) await _initBox();

    final Map<dynamic, dynamic> payloadWithStatus =
        Map<dynamic, dynamic>.from(payload);
    payloadWithStatus['sync_status'] = 'pending';

    // Remove old entry if same DocEntry exists to avoid duplicates
    _completedServices.removeWhere(
        (s) => s['DocEntry'].toString() == payload['DocEntry'].toString());

    _completedServices.add(payloadWithStatus);
    await _completedBox!.put('completed', _completedServices);
    notifyListeners();
    debugPrint("📂 Added DocEntry ${payload['DocEntry']} to pending sync list");
  }

  /// Mark a service as completed in offline docs
  Future<void> markServiceCompletedReject(dynamic docEntry) async {
    if (_box == null) await _initBox();
    List<dynamic> docs =
        List<dynamic>.from(_box!.get('documents', defaultValue: []));

    // final now = DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now());
    bool found = false;

    for (var doc in docs) {
      if (doc['DocEntry'].toString() == docEntry.toString()) {
        doc['U_CK_Status'] = 'Rejected';
        found = true;
      }
    }

    if (found) {
      await _box!.put('documents', docs);
      _documents = docs;
      notifyListeners();
      debugPrint("✅ Marked DocEntry $docEntry as 'Rejected' offline");
    } else {
      debugPrint("⚠️ Could not find DocEntry $docEntry to mark as rejecte");
    }
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

  int get pendingSyncCount {
    if (_completedBox == null) return 0;
    final raw =
        _completedBox!.get('completed', defaultValue: []) as List<dynamic>;
    return raw.where((service) => service['sync_status'] == 'pending').length;
  }

  Future<void> updateDocumentAndStatusOffline({
    required int docEntry,
    required String status,
    String? time,
    required BuildContext context,
  }) async {
    if (_box == null) await _initBox();

    try {
      final rawDocs = _box!.get('documents', defaultValue: []) as List<dynamic>;
      List<Map<String, dynamic>> docs = rawDocs
          .whereType<Map>()
          .map((doc) => Map<String, dynamic>.from(doc))
          .toList();

      final now = DateTime.now();
      final timeStamp = time ?? DateFormat("HH:mm:ss").format(now);

      bool found = false;
      // for (var doc in docs) {
      //   if (doc['DocEntry'] == docEntry) {
      //     doc['U_CK_Status'] = status;

      //     // Update time fields based on status
      //     if (status == "Accept") {
      //       doc["U_CK_Time"] = timeStamp;
      //     } else {
      //       doc["U_CK_EndTime"] = timeStamp;
      //     }
      //     found = true;
      //     break;
      //   }
      // }
      for (var doc in docs) {
        if (doc['DocEntry'] == docEntry) {
          doc['U_CK_Status'] = status;

          // Main time fields
          if (status == "Accept") {
            doc["U_CK_Time"] = timeStamp;
          } else {
            doc["U_CK_EndTime"] = timeStamp;
          }
          print(doc['U_CK_Status']);
          // Status-specific tracking time
          switch (status) {
            case "Accept":
              doc["AcceptTime"] = timeStamp;
              break;
            case "Travel":
              doc["TravelTime"] = timeStamp;
              break;
            case "Service":
              doc["ServiceTime"] = timeStamp;
              break;
            case "Rejected":
              doc["RejectedTime"] = timeStamp;
              break;
          }

          found = true;
          break;
        }
      }

      if (found) {
        await _box!.put('documents', docs);
        _documents = docs;
        notifyListeners();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor:
                  const Color.fromARGB(255, 46, 125, 50), // Green for success
              behavior: SnackBarBehavior.floating,
              elevation: 4,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    "Status updated to $status",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Error updating offline document: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Mark a service as successfully synced
  Future<void> markServiceSynced(dynamic docEntry) async {
    if (_completedBox == null) await _initBox();
    final List<dynamic> services =
        List<dynamic>.from(_completedBox!.get('completed', defaultValue: []));
    final index = services.indexWhere(
        (service) => service['DocEntry'].toString() == docEntry.toString());

    if (index != -1) {
      // Update status to synced
      services[index]['sync_status'] = 'synced';

      // Save back to Hive
      await _completedBox!.put('completed', services);

      // Update local list
      _completedServices = services;

      // Update listeners
      notifyListeners();
    }
  }

  /// Get sync status for a specific service
  String getSyncStatus(dynamic docEntry) {
    if (docEntry == null) return 'synced';

    final entry = _completedServices.firstWhere(
      (s) => s['DocEntry'].toString() == docEntry.toString(),
      orElse: () => null,
    );

    if (entry != null) {
      return entry['sync_status'];
    }

    // If we have completed services but this one isn't there, it might be an older one already synced.
    // However, we should be careful about returning 'synced' too easily.
    return 'synced';
  }
}
