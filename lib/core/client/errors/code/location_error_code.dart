enum LocationError { gpsDisabled, deniedPermission }

extension LocationErrorExtension on LocationError {
  String get errorCode => switch (this) {
    .gpsDisabled => "GPS_DISABLED",
    .deniedPermission => "DENIED_PERMISSION",
  };

  String getMessage([String? custom]) => switch (this) {
    .gpsDisabled =>
      custom ?? "GPS tidak aktif. Aktifkan lokasi untuk melanjutkan.",
    .deniedPermission =>
      custom ??
          "Akses lokasi belum diizinkan. Izinkan terlebih dahulu untuk melanjutkan.",
  };
}
