// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:rakhsa/core/client/errors/errors.dart';

class NetworkException implements Exception {
  final NetworkError? errorType;
  final int? statusCode;
  final String? errorCode;
  final String? title;
  final String? message;
  final dynamic body;
  final Object? original;

  NetworkException({
    this.errorType,
    this.statusCode,
    this.errorCode,
    this.title,
    this.message,
    this.body,
    this.original,
  });

  factory NetworkException.unknown([
    Object? orig,
    int statusCode = 0,
  ]) => NetworkException(
    errorType: NetworkError.unknown,
    title: "Kesalahan Tak Dikenal",
    message:
        'Maaf, terjadi kendala yang belum dapat kami identifikasi. Silakan coba kembali beberapa saat lagi.',
    original: orig,
    statusCode: statusCode,
    errorCode: NetworkError.unknown.errorCode,
  );

  factory NetworkException.noInternetConnection() => NetworkException(
    title: "Tidak Ada Koneksi Internet",
    errorType: NetworkError.noInternetConnection,
    errorCode: NetworkError.noInternetConnection.errorCode,
    message: 'Tidak ada koneksi internet. Mohon periksa jaringan Anda.',
    statusCode: 608,
  );

  @override
  String toString() {
    return 'NetworkException(errorType: $errorType, statusCode: $statusCode, errorCode: $errorCode, title: $title, message: $message, body: $body, original: $original)';
  }
}
