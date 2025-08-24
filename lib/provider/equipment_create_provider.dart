import 'package:flutter/foundation.dart';

class EquipmentCreateProvider with ChangeNotifier {
  String _name = "";
  List<Map<String, dynamic>> _components = [];
  List<Map<String, dynamic>> _parts = [];

  String get name => _name;
  List<Map<String, dynamic>> get components => _components;
  List<Map<String, dynamic>> get parts => _parts;

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void addOrEditComponent(Map<String, dynamic> item, {int editIndex = -1}) {
    if (editIndex == -1) {
      _components.add(item);
    } else {
      _components[editIndex] = item;
    }
    notifyListeners();
  }
    void addOrEditPart(Map<String, dynamic> item, {int editIndex = -1}) {
    if (editIndex == -1) {
      _parts.add(item);
    } else {
      _parts[editIndex] = item;
    }
    notifyListeners();
  }

  void removeComponent(int index) {
    if (index >= 0 && index < _components.length) {
      _components.removeAt(index);
      notifyListeners();
    }
  }
  void removePart(int index) {
    if (index >= 0 && index < _parts.length) {
      _parts.removeAt(index);
      notifyListeners();
    }
  }
  void clearComponents() {
    _components.clear();
    notifyListeners();
  }

  Map<String, dynamic> get fullData => {
        "Name": _name,
        "Component": _components,
        "Part": _parts,
      };
}
