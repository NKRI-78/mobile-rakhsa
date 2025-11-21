import 'package:rakhsa/misc/client/errors/errors.dart';

class DataParsingException implements Exception {
  DataParsingException({
    this.error,
    this.message =
        "Terjadi kesalahan saat memuat data. Silakan coba lagi dalam beberapa saat.",
  });

  final String message;
  final Object? error;

  final String? errorCode = NetworkError.parsingError.errorCode;

  @override
  String toString() => 'DataParsingException: ${error?.toString() ?? "-"}';
}
