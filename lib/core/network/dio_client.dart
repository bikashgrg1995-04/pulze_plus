import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'api_endpoints.dart';
import 'dio_exception_handler.dart';
import 'token_storage.dart';

class DioClient {
  DioClient({Dio? dio, required this.tokenStorage, this.onSessionExpired})
    : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _setupInterceptors();
  }

  final Dio _dio;
  final TokenStorage tokenStorage;
  final VoidCallback? onSessionExpired;

  Future<String?>? _refreshFuture;

  bool _sessionExpiredHandled = false;

  Dio get instance => _dio;

  // ===========================================================================
  // Session
  // ===========================================================================

  Future<void> _handleSessionExpired() async {
    if (_sessionExpiredHandled) {
      return;
    }

    _sessionExpiredHandled = true;

    await tokenStorage.clearTokens();

    onSessionExpired?.call();
  }

  // ===========================================================================
  // Token refresh
  // ===========================================================================

  Future<String?> _refreshAccessToken() async {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    _refreshFuture = _performTokenRefresh();

    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<String?> _performTokenRefresh() async {
    final refreshToken = await tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await _handleSessionExpired();

      return null;
    }

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        ApiEndpoints.tokenRefresh,
        data: {'refresh': refreshToken},
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        await _handleSessionExpired();

        return null;
      }

      final newAccessToken = data['access'];

      if (newAccessToken is! String || newAccessToken.isEmpty) {
        await _handleSessionExpired();

        return null;
      }

      final newRefreshToken = data['refresh'];

      await tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken is String && newRefreshToken.isNotEmpty
            ? newRefreshToken
            : refreshToken,
      );

      // A successful refresh means the session is valid again.
      _sessionExpiredHandled = false;

      return newAccessToken;
    } on DioException catch (_) {
      await _handleSessionExpired();

      return null;
    } catch (error) {
      await _handleSessionExpired();

      return null;
    }
  }

  // ===========================================================================
  // Interceptors
  // ===========================================================================

  void _setupInterceptors() {
    // 1. Attach access token.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await tokenStorage.getAccessToken();

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          handler.next(options);
        },
      ),
    );

    // 2. Refresh access token on 401 and retry
    //    the original request.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode != 401) {
            handler.next(error);
            return;
          }

          final requestOptions = error.requestOptions;

          // Never try to refresh the refresh endpoint itself.
          if (requestOptions.path == ApiEndpoints.tokenRefresh) {
            await _handleSessionExpired();

            handler.next(error);
            return;
          }

          final refreshToken = await tokenStorage.getRefreshToken();

          if (refreshToken == null || refreshToken.isEmpty) {
            await _handleSessionExpired();

            handler.next(error);
            return;
          }

          final newAccessToken = await _refreshAccessToken();

          if (newAccessToken == null || newAccessToken.isEmpty) {
            handler.next(error);
            return;
          }

          try {
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(requestOptions);

            handler.resolve(retryResponse);
          } on DioException catch (retryError) {
            handler.next(retryError);
          } catch (error) {
            handler.next(
              DioException(requestOptions: requestOptions, error: error),
            );
          }
        },
      ),
    );

    // 3. Central exception handling LAST.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final appException = DioExceptionHandler.handle(error);

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: appException,
              message: appException.message,
            ),
          );
        },
      ),
    );
  }
}
