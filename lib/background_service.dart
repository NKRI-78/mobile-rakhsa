import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rakhsa/misc/helpers/storage.dart';

final service = FlutterBackgroundService();

Future<void> initBackgroundService(String title, String content) async {
  if (await service.isRunning()) return;
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
      initialNotificationTitle: title,
      initialNotificationContent: content,
      notificationChannelId: "notification",
    ),
  );
}

void startBackgroundService() {
  service.startService();
}

void stopBackgroundService() {
  service.invoke("stop");
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  debugPrint("=== ON START ===");

  final deviceInfo = DeviceInfoPlugin();

  await StorageHelper.init(fromBgService: true);
  await StorageHelper.loadlocalSession();
  debugPrint("SCHEDULER RUNNING: StorageHelper.init = done");

  Timer.periodic(const Duration(hours: 1), (_) async {
    debugPrint("=== SCHEDULER RUNNING ===");

    var address = "-";
    var coord = <String, double>{"lat": 0.0, "lng": 0.0};

    final uid = StorageHelper.session?.user.id ?? "-";
    debugPrint("SCHEDULER RUNNING: uid = $uid");

    final hasPermission = await Geolocator.checkPermission().then((p) {
      return p == LocationPermission.always ||
          p == LocationPermission.whileInUse;
    });
    debugPrint("SCHEDULER RUNNING: hasPermission? $hasPermission");
    if (hasPermission) {
      debugPrint("SCHEDULER RUNNING: sedang mendapatkan lokasi...");
      final position = await Geolocator.getCurrentPosition(
        locationSettings: Platform.isIOS
            ? AppleSettings(accuracy: LocationAccuracy.best)
            : AndroidSettings(accuracy: LocationAccuracy.best),
      );
      coord = {"lat": position.latitude, "lng": position.longitude};
      debugPrint("SCHEDULER RUNNING: current location = $coord");

      address =
          await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          ).then((pcl) {
            if (pcl.isEmpty) return "-";
            return [
              pcl[0].administrativeArea,
              pcl[0].subAdministrativeArea,
              pcl[0].street,
              pcl[0].country,
            ].where((p) => p != null && p.isNotEmpty).join(", ");
          });
      debugPrint("SCHEDULER RUNNING: address = $address");
    }

    Map<String, dynamic> sendData = {};
    if (Platform.isIOS) {
      final iOSInfo = await deviceInfo.iosInfo;
      sendData = {
        "user_id": uid,
        "address": address,
        "device": iOSInfo.model,
        "product_name": iOSInfo.modelName,
        "no_serial": iOSInfo.systemName,
        "os_name": "iOS",
        "lat": coord['lat'],
        "lng": coord['lng'],
      };
    } else {
      final androidInfo = await deviceInfo.androidInfo;
      sendData = {
        "user_id": uid,
        "address": address,
        "device": androidInfo.model,
        "product_name": androidInfo.product,
        "no_serial": androidInfo.product,
        "os_name": "Android",
        "lat": coord['lat'],
        "lng": coord['lng'],
      };
    }

    try {
      // base url masih menggunakan api production
      await Dio().post(
        "https://api-rakhsa.inovatiftujuh8.com/api/v1/profile/insert-user-track",
        data: sendData,
      );
      debugPrint("SCHEDULER RUNNING: send data berhasil= $sendData");
    } on DioException catch (e) {
      debugPrint(
        "SCHEDULER RUNNING: Error posting data DioException: ${e.response?.data ?? "-"}",
      );
      throw Exception(e.response?.data['message'] ?? '-');
    } catch (e) {
      debugPrint("SCHEDULER RUNNING: Error posting data: $e");
      throw Exception(e.toString());
    }
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}
