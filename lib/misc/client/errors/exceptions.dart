import 'package:rakhsa/misc/client/errors/code.dart';

class ClientException implements Exception {
  ClientException({this.code = 0, required this.message, this.errorCode});

  final int code;
  final String message;
  final String? errorCode;

  factory ClientException.unknown({String? other}) => ClientException(
    code: ErrorCode.unknown.code,
    message: "Terjadi kesalahan yang tak terduga [${other ?? "-"}]",
  );

  factory ClientException.missing(String message) =>
      ClientException(code: -2, message: message);
}

class ConnectivityException implements Exception {
  ConnectivityException({this.message = "Tidak ada koneksi internet."});

  final String message;
  final int code = ErrorCode.noInternetConnection.code;
  final String errorCode = ErrorCode.noInternetConnection.errorCode;
}

class DataParsingException implements Exception {
  DataParsingException(this.message, [this.cause, this.st]);

  final String message;
  final Object? cause;
  final StackTrace? st;

  final int code = ErrorCode.errorDataParsing.code;
  final String errorCode = ErrorCode.errorDataParsing.errorCode;

  @override
  String toString() => 'DataParsingException: $message';
}

class LocationException implements Exception {
  final String errCode;
  final String message;

  LocationException({required this.errCode, required this.message});
}
