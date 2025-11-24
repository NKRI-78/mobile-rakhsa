import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/service/app/app_metadata.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';

class EnableLocationAlwaysDialog extends StatefulWidget {
  const EnableLocationAlwaysDialog._();

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

  // fungsi ini buat negcek apakah sudah saatnya munculin dialog lagi
  // setelah user menekan "ingatkan nanti" durasi bisa diatur melalui parameter _checkOrLaunch
  static bool _shouldShowAfterOnLater(Duration laterDuration) {
    final raw = StorageHelper.read("later_location_always_cache_key");
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

  @override
  State<EnableLocationAlwaysDialog> createState() =>
      _EnableLocationAlwaysDialogState();
}

class _EnableLocationAlwaysDialogState
    extends State<EnableLocationAlwaysDialog> {
  final _demoIndexController = ValueNotifier<int>(0);

  final _demoItems = [
    "assets/images/permission-location-always-1.webp",
    "assets/images/permission-location-always-2.webp",
    "assets/images/permission-location-always-3.webp",
  ];

  @override
  void dispose() {
    _demoIndexController.dispose();
    super.dispose();
  }

  static Future<void> _onUserSavedLater() async {
    try {
      await StorageHelper.write(
        "later_location_always_cache_key",
        DateTime.now().toIso8601String(),
      );
    } catch (_) {}
  }

  Future<void> _activateBgLocation() async {
    final bgLocation = Permission.locationAlways;
    final status = await bgLocation.status;
    if (status == PermissionStatus.granted) return;

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
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Tingkatkan Keandalan Fitur Keselamatan",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackColor,
                fontSize: fontSizeOverLarge,
                fontWeight: FontWeight.bold,
              ),
            ),

            10.spaceY,

            Stack(
              children: [
                CarouselSlider(
                  items: _demoItems.map((img) {
                    return Image.asset(img);
                  }).toList(),
                  options: CarouselOptions(
                    height: 170,
                    viewportFraction: 1,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    onPageChanged: (index, reason) =>
                        _demoIndexController.value = index,
                  ),
                ),

                Positioned(
                  right: 16,
                  left: 16,
                  bottom: 2,
                  child: ValueListenableBuilder(
                    valueListenable: _demoIndexController,
                    builder: (context, currentIndex, child) {
                      return Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _demoItems.asMap().entries.map((entry) {
                          final active = currentIndex == entry.key;
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            width: active ? 35 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? primaryColor
                                  : primaryColor.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),

            18.spaceY,

            Text(
              "Mengizinkan akses lokasi Selalu, aplikasi dapat lebih responsif saat Anda membutuhkan fitur SOS. Izin ini sepenuhnya opsional, namun akan sangat membantu agar sistem dapat bekerja lebih optimal.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 12),
            ),

            16.spaceY,

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10),
                ),
              ),
              child: Text("Aktifkan"),
              onPressed: () async {
                context.pop(true);
                await _activateBgLocation();
              },
            ),

            2.spaceY,

            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10),
                ),
              ),
              child: Text("Ingatkan nanti"),
              onPressed: () async {
                await _onUserSavedLater();
                if (context.mounted) context.pop(false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
