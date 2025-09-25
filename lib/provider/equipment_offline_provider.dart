import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// Helper function to convert file to base64 with extension
Future<Map<String, String>> fileToBase64WithExt(File file) async {
  final bytes = await file.readAsBytes();
  final ext = file.path.split('.').last;
  return {
    "ext": ext,
    "data": base64Encode(bytes),
    "name": file.path.split('/').last,
  };
}

class EquipmentOfflineProvider with ChangeNotifier {
  static const String _boxName = "equipment_box";
  static const String _keyEquipments = "equipments";

  bool _submit = false;
  bool get submit => _submit;

  List<Map<String, dynamic>> _equipments = [];
  List<Map<String, dynamic>> get equipments => _equipments;

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
 Future<void> loadEquipments() async {
  final box = Hive.box(_boxName);
  try {
    final raw = box.get(_keyEquipments, defaultValue: []);
    var equipments = (raw as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    // ✅ Apply filter if provided
    if (_filter != null && _filter!.isNotEmpty) {
      equipments = equipments.where((equip) {
        final code = equip["Code"] ?? ""; // or "CardCode" if you store it like docs
        try {
          return code.toString().toLowerCase().contains(_filter!.toLowerCase());
        } catch (e) {
          return false;
        }
      }).toList();
    }

    _equipments = equipments;
  } catch (e) {
    debugPrint("Error loading offline equipments: $e");
    _equipments = [];
  } finally {
    notifyListeners();
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
  Future<void> updateEquipment(int index, Map<String, dynamic> payload) async {
    final box = Hive.box(_boxName);
    final List<dynamic> existing = box.get(_keyEquipments, defaultValue: []);
    if (index >= 0 && index < existing.length) {
      existing[index] = payload;
      await box.put(_keyEquipments, existing);
      await loadEquipments();
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
  Future<bool> saveEquipmentOffline({
    required Map<String, dynamic> data,
  }) async {
    _submit = true;
    notifyListeners();

    try {
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
        "savedAt": DateTime.now().toIso8601String(),
      };

      await addEquipment(payload);
      print(_equipments);
      // Clear temp collections
      clearCollection();
      _submit = false;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("Error saving equipment offline: $e");
      _submit = false;
      notifyListeners();
      return false;
    }
  }
}
