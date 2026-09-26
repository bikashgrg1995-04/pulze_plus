import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'api_endpoints.dart';
import 'dio_exception_handler.dart';
import 'token_storage.dart';

class DioClient {
  DioClient({Dio? dio, TokenStorage? tokenStorage})
    : _dio = dio ?? Dio(),
      _tokenStorage = tokenStorage ?? TokenStorage() {
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
  final TokenStorage _tokenStorage;

  Dio get instance => _dio;

  void _setupInterceptors() {
    // 1. Attach access token first.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _tokenStorage.getAccessToken();

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          handler.next(options);
        },
      ),
    );

    // 2. Refresh access token when the API returns 401.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode != 401) {
            handler.next(error);
            return;
          }

          final requestOptions = error.requestOptions;

          if (requestOptions.path == ApiEndpoints.tokenRefresh) {
            await _tokenStorage.clearTokens();
            handler.next(error);
            return;
          }

          final refreshToken = await _tokenStorage.getRefreshToken();

          if (refreshToken == null || refreshToken.isEmpty) {
            await _tokenStorage.clearTokens();
            handler.next(error);
            return;
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
              await _tokenStorage.clearTokens();
              handler.next(error);
              return;
            }

            final newAccessToken = data['access'];

            if (newAccessToken is! String || newAccessToken.isEmpty) {
              await _tokenStorage.clearTokens();
              handler.next(error);
              return;
            }

            final newRefreshToken = data['refresh'];

            await _tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken:
                  newRefreshToken is String && newRefreshToken.isNotEmpty
                  ? newRefreshToken
                  : refreshToken,
            );

            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(requestOptions);

            handler.resolve(retryResponse);
          } on DioException catch (e) {
            await _tokenStorage.clearTokens();
            handler.next(error);
          } catch (e) {
            await _tokenStorage.clearTokens();
            handler.next(error);
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
