import 'dart:convert';
import 'dart:developer';

import 'package:bizd_tech_service/core/error/failure.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:dio/dio.dart';

/// Safely extracts error message from API response
/// Handles various error response formats from SAP and other APIs
String _extractErrorMessage(Response? response) {
  try {
    if (response?.data == null) {
      return "An unexpected error occurred.";
    }

    final data = response!.data;

    // Handle Map response
    if (data is Map) {
      // Try SAP B1 format: { error: { message: { value: "..." } } }
      if (data['error'] is Map) {
        final error = data['error'] as Map;
        if (error['message'] is Map) {
          final message = error['message']['value'];
          if (message != null && message.toString().isNotEmpty) {
            return message.toString();
          }
        }
        // Fallback: { error: { message: "..." } }
        if (error['message'] is String &&
            error['message'].toString().isNotEmpty) {
          return error['message'].toString();
        }
      }

      // Try common formats: { message: "..." } or { error: "..." }
      if (data['message'] is String && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }
      if (data['error'] is String && data['error'].toString().isNotEmpty) {
        return data['error'].toString();
      }
    }

    // Handle String response
    if (data is String && data.isNotEmpty) {
      return data;
    }

    return "An unexpected error occurred.";
  } catch (e) {
    log('Error extracting error message: $e');
    return "An unexpected error occurred.";
  }
}

class DioClient {
  Dio _dio = Dio();

  // Create a new CancelToken
  final cancelToken = CancelToken();

  DioClient() {
    _dio = Dio(
      BaseOptions(
        receiveDataWhenStatusError: true,
        // connectTimeout: const Duration(seconds: 5),
        // receiveTimeout: const Duration(seconds: 5),
      ),
    );
  }
  Future<Response> get(String uri,
      {Options? options, Map<String, dynamic>? query}) async {
    try {
      final token = await LocalStorageManger.getString('SessionId');
      final host = await LocalStorageManger.getString('host');
      final port = await LocalStorageManger.getString('port');

      final res = await _dio.get(
        '${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/sapIntegration',
        queryParameters: query,
        options: Options(
          headers: {
            'Content-Type': "application/json",
            "Authorization": 'Bearer $token',
            'sapUrl': uri
          },
        ),
        cancelToken: cancelToken,
      );
      return res;
    } on DioException catch (e) {
      log(e.requestOptions.method);
      log(e.requestOptions.uri.toString());
      log(jsonEncode(e.requestOptions.data));
      log('dio ${e.response?.statusCode}');
      log(jsonEncode(e.requestOptions.headers));
      if (e.response?.statusCode == null) {
        throw const ConnectionRefuse(
          message: "Invalid Server Configuration",
        );
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const ConnectionRefuse(
          message: "Invalid server host name.",
        );
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ConnectionRefuse(
          message:
              "Sorry, our server is currently unavailable. Please contact our support.",
        );
      }
      if (e.response?.statusCode == 401) {
        throw const UnauthorizeFailure(message: 'Session already timeout');
      }

      throw ServerFailure(
        message: _extractErrorMessage(e.response),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getAttachment(String uri,
      {Options? options, Map<String, dynamic>? query}) async {
    try {
      final token = await LocalStorageManger.getString('SessionId');
      final host = await LocalStorageManger.getString('host');
      final port = await LocalStorageManger.getString('port');

      final res = await _dio.get(
        '${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/sapIntegration/Attachments2',
        queryParameters: query,
        options: Options(
          headers: {
            'Content-Type': "application/json",
            "Authorization": 'Bearer $token',
            'sapUrl': uri
          },
        ),
        cancelToken: cancelToken,
      );
      return res;
    } on DioException catch (e) {
      log(e.requestOptions.method);
      log(e.requestOptions.uri.toString());
      log(jsonEncode(e.requestOptions.data));
      log('dio ${e.response?.statusCode}');
      log(jsonEncode(e.requestOptions.headers));
      if (e.response?.statusCode == null) {
        throw const ConnectionRefuse(
          message: "Invalid Server Configuration",
        );
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const ConnectionRefuse(
          message: "Invalid server host name.",
        );
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ConnectionRefuse(
          message:
              "Sorry, our server is currently unavailable. Please contact our support.",
        );
      }
      if (e.response?.statusCode == 401) {
        throw const UnauthorizeFailure(message: 'Session already timeout');
      }

      throw ServerFailure(
        message: _extractErrorMessage(e.response),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    dynamic uri,
    bool isLogin,
    bool isFormData, {
    Options? options,
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final token = await LocalStorageManger.getString('SessionId');
      final host = await LocalStorageManger.getString('host');
      final port = await LocalStorageManger.getString('port');

      final response = await _dio.post(
        isLogin
            ? '${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/auth$uri'
            : '${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/sapIntegration${isFormData ? '/Attachments2' : ""}',
        data: data,
        options: Options(
          headers: {
            'Content-Type':
                isFormData ? 'multipart/form-data' : 'application/json',
            'Authorization': 'Bearer $token',
            'sapUrl': uri,
            ...?options?.headers, // merge user-provided headers
          },
        ),
        cancelToken: cancelToken,
        queryParameters: queryParameters,
      );

      return response;
    } on DioException catch (e) {
      log(e.requestOptions.method);
      log(e.requestOptions.uri.toString());

      if (e.requestOptions.data is FormData) {
        log('[FormData] - skipped logging raw content.');
      } else {
        log(jsonEncode(e.requestOptions.data));
      }

      log('dio ${e.response?.statusCode}');
      log('dio ${e.response?.data}');
      if (e.response?.statusCode == null) {
        throw const ConnectionRefuse(message: "Invalid Server Configuration");
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const ConnectionRefuse(message: "Invalid server host name.");
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ConnectionRefuse(
          message:
              "Sorry, our server is currently unavailable. Please contact our support.",
        );
      }
      if (e.response?.statusCode == 401) {
        throw UnauthorizeFailure(
            message: 'Oops. Invalid Request or ${e.response?.data['error']}.');
      }

      throw ServerFailure(
        message: _extractErrorMessage(e.response),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> postNotification(
    dynamic uri, {
    Options? options,
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final token = await LocalStorageManger.getString('SessionId');
      final host = await LocalStorageManger.getString('host');
      final port = await LocalStorageManger.getString('port');

      final response = await _dio.post(
        '${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/notifications/sendToWeb',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            ...?options?.headers,
          },
        ),
        cancelToken: cancelToken,
        queryParameters: queryParameters,
      );

      return response;
    } catch (e) {
      // 🟢 Return success manually if Dio fails
      return Response(
        requestOptions: RequestOptions(
          path: uri.toString(),
        ),
        statusCode: 200,
        statusMessage: 'Success (Handled Fallback)',
        data: {
          "success": true,
          "message": "Notification fallback response",
        },
      );
    }
  }

  Future<Response> patch(
    String uri,
    bool isFormData,
    bool isChangePassword, {
    Options? options,
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final token = await LocalStorageManger.getString('SessionId');
      _dio.options.headers['Content-Type'] = "application/json";
      final host = await LocalStorageManger.getString('host');
      final port = await LocalStorageManger.getString('port');

      final response = await _dio.patch(
        isChangePassword
            ? '${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/auth$uri'
            : '${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/sapIntegration${isFormData ? '/Attachments2' : ""}',
        data: data,
        options: Options(
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
          headers: isChangePassword
              ? {
                  'Content-Type': 'application/json',
                  "Authorization": 'Bearer $token',
                  ...?options?.headers,
                }
              : {
                  'Content-Type':
                      isFormData ? 'multipart/form-data' : 'application/json',
                  "Authorization": 'Bearer $token',
                  'sapUrl': uri,
                  ...?options?.headers,
                },
        ),
        cancelToken: cancelToken,
        queryParameters: queryParameters,
      );

      return response;
    } on DioException catch (e) {
      log(e.requestOptions.method);
      log(e.requestOptions.uri.toString());
      if (e.requestOptions.data is FormData) {
        log('[FormData] - skipped logging raw content.');
      } else {
        log(jsonEncode(e.requestOptions.data));
      }
      log(jsonEncode(e.requestOptions.data));
      log('dio ${e.response?.statusCode}');
      log(jsonEncode(e.requestOptions.headers));

      if (e.response?.statusCode == null) {
        throw const ConnectionRefuse(message: "Invalid Server Configuration");
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const ConnectionRefuse(message: "Invalid server host name.");
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ConnectionRefuse(
          message:
              "Sorry, our server is currently unavailable. Please contact our support.",
        );
      }
      if (e.response?.statusCode == 401) {
        throw const UnauthorizeFailure(
            message: 'Opps. Invalid Request or Time Out.');
      }

      throw ServerFailure(
        message: _extractErrorMessage(e.response),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String uri,
      {Options? options,
      Object? data,
      Map<String, dynamic>? queryParameters}) async {
    try {
      final token = await LocalStorageManger.getString('SessionId');
      _dio.options.headers['Content-Type'] = "application/json";
      final host = await LocalStorageManger.getString('host');
      final port = await LocalStorageManger.getString('port');

      final response = await _dio.put(
        '${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/sapIntegration',
        data: data,
        options: Options(
          headers: {
            'Content-Type': "application/json",
            "Authorization": 'Bearer $token',
            'sapUrl': uri
          },
        ),
        cancelToken: cancelToken,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      log(e.requestOptions.method);
      log(e.requestOptions.uri.toString());
      log(jsonEncode(e.requestOptions.data));
      log('dio ${e.response?.statusCode}');

      if (e.response?.statusCode == null) {
        throw const ConnectionRefuse(
          message: "Invalid Server Configuration",
        );
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const ConnectionRefuse(
          message: "Invalid server host name.",
        );
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ConnectionRefuse(
          message:
              "Sorry, our server is currently unavailable. Please contact our support.",
        );
      }
      if (e.response?.statusCode == 401) {
        throw const UnauthorizeFailure(
            message: 'Opps. Invalid Request or Time Out.');
      }

      throw ServerFailure(
        message: _extractErrorMessage(e.response),
      );
    } catch (e) {
      rethrow;
    }
  }
}
