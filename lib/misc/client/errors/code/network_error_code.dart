enum NetworkError {
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  badCertificate,
  badResponse,
  cancel,
  connectionError,
  noInternetConnection,
  parsingError,
  unknown,
}

extension NetworkErrorExtension on NetworkError {
  String? get errorCode => switch (this) {
    NetworkError.unknown => "UNKNOWN",
    NetworkError.noInternetConnection => "NO_INTERNET_CONNECTION",
    NetworkError.parsingError => "PARSING_ERROR",
    _ => null,
  };
}
