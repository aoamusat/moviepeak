import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._storage)
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 20),
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  final Dio _dio;
  final SecureStorageService _storage;

  static const _refreshAttemptedKey = 'refreshAttempted';
  static const _skipAuthKey = 'skipAuth';

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skipAuth = options.extra[_skipAuthKey] == true;
    if (!skipAuth) {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final requestOptions = err.requestOptions;
    final alreadyAttempted = requestOptions.extra[_refreshAttemptedKey] == true;
    final isAuthRoute = requestOptions.path.contains('/auth/login') ||
        requestOptions.path.contains('/auth/signup') ||
        requestOptions.path.contains('/auth/refresh');

    if (statusCode == 401 && !alreadyAttempted && !isAuthRoute) {
      final didRefresh = await _attemptTokenRefresh();
      if (didRefresh) {
        try {
          final retryHeaders =
              Map<String, dynamic>.from(requestOptions.headers);
          final newToken = await _storage.readAccessToken();
          if (newToken != null) {
            retryHeaders['Authorization'] = 'Bearer $newToken';
          }

          final response = await _dio.fetch<dynamic>(
            requestOptions.copyWith(
              headers: retryHeaders,
              extra: {
                ...requestOptions.extra,
                _refreshAttemptedKey: true,
              },
            ),
          );
          handler.resolve(response);
          return;
        } on DioException catch (_) {
          await _storage.clearTokens();
        }
      } else {
        await _storage.clearTokens();
      }
    }

    handler.next(err);
  }

  Future<bool> _attemptTokenRefresh() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
      ),
    );

    try {
      final response = await refreshDio.post<dynamic>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final payload = _unwrapData(response.data);
      if (payload is! Map<String, dynamic>) {
        return false;
      }

      final access = payload['accessToken']?.toString();
      final refresh = payload['refreshToken']?.toString();
      if (access == null || refresh == null) {
        return false;
      }

      await _storage.saveTokens(accessToken: access, refreshToken: refresh);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: Options(extra: {_skipAuthKey: skipAuth}),
      );
      return _unwrapData(response.data);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(extra: {_skipAuthKey: skipAuth}),
      );
      return _unwrapData(response.data);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic data,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        options: Options(extra: {_skipAuthKey: skipAuth}),
      );
      return _unwrapData(response.data);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  ApiException _mapException(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;

    String message = 'Request failed. Please try again.';
    if (data is Map<String, dynamic>) {
      final errorMessage = data['message'];
      if (errorMessage is List && errorMessage.isNotEmpty) {
        message = errorMessage.first.toString();
      } else if (errorMessage != null) {
        message = errorMessage.toString();
      } else if (data['error'] != null) {
        message = data['error'].toString();
      }
    } else if (error.message != null) {
      message = error.message!;
    }

    return ApiException(message: message, statusCode: status);
  }

  dynamic _unwrapData(dynamic raw) {
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'];
    }
    return raw;
  }
}
