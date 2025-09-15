import 'dart:convert';
import 'dart:developer';

import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
import 'package:dio/dio.dart';
import '../core/error/failure.dart';

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
        'https://${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/sapIntegration',
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
        message: e.response?.data['error']['message']['value'] ??
            "An unexpected error occurred.",
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
        'https://${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/sapIntegration/Attachments2',
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
        message: e.response?.data['error']['message']['value'] ??
            "An unexpected error occurred.",
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
            ? 'https://${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/auth$uri'
            : 'https://${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/sapIntegration${isFormData ? '/Attachments2' : ""}',
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
        message: e.response?.data['error']['message']['value'] ??
            "An unexpected error occurred.",
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
        'https://${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/notifications/sendToWeb',
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
            ? 'https://${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/auth$uri'
            : 'https://${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/sapIntegration${isFormData ? '/Attachments2' : ""}',
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
        message: e.response?.data['error']['message']['value'] ??
            "An unexpected error occurred.",
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
        'https://${host == '' ? 'svr10.biz-dimension.com' : host}:${port == '' ? '9093' : port}/api/sapIntegration',
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
        message: e.response?.data['error']['message']['value'] ??
            "An unexpected error occurred.",
      );
    } catch (e) {
      rethrow;
    }
  }
}
