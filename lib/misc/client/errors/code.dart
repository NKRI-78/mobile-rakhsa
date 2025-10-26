enum ErrorCode {
  connectionTimeout,
  receiveTimeout,
  sendTimeout,
  badResponse,
  cancel,
  connectionError,
  unexpectedClientError,
  noInternetConnection,
  errorDataParsing,
  unknown,
}

extension ErrorCodeExtension on ErrorCode {
  int get code {
    return switch (this) {
      ErrorCode.connectionTimeout => 408,
      ErrorCode.receiveTimeout => 408,
      ErrorCode.sendTimeout => 408,
      ErrorCode.badResponse => 400,
      ErrorCode.cancel => 499,
      ErrorCode.connectionError => 504,
      ErrorCode.unexpectedClientError => 500,
      ErrorCode.noInternetConnection => -1,
      ErrorCode.errorDataParsing => -2,
      ErrorCode.unknown => -3,
    };
  }

  String message([String? cause]) {
    return switch (this) {
      ErrorCode.connectionTimeout =>
        'Koneksi timeout. Silakan coba lagi. $cause',
      ErrorCode.receiveTimeout =>
        'Server terlalu lama merespons. Silakan coba lagi. $cause',
      ErrorCode.sendTimeout => 'Waktu pengiriman data ke server habis. $cause',
      ErrorCode.cancel => 'Permintaan dibatalkan oleh pengguna. $cause',
      ErrorCode.connectionError =>
        'Server tidak dapat dijangkau. Periksa koneksi internet Anda. $cause',
      ErrorCode.unexpectedClientError => 'Terjadi kesalahan server. $cause',
      ErrorCode.noInternetConnection => 'Tidak ada koneksi internet. $cause',
      ErrorCode.errorDataParsing =>
        'Kesalahan saat mencoba parsing data. $cause',
      ErrorCode.unknown => 'Kesalahan yang tidak diketahui. $cause',
      _ => 'Kesalahan yang tidak diketahui. $cause', // unknown error
    };
  }

  String get errorCode {
    return switch (this) {
      ErrorCode.noInternetConnection => 'no_internet_connection',
      ErrorCode.errorDataParsing => 'error_data_parsing',
      _ => '_', // unknown error
    };
  }
}
