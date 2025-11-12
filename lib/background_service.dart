import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rakhsa/misc/helpers/storage.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final interval = Duration(hours: 1);
  debugPrint("FG SERVICE STARTED: interval ${interval.inMinutes} menit");
  Timer.periodic(interval, (timer) async {
    final success = await fetchLocationFromBgService();
    if (!success) {
      timer.cancel();
      stopBackgroundService();
    }
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

Future<bool> initBackgroundService(String title, String content) {
  return FlutterBackgroundService().configure(
    iosConfiguration: IosConfiguration(
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
      // id channel jangan diganti beb, bisa bikin bug
      // id channel sudah sesuai dengan channelName: 'notification', init notification di main()
      notificationChannelId: "notification",
    ),
  );
}

Future<bool> get bgServiceIsRunning => FlutterBackgroundService().isRunning();

Future<bool> startBackgroundService() {
  return FlutterBackgroundService().startService();
}

void stopBackgroundService() => FlutterBackgroundService().invoke("stop");

Future<bool> fetchLocationFromBgService() async {
  Dio? client;
  Connectivity? conn;
  DeviceInfoPlugin? deviceInfo;

  await StorageHelper.init();

  // base url diambil dari shared prefs yang udah di simpan dari halaman splash screen
  // fallback kalau baseUrl null || isEmpty ambil dari api production
  final url = StorageHelper.read("base_url_cache");
  final baseUrl = (url == null || url.isEmpty)
      ? "https://api-rakhsa.inovatiftujuh8.com/api/v1"
      : url;
  debugPrint("SCHEDULER RUNNING ON START: baseUrl = $baseUrl");

  // location
  var location = <String, dynamic>{"lat": 0.0, "lng": 0.0, "address": "-"};

  // get uid
  final uid = await StorageHelper.loadlocalSession().then((v) => v?.user.id);
  debugPrint("SCHEDULER RUNNING ON START: uid = $uid");
  if (uid == null) return false;

  // get current location
  final hasPermission = await Geolocator.checkPermission().then((p) {
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  });
  debugPrint("SCHEDULER RUNNING: hasPermission? $hasPermission");
  if (hasPermission) {
    Position? position;
    debugPrint("SCHEDULER RUNNING: sedang mendapatkan lokasi...");
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: Platform.isIOS
            ? AppleSettings(accuracy: LocationAccuracy.best)
            : AndroidSettings(accuracy: LocationAccuracy.best),
      );
      location = {"lat": position.latitude, "lng": position.longitude};
      debugPrint("SCHEDULER RUNNING: current location = $location");
    } catch (e) {
      position = null;
    }

    // fetch address
    if (position != null) {
      final addr =
          await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          ).then((pcl) {
            if (pcl.isEmpty) return "-";
            var parts = <String?>[
              pcl[0].administrativeArea,
              pcl[0].subAdministrativeArea,
              pcl[0].street,
              pcl[0].country,
            ];
            return parts.where((p) => p != null && p.isNotEmpty).join(", ");
          });
      location = {...location, "address": addr};
      debugPrint("SCHEDULER RUNNING: address = $location");
    }
  }

  // send data
  deviceInfo = DeviceInfoPlugin();
  var sendData = <String, dynamic>{};
  if (Platform.isIOS) {
    final iOSInfo = await deviceInfo.iosInfo;
    sendData = {
      "user_id": uid,
      "address": location['address'],
      "device": iOSInfo.model,
      "product_name": iOSInfo.modelName,
      "no_serial": iOSInfo.systemName,
      "os_name": "iOS",
      "lat": location['lat'],
      "lng": location['lng'],
    };
  } else if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    sendData = {
      "user_id": uid,
      "address": location['address'],
      "device": androidInfo.model,
      "product_name": androidInfo.product,
      "no_serial": androidInfo.product,
      "os_name": "Android",
      "lat": location['lat'],
      "lng": location['lng'],
    };
  }

  // hit api
  try {
    client = Dio();
    conn = Connectivity();
    final hasConn = await conn.checkConnectivity().then((c) {
      return c.contains(ConnectivityResult.mobile) ||
          c.contains(ConnectivityResult.wifi) ||
          c.contains(ConnectivityResult.vpn);
    });
    debugPrint("SCHEDULER RUNNING: mencoba mengirim data.. hasConn? $hasConn");
    if (!hasConn) return false;
    await client.post("$baseUrl/profile/insert-user-track", data: sendData);
    debugPrint("SCHEDULER RUNNING: send data berhasil= $sendData");
    return true;
  } on DioException catch (e) {
    debugPrint(
      "SCHEDULER RUNNING: Error posting data DioException: ${e.response?.data ?? "-"}",
    );
    client = null;
    conn = null;
    return false;
  } catch (e) {
    debugPrint("SCHEDULER RUNNING: Error posting data: $e");
    client = null;
    conn = null;
    return false;
  }
}
