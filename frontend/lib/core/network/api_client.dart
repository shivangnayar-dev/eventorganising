import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  ApiClient._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _handleError,
    ));
  }

  static final ApiClient instance = ApiClient._internal();
  final Dio _dio;
  // Use shared storage instance for consistency across the app
  final _secureStorage = SecureStorage.instance;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _secureStorage.read(AppConstants.tokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Ignore storage errors
    }
    handler.next(options);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      String? token;
      try {
        token = await _secureStorage.read(AppConstants.tokenKey);
      } catch (e) {
        // Silently handle storage read errors - token might not exist yet
        token = null;
      }
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: _authHeader(token)),
      );
      return response;
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
  }) async {
    try {
      String? token;
      try {
        token = await _secureStorage.read(AppConstants.tokenKey);
      } catch (e) {
        // Silently handle storage read errors - token might not exist yet
        token = null;
      }
      final response = await _dio.post<T>(
        path,
        data: data,
        options: Options(headers: _authHeader(token)),
      );
      return response;
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
  }) async {
    try {
      final token = await _secureStorage.read(AppConstants.tokenKey);
      final response = await _dio.put<T>(
        path,
        data: data,
        options: Options(headers: _authHeader(token)),
      );
      return response;
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
  }) async {
    try {
      final token = await _secureStorage.read(AppConstants.tokenKey);
      final response = await _dio.delete<T>(
        path,
        data: data,
        options: Options(headers: _authHeader(token)),
      );
      return response;
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await _secureStorage.write(AppConstants.tokenKey, accessToken);
      await _secureStorage.write(AppConstants.refreshTokenKey, refreshToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveAccessToken(String token) async {
    try {
      await _secureStorage.write(AppConstants.tokenKey, token);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(AppConstants.tokenKey);
    await _secureStorage.delete(AppConstants.refreshTokenKey);
  }

  Future<void> _handleError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized - try to refresh token
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // Don't retry refresh endpoint
      if (requestOptions.path == '/auth/refresh') {
        await clearTokens();
        handler.next(err);
        return;
      }

      // If already refreshing, queue this request
      if (_isRefreshing) {
        return _queueRequest(requestOptions, handler);
      }

      _isRefreshing = true;

      try {
        final refreshToken = await _secureStorage.read(AppConstants.refreshTokenKey);
        if (refreshToken == null || refreshToken.isEmpty) {
          await clearTokens();
          handler.next(err);
          return;
        }

        // Try to refresh the token
        final refreshResponse = await _dio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        final newAccessToken = refreshResponse.data?['accessToken'] as String?;
        if (newAccessToken == null || newAccessToken.isEmpty) {
          await clearTokens();
          handler.next(err);
          return;
        }

        // Save new access token
        await saveAccessToken(newAccessToken);

        // Update the original request with new token
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        // Retry the original request
        final response = await _dio.fetch(requestOptions);
        handler.resolve(response);

        // Process queued requests
        _processPendingRequests(newAccessToken);
      } catch (refreshError) {
        // Refresh failed - clear tokens and reject all requests
        await clearTokens();
        _rejectPendingRequests(refreshError);
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  void _queueRequest(RequestOptions options, ErrorInterceptorHandler handler) {
    _pendingRequests.add(_PendingRequest(options, handler));
  }

  Future<void> _processPendingRequests(String newAccessToken) async {
    for (final pending in _pendingRequests) {
      try {
        pending.options.headers['Authorization'] = 'Bearer $newAccessToken';
        final response = await _dio.fetch(pending.options);
        pending.handler.resolve(response);
      } catch (e) {
        pending.handler.reject(
          e is DioException ? e : DioException(requestOptions: pending.options, error: e),
        );
      }
    }
    _pendingRequests.clear();
  }

  void _rejectPendingRequests(dynamic error) {
    for (final pending in _pendingRequests) {
      pending.handler.reject(
        error is DioException
            ? error
            : DioException(requestOptions: pending.options, error: error),
      );
    }
    _pendingRequests.clear();
  }

  Map<String, String> _authHeader(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
}

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _PendingRequest(this.options, this.handler);
}
