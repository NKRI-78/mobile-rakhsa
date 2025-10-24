enum ErrorCode {
  connectionTimeout,
  receiveTimeout,
  sendTimeout,
  badResponse,
  cancel,
  connectionError,
  unexpectedClientError,
  noInternetConnection,
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
      ErrorCode.noInternetConnection => 503,
      ErrorCode.unknown => -1,
    };
  }

  String get message {
    return switch (this) {
      ErrorCode.connectionTimeout => 'Koneksi timeout. Silakan coba lagi.',
      ErrorCode.receiveTimeout =>
        'Server terlalu lama merespons. Silakan coba lagi.',
      ErrorCode.sendTimeout => 'Waktu pengiriman data ke server habis.',
      ErrorCode.cancel => 'Permintaan dibatalkan oleh pengguna.',
      ErrorCode.connectionError =>
        'Server tidak dapat dijangkau. Periksa koneksi internet Anda.',
      ErrorCode.unexpectedClientError => 'Terjadi kesalahan server',
      ErrorCode.noInternetConnection => 'Tidak ada koneksi internet',
      ErrorCode.unknown => 'Kesalahan yang tidak diketahui',
      _ => 'Kesalahan yang tidak diketahui', // unknown error
    };
  }
}
