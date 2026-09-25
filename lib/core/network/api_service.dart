import 'package:dio/dio.dart';

import 'app_exception.dart';
import 'dio_client.dart';

class ApiService {
  ApiService({
    DioClient? dioClient,
  }) : _dio = (dioClient ?? DioClient()).instance;

  final Dio _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
      );
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

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
      );
    } on DioException catch (error) {
      throw _extractAppException(error);
    }
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
      );
    } on DioException catch (error) {
      throw _extractAppException(error);
    }
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
      );
    } on DioException catch (error) {
      throw _extractAppException(error);
    }
  }

  AppException _extractAppException(DioException error) {
    if (error.error is AppException) {
      return error.error as AppException;
    }

    return AppException(
      message: error.message ?? 'Something went wrong.',
      statusCode: error.response?.statusCode,
    );
  }
}