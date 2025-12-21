import 'package:rakhsa/core/client/errors/errors.dart';

class DataParsingException implements Exception {
  DataParsingException({
    this.error,
    this.title = "Kesalahan Pemrosesan Data",
    this.message =
        "Terjadi kesalahan saat memuat data. Silakan coba lagi dalam beberapa saat.",
  });

  final String title;
  final String message;
  final Object? error;

  final String? errorCode = NetworkError.parsingError.errorCode;

  @override
  String toString() => 'DataParsingException: ${error?.toString() ?? "-"}';
}
