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
    .unknown => "UNKNOWN",
    .noInternetConnection => "NO_INTERNET_CONNECTION",
    .parsingError => "PARSING_ERROR",
    _ => null,
  };
}
