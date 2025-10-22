import 'package:rakhsa/misc/client/error/code.dart';

class ClientException implements Exception {
  ClientException({this.code = 0, required this.message});

  final int code;
  final String message;

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
}
