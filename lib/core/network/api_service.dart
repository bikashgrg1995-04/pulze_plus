import 'package:dio/dio.dart';

import 'app_exception.dart';
import 'dio_client.dart';

class ApiService {
  ApiService({required DioClient dioClient}) : _dio = dioClient.instance;

  final Dio _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (error) {
      throw _extractAppException(error);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      throw _extractAppException(error);
    }
  }

  Future<Response<dynamic>> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (error) {
      throw _extractAppException(error);
    }
  }

  Future<Response<dynamic>> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (error) {
      throw _extractAppException(error);
    }
  }

  Future<Response<dynamic>> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (error) {
      throw _extractAppException(error);
    }
  }

  AppException _extractAppException(DioException error) {
    if (error.error is AppException) {
      return error.error as AppException;
    }

    final responseData = error.response?.data;

    if (responseData is Map) {
      final detail = responseData['detail'];

      if (detail is String && detail.isNotEmpty) {
        return AppException(
          message: detail,
          statusCode: error.response?.statusCode,
        );
      }

      final message = responseData['message'];

      if (message is String && message.isNotEmpty) {
        return AppException(
          message: message,
          statusCode: error.response?.statusCode,
        );
      }

      final currentPassword = responseData['current_password'];

      if (currentPassword is List && currentPassword.isNotEmpty) {
        return AppException(
          message: currentPassword.first.toString(),
          statusCode: error.response?.statusCode,
        );
      }

      if (currentPassword is String && currentPassword.isNotEmpty) {
        return AppException(
          message: currentPassword,
          statusCode: error.response?.statusCode,
        );
      }
    }

    return AppException(
      message: error.message ?? 'Something went wrong.',
      statusCode: error.response?.statusCode,
    );
  }
}
