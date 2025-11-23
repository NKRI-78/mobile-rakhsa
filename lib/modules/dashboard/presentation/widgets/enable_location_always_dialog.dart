import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/service/app/app_metadata.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';

class EnableLocationAlwaysDialog extends StatelessWidget {
  const EnableLocationAlwaysDialog._();

  static String get _cacheKey => "later_location_always_cache_key";

  static Future<bool> checkOrLaunch(
    BuildContext context, {
    Duration afterInstallDuration = const Duration(minutes: 15),
    Duration laterDuration = const Duration(days: 1),
  }) async {
    if (!_shouldShowAfterInstall(afterInstallDuration)) return false;

    final status = await Permission.locationAlways.status.catchError(
      (_) => PermissionStatus.denied,
    );
    final hasPermission = status == PermissionStatus.granted;
    if (hasPermission) return true;

    if (!context.mounted) return false;

    if (!_shouldShowAfterOnLater(laterDuration)) return false;

    final permissionResult = await AppDialog.show<bool?>(
      c: context,
      canPop: false,
      customDialogBuilder: (_) => EnableLocationAlwaysDialog._(),
    );

    return permissionResult ?? false;
  }

  static Future<void> _onUserSavedLater() async {
    try {
      await StorageHelper.write(_cacheKey, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  // fungsi ini buat negcek apakah sudah saatnya munculin dialog lagi
  // setelah user menekan "ingatkan nanti" durasi bisa diatur melalui parameter _checkOrLaunch
  static bool _shouldShowAfterOnLater(Duration laterDuration) {
    final raw = StorageHelper.read(_cacheKey);
    if (raw == null) return true;
    final savedTime = DateTime.parse(raw);
    final onLaterDiff = DateTime.now().difference(savedTime);
    return onLaterDiff >= laterDuration;
  }

  // dibaca beb 😘😘 ini bukan tulisan AI yaw
  // fungsi ini intinya itu ngecek dialog location always itu mau ditampilkan
  // dengan durasi berapa lama setelah aplikasi diinstall pertama kali biar
  // ga tabrakan sama showing dialog lainya ketika user baru pertama kali install applikasi
  // durasi bisa diatur melalui parameter _checkOrLaunch
  static bool _shouldShowAfterInstall(Duration afterInstallDuration) {
    final appAge = AppMetadata().getAppAge();
    if (appAge == null) return true;
    return appAge >= afterInstallDuration;
  }

  Future<void> _activateBgLocation() async {
    final bgLocation = Permission.locationAlways;
    final status = await bgLocation.status;

    // permanentlyDenied itu biasanya kalau di:
    // Android: dikasi kesempatan 2 kali activate bg location, lewat dari itu berarti status == permanentlyDenied
    // iOS: langsung status == permanentlyDenied
    // kalau permanentlyDenied openAppSettings aja
    if (status == PermissionStatus.permanentlyDenied) {
      await Geolocator.openAppSettings();
    } else {
      await bgLocation.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogCard(
      DialogContent(
        assetIcon: "assets/images/icons/location.png",
        title: "Tingkatkan Keandalan Fitur Keselamatan",
        message: """
Dengan mengizinkan akses lokasi Selalu, aplikasi dapat lebih responsif saat Anda membutuhkan fitur SOS. Izin ini sepenuhnya opsional—namun akan sangat membantu agar sistem dapat bekerja lebih optimal.
""",
        style: DialogStyle(assetIconSize: 170),
        buildActions: (dc) {
          return [
            DialogActionButton(
              label: "Ingatkan nanti",
              onTap: () async {
                await _onUserSavedLater();
                if (dc.mounted) dc.pop(false);
              },
            ),
            DialogActionButton(
              label: "Aktifkan",
              primary: true,
              onTap: () async {
                dc.pop(true);
                await _activateBgLocation();
              },
            ),
          ];
        },
      ),
    );
  }
}
