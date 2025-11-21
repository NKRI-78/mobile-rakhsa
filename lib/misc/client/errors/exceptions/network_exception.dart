import 'package:rakhsa/misc/client/errors/errors.dart';

class NetworkException implements Exception {
  final NetworkError? errorType;
  final int? statusCode;
  final String? errorCode;
  final String? message;
  final dynamic body;
  final Object? original;

  NetworkException({
    this.errorType,
    this.statusCode,
    this.errorCode,
    this.message,
    this.body,
    this.original,
  });

  factory NetworkException.unknown([
    Object? orig,
    int statusCode = 0,
  ]) => NetworkException(
    errorType: NetworkError.unknown,
    message:
        'Maaf, terjadi kendala yang belum dapat kami identifikasi. Silakan coba kembali beberapa saat lagi.',
    original: orig,
    statusCode: statusCode,
    errorCode: NetworkError.unknown.errorCode,
  );

  factory NetworkException.noInternetConnection() => NetworkException(
    errorType: NetworkError.noInternetConnection,
    errorCode: NetworkError.noInternetConnection.errorCode,
    message: 'Tidak ada koneksi internet. Mohon periksa jaringan Anda.',
    statusCode: 608,
  );
}
