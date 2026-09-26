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

    debugPrint('[AUTH] Session expired. Notifying auth state.');

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
      debugPrint('[AUTH] No refresh token available.');

      await _handleSessionExpired();

      return null;
    }

    try {
      debugPrint('[AUTH] Attempting token refresh...');

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

      debugPrint(
        '[AUTH] Token refresh response: '
        '${response.statusCode}',
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        debugPrint('[AUTH] Invalid refresh response.');

        await _handleSessionExpired();

        return null;
      }

      final newAccessToken = data['access'];

      if (newAccessToken is! String || newAccessToken.isEmpty) {
        debugPrint('[AUTH] New access token is missing.');

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

      debugPrint('[AUTH] New access token saved.');

      return newAccessToken;
    } on DioException catch (error) {
      debugPrint(
        '[AUTH] Token refresh failed: '
        '${error.response?.statusCode} '
        '${error.response?.data}',
      );

      await _handleSessionExpired();

      return null;
    } catch (error) {
      debugPrint('[AUTH] Token refresh error: $error');

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
            debugPrint('[AUTH] Refresh endpoint returned 401.');

            await _handleSessionExpired();

            handler.next(error);
            return;
          }

          debugPrint(
            '[AUTH] 401 received: '
            '${requestOptions.path}',
          );

          final refreshToken = await tokenStorage.getRefreshToken();

          debugPrint(
            '[AUTH] Refresh token exists: '
            '${refreshToken != null && refreshToken.isNotEmpty}',
          );

          if (refreshToken == null || refreshToken.isEmpty) {
            debugPrint('[AUTH] No refresh token available.');

            await _handleSessionExpired();

            handler.next(error);
            return;
          }

          final newAccessToken = await _refreshAccessToken();

          if (newAccessToken == null || newAccessToken.isEmpty) {
            debugPrint('[AUTH] Unable to refresh access token.');

            handler.next(error);
            return;
          }

          try {
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            debugPrint(
              '[AUTH] Retrying original request: '
              '${requestOptions.path}',
            );

            final retryResponse = await _dio.fetch(requestOptions);

            handler.resolve(retryResponse);
          } on DioException catch (retryError) {
            debugPrint(
              '[AUTH] Retry failed: '
              '${retryError.response?.statusCode}',
            );

            handler.next(retryError);
          } catch (error) {
            debugPrint('[AUTH] Retry error: $error');

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
