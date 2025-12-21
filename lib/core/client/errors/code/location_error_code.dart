enum LocationError { gpsDisabled, deniedPermission }

extension LocationErrorExtension on LocationError {
  String get errorCode => switch (this) {
    LocationError.gpsDisabled => "GPS_DISABLED",
    LocationError.deniedPermission => "DENIED_PERMISSION",
  };

  String getMessage([String? custom]) => switch (this) {
    LocationError.gpsDisabled =>
      custom ?? "GPS tidak aktif. Aktifkan lokasi untuk melanjutkan.",
    LocationError.deniedPermission =>
      custom ??
          "Akses lokasi belum diizinkan. Izinkan terlebih dahulu untuk melanjutkan.",
  };
}
