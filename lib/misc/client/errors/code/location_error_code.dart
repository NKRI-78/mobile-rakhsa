enum LocationErrorCode { gpsDisabled, deniedPermission }

extension LocationErrorCodeExtension on LocationErrorCode {
  String get errorCode => switch (this) {
    LocationErrorCode.gpsDisabled => "GPS_DISABLED",
    LocationErrorCode.deniedPermission => "DENIED_PERMISSION",
  };

  String getMessage([String? custom]) => switch (this) {
    LocationErrorCode.gpsDisabled =>
      custom ?? "GPS tidak aktif. Aktifkan lokasi untuk melanjutkan.",
    LocationErrorCode.deniedPermission =>
      custom ??
          "Akses lokasi belum diizinkan. Izinkan terlebih dahulu untuk melanjutkan.",
  };
}
