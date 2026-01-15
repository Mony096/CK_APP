import 'dart:convert';
import 'dart:io';

import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// Helper function to convert file to base64 with extension
Future<Map<String, String>> fileToBase64WithExt(File file) async {
  final bytes = await file.readAsBytes();
  final base64Data = base64Encode(bytes);

  // Detect extension safely
  final path = file.path.toLowerCase();
  String ext = "bin"; // fallback
  if (path.endsWith(".png"))
    ext = "png";
  else if (path.endsWith(".jpg") || path.endsWith(".jpeg"))
    ext = "jpg";
  else if (path.endsWith(".pdf"))
    ext = "pdf";
  else if (path.endsWith(".gif")) ext = "gif";

  return {"ext": ext, "data": base64Data};
}

class EquipmentOfflineProvider with ChangeNotifier {
  static const String _boxName = "equipment_box";
  static const String _keyEquipments = "equipments";

  bool _submit = false;
  bool get submit => _submit;

  List<dynamic> _equipments = [];
  List<dynamic> get equipments => _equipments;

  List<dynamic> _components = [];
  List<dynamic> _parts = [];
  List<File> _imagesList = [];
  String? _filter;

  String? get filter => _filter;
  List<dynamic> get components => _components;
  List<dynamic> get parts => _parts;
  List<File> get imagesList => _imagesList;

  EquipmentOfflineProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    if (!Hive.isAdapterRegistered(0)) {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
    }
    await Hive.openBox(_boxName);
    await loadEquipments();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void clearFilter() {
    _filter = null;
    notifyListeners();
  }

  /// Load all equipments from Hive
  // Future<void> loadEquipments() async {
  //   final box = Hive.box(_boxName);
  //   try {
  //     final raw = box.get(_keyEquipments, defaultValue: []);
  //     var equipments = (raw as List)
  //         .whereType<Map>()
  //         .map((e) => Map<String, dynamic>.from(e))
  //         .toList();

  //     // ✅ Apply filter if provided
  //     if (_filter != null && _filter!.isNotEmpty) {
  //       equipments = equipments.where((equip) {
  //         final code =
  //             equip["Code"] ?? ""; // or "CardCode" if you store it like docs
  //         try {
  //           return code
  //               .toString()
  //               .toLowerCase()
  //               .contains(_filter!.toLowerCase());
  //         } catch (e) {
  //           return false;
  //         }
  //       }).toList();
  //     }

  //     _equipments = equipments;
  //   } catch (e) {
  //     debugPrint("Error loading offline equipments: $e");
  //     _equipments = [];
  //   } finally {
  //     notifyListeners();
  //   }
  // }
  Future<void> loadEquipments() async {
    final box = Hive.box(_boxName);
    try {
      final raw = box.get(_keyEquipments, defaultValue: []);
      var equipments = (raw as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // Apply filter if provided
      if (_filter != null && _filter!.isNotEmpty) {
        equipments = equipments.where((equip) {
          final code = equip["Code"] ?? "";
          try {
            return code
                .toString()
                .toLowerCase()
                .contains(_filter!.toLowerCase());
          } catch (e) {
            return false;
          }
        }).toList();
      }

      // Sort by savedAt descending; if missing, order by DocEntry descending
      equipments.sort((a, b) {
        final aSavedAt = a['savedAt']?.toString();
        final bSavedAt = b['savedAt']?.toString();

        if (aSavedAt != null && bSavedAt != null) {
          return bSavedAt.compareTo(aSavedAt);
        } else if (aSavedAt != null) {
          return -1; // a comes first
        } else if (bSavedAt != null) {
          return 1; // b comes first
        } else {
          // both savedAt missing, fallback to DocEntry descending
          final aDoc = a['DocEntry'] ?? 0;
          final bDoc = b['DocEntry'] ?? 0;
          return (bDoc as int).compareTo(aDoc as int);
        }
      });

      _equipments = equipments;
    } catch (e) {
      debugPrint("Error loading offline equipments: $e");
      _equipments = [];
    } finally {
      notifyListeners();
    }
  }

  Future<void> saveDocuments(List<dynamic> docs) async {
    try {
      final box = await Hive.openBox(_boxName); // make sure the box is open
      await box.put(_keyEquipments, docs); // save the list
      _equipments = docs; // update local state
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving offline equipments: $e");
    }
  }

  /// Save a new equipment offline
  Future<void> addEquipment(Map<String, dynamic> payload) async {
    final box = Hive.box(_boxName);
    final List<dynamic> existing = box.get(_keyEquipments, defaultValue: []);
    existing.add(payload);
    await box.put(_keyEquipments, existing);
    await loadEquipments(); // refresh
  }

  /// Update an existing equipment by index
  /// Update an existing equipment by looking for its 'id'
  Future<void> updateEquipment(Map<String, dynamic> payload) async {
    // 1. Get the box and the existing list
    final box = Hive.box(_boxName);
    final List<dynamic> existing = box.get(_keyEquipments, defaultValue: []);

    // 2. Get the ID of the equipment we want to update
    final idToUpdate = payload['Code'];

    // Check if we have an ID to work with
    if (idToUpdate == null) {
      debugPrint("Error: Payload is missing a unique 'id' for update.");
      return;
    }

    // 3. Find the index of the equipment with the matching ID
    // We cast to Map<String, dynamic> to safely access the 'id' key.
    final indexToUpdate = existing.indexWhere(
      (item) => (item as dynamic)['Code'] == idToUpdate,
    );

    // 4. Update the list if the item was found
    if (indexToUpdate != -1) {
      existing[indexToUpdate] = payload; // Update the item at the found index

      // 5. Save the updated list and refresh local state
      await box.put(_keyEquipments, existing);
      await loadEquipments(); // refresh
    } else {
      debugPrint(
          "Warning: Equipment with ID $idToUpdate not found for update.");
    }
  }

  //refresh
  Future<void> refreshDocuments() async {
    clearFilter();
    await loadEquipments();
  }

  /// Remove equipment by index
  Future<void> removeEquipment(int index) async {
    final box = Hive.box(_boxName);
    final List<dynamic> existing = box.get(_keyEquipments, defaultValue: []);
    if (index >= 0 && index < existing.length) {
      existing.removeAt(index);
      await box.put(_keyEquipments, existing);
      await loadEquipments();
    }
  }

  /// Clear all offline equipments
  Future<void> clearEquipments() async {
    final box = Hive.box(_boxName);
    await box.delete(_keyEquipments);
    _equipments = [];
    notifyListeners();
  }

  /// Add or edit a component
  void addOrEditComponent(Map<String, dynamic> item, {int editIndex = -1}) {
    if (editIndex == -1) {
      _components.add(item);
    } else {
      _components[editIndex] = item;
    }
    notifyListeners();
  }

  void clearComponents() {
    _components.clear();
    notifyListeners();
  }

  /// Add or edit a part
  void addOrEditPart(Map<String, dynamic> item, {int editIndex = -1}) {
    if (editIndex == -1) {
      _parts.add(item);
    } else {
      _parts[editIndex] = item;
    }
    notifyListeners();
  }

  void clearParts() {
    _parts.clear();
    notifyListeners();
  }

  /// Manage images
  void addImages(List<File> images) {
    _imagesList.addAll(images);
    notifyListeners();
  }

  void clearImages() {
    _imagesList.clear();
    notifyListeners();
  }

  /// Set components directly
  void setComponents(List<dynamic> collection) {
    _components = collection;
    notifyListeners();
  }

  /// Set parts directly
  void setParts(List<dynamic> collection) {
    _parts = collection;
    notifyListeners();
  }

  /// Set images directly (List<File>)
  void setImages(List<File> images) {
    _imagesList = images;
    notifyListeners();
  }

// Remove component
  void removeComponent(int index) {
    if (index >= 0 && index < _components.length) {
      _components.removeAt(index);
      notifyListeners();
    }
  }

  // Remove part
  void removePart(int index) {
    if (index >= 0 && index < _parts.length) {
      _parts.removeAt(index);
      notifyListeners();
    }
  }

  void clearCollection() {
    _components = [];
    _parts = [];
    _imagesList = [];
    notifyListeners();
  }

  /// Save equipment offline with components, parts, and images as base64
  Future<bool> saveEquipmentOffline(
      {required Map<String, dynamic> data,
      required BuildContext context}) async {
    _submit = true;
    MaterialDialog.loading(context); // Show loading dialog

    notifyListeners();

    try {
      // --- Check for duplicate code ---
      final existing = _equipments.firstWhere(
        (e) => e['Code'] == data['Code'],
        orElse: () => <String, dynamic>{},
      );

      if (existing.isNotEmpty) {
        MaterialDialog.close(context); // Close loading before throwing
        throw Exception("Equipment with code ${data['Code']} already exists!");
      }

      // Convert images to base64
      List<Map<String, String>> fileDataList = [];
      for (File imageFile in _imagesList) {
        fileDataList.add(await fileToBase64WithExt(imageFile));
      }

      final payload = {
        ...data,
        "files": fileDataList,
        "CK_CUSEQUI01Collection": _components,
        "CK_CUSEQUI02Collection": _parts,
        "sync_status": "pending", // or use isPending: true
        "savedAt": DateTime.now().toIso8601String(),
      };

      await addEquipment(payload);
      print(_equipments);
      // Clear temp collections
      clearCollection();
      MaterialDialog.close(context); // Show loading dialog

      _submit = false;
      _components = [];
      _parts = [];
      _imagesList = [];
      await MaterialDialog.createdSuccess(
        context,
      );
      notifyListeners();

      return true;
    } catch (e) {
      await MaterialDialog.warningStayScreenWhenOk(
        context,
        title: "Error",
        body: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }
}
