import 'package:dio/dio.dart';

class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => 'AppException(code: $code, message: $message)';

  static AppException fromDio(DioException error) {
    final response = error.response;
    final message = switch (error.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out',
      DioExceptionType.receiveTimeout => 'Server took too long to respond',
      DioExceptionType.badResponse => response?.data['message']?.toString() ??
          'Server responded with an error',
      DioExceptionType.cancel => 'Request cancelled',
      DioExceptionType.connectionError => 'Network error occurred',
      DioExceptionType.badCertificate => 'Bad TLS certificate',
      DioExceptionType.sendTimeout => 'Request timed out',
      DioExceptionType.unknown => 'Unexpected error occurred',
    };
    return AppException(message, code: response?.statusCode);
  }
}
