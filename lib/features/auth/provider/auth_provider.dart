import 'package:bizd_tech_service/core/network/dio_client.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:bizd_tech_service/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isCheckSessionId = true;
  bool _isCheckPendingObj = false;
  bool _isChangePassword = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isCheckSessionId => _isCheckSessionId;
  bool get isCheckPendingObj => _isCheckPendingObj;
  bool get isChangePassword => _isChangePassword;
  final DioClient dio = DioClient(); // Your custom Dio client

  /// Constructor: Automatically checks session on provider creation
  AuthProvider() {
    checkSession();
  }
  void reset() {
    _isLoggedIn = false;
    _isLoading = false;
    _isCheckSessionId = true;
    _isCheckPendingObj = false;
    notifyListeners();
  }

  /// Login function
  ///
  Future<void> updateToken(String token) async {
    try {
      final userId = await LocalStorageManger.getString('UserId');
      final response = await dio.patch(
        "/EmployeesInfo($userId)",
        false,
        false,
        data: {"U_ck_andriod_token": token},
      );
      // print(response.data);
    } catch (e) {
      rethrow; // Let the caller handle the error
    }
  }

  // Future<List> getCurrUser(String code) async {
  //   try {
  //     final response = await dio.get(
  //       "/EmployeesInfo?\$filter=EmployeeCode eq '$code' & \$select=EmployeeCode,EmployeeID",
  //     );
  //     return response.data["values"];
  //   } catch (e) {
  //     rethrow; // Let the caller handle the error
  //   }
  // }

  Future<bool> login(
      BuildContext context, String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // await LocalStorageManger.setString('SessionId', "1");
      // checkSession();
      //   _isLoggedIn = true;
      //   notifyListeners();
      //   return true;
      final response = await dio.post('/login', true, false, data: {
        "userName": username,
        "password": password,
      });

      // Log the full response for debugging
      debugPrint('════════════════════════════════════════════');
      debugPrint('🔐 LOGIN RESPONSE');
      debugPrint('════════════════════════════════════════════');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint('════════════════════════════════════════════');

      if (response.statusCode == 200) {
        if (response.data["requirePasswordChange"] == true) {
          await LocalStorageManger.setString(
              'SessionId', response.data['token']);
          _isChangePassword = true;
          notifyListeners();
          return true; // Indicate that password change is required
        }

        debugPrint('📦 Saving session data...');
        await LocalStorageManger.setString('SessionId', response.data['token']);
        await LocalStorageManger.setString(
            'UserId', response.data["employeeID"].toString());
        await LocalStorageManger.setString('UserName', username);
        await LocalStorageManger.setString('FullName',
            '${response.data["firstName"]} ${response.data["lastName"]}');
        await LocalStorageManger.setString(
            'FirstName', response.data["firstName"].toString());
        await LocalStorageManger.setString(
            'LastName', response.data["lastName"].toString());
        debugPrint('✅ Session data saved!');

        // FCM Token update - optional (won't work on iOS simulator)
        debugPrint('📱 Getting FCM token...');
        try {
          final FirebaseMessaging messaging = FirebaseMessaging.instance;
          await messaging.requestPermission(
              alert: true, badge: true, sound: true);
          final token = await messaging.getToken();
          if (token != null) {
            print("FCM Token: $token");
            await updateToken(token);
            await LocalStorageManger.setString('frmToken', token);
            debugPrint('✅ FCM token saved!');
          }
        } catch (e) {
          debugPrint('⚠️ FCM Token not available (simulator?): $e');
          // Continue login even if FCM fails - this is expected on iOS simulator
        }
        debugPrint('🔄 Checking session...');
        checkSession();
        _isLoggedIn = true;
        notifyListeners();
        debugPrint('✅ Login complete! Returning true');
        return true;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ LOGIN ERROR: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      MaterialDialog.warning(
        context,
        title: 'Error',
        body: "Failed to login: ${e.toString()}",
      );
    }

    _isLoggedIn = false;
    notifyListeners();
    return false;
  }

  Future<bool> changePassword(
      BuildContext context, String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await dio.patch('/change-password', false, true, data: {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      });

      print("PATCH response status: ${response.statusCode}");
      print("PATCH response data: ${response.data}");

      if (response.statusCode == 200) {
        await LocalStorageManger.removeString('SessionId');
        _isChangePassword = false;
        notifyListeners();
        return true;
      }
    } catch (e, stackTrace) {
      print("❌ Error caught: $e");
      print("📍 StackTrace: $stackTrace");

      MaterialDialog.warning(
        context,
        title: 'Error',
        body: e.toString(),
      );
    }

    _isLoggedIn = false;
    notifyListeners();
    return false;
  }

  /// Logout and clear session
  Future<void> logout() async {
    await updateToken("");
    await LocalStorageManger.removeString('SessionId');
    await FirebaseMessaging.instance.deleteToken();
    _isLoggedIn = false;
    notifyListeners();
  }

  /// Check saved session on app start
  Future<void> checkSession() async {
    notifyListeners();
    try {
      _isCheckSessionId = true;
      final sessionId = await LocalStorageManger.getString('SessionId');
      _isLoggedIn = sessionId.isNotEmpty;
      // final userId = await LocalStorageManger.getString('UserId');
      // final response = await dio.get(
      //     "/DeliveryNotes?\$filter=U_lk_delstat eq 'Pending' and U_lk_driver eq $userId &\$select=U_lk_delstat,U_lk_driver");
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = response.data["value"];
      //   final sessionId = await LocalStorageManger.getString('SessionId');
      //   _isLoggedIn = sessionId.isNotEmpty;
      //   _isCheckPendingObj = data.isNotEmpty;
      // } else {
      //   throw Exception("Failed to load documents");
      // }
      _isCheckSessionId = false;
    } catch (e) {
      _isCheckSessionId = false;
      print(e);
    }

    notifyListeners();
  }
}
