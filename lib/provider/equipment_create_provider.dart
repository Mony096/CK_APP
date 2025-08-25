import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EquipmentCreateProvider with ChangeNotifier {
  bool _submit = false;
  List<dynamic> _components = [];
  List<dynamic> _parts = [];

  bool get submit => _submit;
  List<dynamic> get components => _components;
  List<dynamic> get parts => _parts;
  final DioClient dio = DioClient(); // Custom Dio wrapper

  void addOrEditComponent(Map<String, dynamic> item, {int editIndex = -1}) {
    if (editIndex == -1) {
      _components.add(item);
    } else {
      _components[editIndex] = item;
    }
    notifyListeners();
  }

  void setParts(List<dynamic> collection) {
    _parts = collection;
    notifyListeners();
  }

  void setComponents(List<dynamic> collection) {
    _components = collection;
    notifyListeners();
  }

  void clearCollection() {
    _components = [];
    _parts = [];
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

  Future<void> postToSAP({
    required BuildContext context, // ✅ Add BuildContext for UI
    required Map<String, dynamic> data,
  }) async {
    _submit = true;
    notifyListeners();
    MaterialDialog.loading(context); // Show loading dialog

    try {
      final payload = {
        ...data,
        "CK_CUSEQUI01Collection": _components,
        "CK_CUSEQUI02Collection": _parts,
      };
      final create = await dio.post(
        "/CK_CUSEQUI",
        false,
        false,
        data: payload,
      );

      if (create.statusCode == 201) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text("Status updated successfully!"),
        //     backgroundColor: Color.fromARGB(255, 53, 55, 53),
        //     duration: Duration(seconds: 2),
        //   ),
        // );
        await MaterialDialog.createdSuccess(
          context,
        );
      }
    } catch (e) {
      await MaterialDialog.warning(
        context,
        title: "Error",
        body: e.toString(),
      );
    } finally {
      _submit = false;
      _components = [];
      _parts = [];
      MaterialDialog.close(context); // Show loading dialog
      notifyListeners();
    }
  }
}
