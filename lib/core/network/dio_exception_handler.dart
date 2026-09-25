import 'package:dio/dio.dart';

import 'app_exception.dart';

class DioExceptionHandler {
  DioExceptionHandler._();

  static AppException handle(DioException exception) {
    final response = exception.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String && message.isNotEmpty) {
        return AppException(
          message: message,
          statusCode: statusCode,
        );
      }
    }

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return AppException(
          message: 'Request timed out. Please try again.',
          statusCode: statusCode,
        );

      case DioExceptionType.connectionError:
        return AppException(
          message: 'Unable to connect to the server.',
          statusCode: statusCode,
        );

      case DioExceptionType.badCertificate:
        return AppException(
          message: 'Secure connection failed.',
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return AppException(
          message: 'Request was cancelled.',
          statusCode: statusCode,
        );

      case DioExceptionType.badResponse:
        return AppException(
          message: 'Something went wrong. Please try again.',
          statusCode: statusCode,
        );

      case DioExceptionType.unknown:
        return AppException(
          message: 'Something went wrong. Please try again.',
          statusCode: statusCode,
        );
    }
  }
}