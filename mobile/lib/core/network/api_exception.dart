import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
  });

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    final detail = data is Map<String, dynamic> ? data['detail'] : null;

    return ApiException(
      message: detail is String ? detail : error.message ?? 'Unexpected API error.',
      statusCode: error.response?.statusCode,
    );
  }

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
