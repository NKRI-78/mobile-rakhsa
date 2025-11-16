import 'dart:async';
import 'dart:io' show Platform;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/misc/utils/logger.dart';

class Coord {
  final double lat;
  final double lng;

  Coord({this.lat = 0.0, this.lng = 0.0});
}

class ForegroundLocationData {
  final Coord coord;
  final String address;

  ForegroundLocationData({required this.coord, required this.address});
}

Future<bool> sendLatestLocation(
  String event, {
  ForegroundLocationData? foregroundData,
}) async {
  Dio? client;
  DeviceInfoPlugin? deviceInfo;

  // fallback kalau baseUrl null || isEmpty ambil dari api production
  final apiBaseUrl = BuildConfig.getCacheConfig()?.apiBaseUrl;
  final baseUrl = (apiBaseUrl?.isNotEmpty ?? false)
      ? apiBaseUrl!
      : "https://api-rakhsa.inovatiftujuh8.com/api/v1";
  log("SCHEDULER RUNNING ON START: baseUrl = $baseUrl");

  // set dio client
  client = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      sendTimeout: Duration(seconds: 7),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  client.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
      enabled: true,
    ),
  );

  // get uid
  final uid = await StorageHelper.loadlocalSession().then((v) => v?.user.id);
  log("SCHEDULER RUNNING ON START: uid = $uid");
  if (uid == null) return false;

  // check internet conn
  final hasConn = await Connectivity()
      .checkConnectivity()
      .then((c) {
        return c.contains(ConnectivityResult.mobile) ||
            c.contains(ConnectivityResult.wifi) ||
            c.contains(ConnectivityResult.vpn);
      })
      .onError((e, st) => false);
  log("SCHEDULER RUNNING: hass conn? $hasConn");
  if (!hasConn) return false;

  //* KIRIM LOKASI VIA FOREGROUND
  if (foregroundData != null) {
    log("SCHEDULER RUNNING: send lokasi via foreground");
    // send data
    deviceInfo = DeviceInfoPlugin();
    var sendData = <String, dynamic>{};
    if (Platform.isIOS) {
      final iOSInfo = await deviceInfo.iosInfo;
      sendData = {
        "user_id": uid,

        "event": event,
        "reason": "Berhasil mendapatkan lokasi terkini.",

        "os_name": "iOS",
        "device": iOSInfo.model,
        "product_name": iOSInfo.modelName,
        "no_serial": iOSInfo.systemName,

        "lat": foregroundData.coord.lat,
        "lng": foregroundData.coord.lng,
        "address": foregroundData.address,
      };
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      sendData = {
        "user_id": uid,

        "event": event,
        "reason": "Berhasil mendapatkan lokasi terkini.",

        "os_name": "Android",
        "device": androidInfo.model,
        "product_name": androidInfo.product,
        "no_serial": androidInfo.product,

        "lat": foregroundData.coord.lat,
        "lng": foregroundData.coord.lng,
        "address": foregroundData.address,
      };
    }
    try {
      log("SCHEDULER RUNNING: mencoba mengirim data..");
      await client.post("/profile/insert-user-track", data: sendData);
      log("SCHEDULER RUNNING: send data berhasil= $sendData");
      return true;
    } on DioException catch (e) {
      log(
        "SCHEDULER RUNNING: Error posting data DioException: ${e.response?.data ?? "-"}",
      );
      return false;
    } catch (e) {
      log("SCHEDULER RUNNING: Error posting data: $e");
      return false;
    }
  }

  //* KIRIM LOKASI VIA BACKGROUND
  log("SCHEDULER RUNNING: send lokasi via background");

  // send data
  // struktur sendData seharusnya begini:
  var sendData = <String, dynamic>{
    // user data
    "user_id": uid,

    // event detail
    "event": event,
    "reason": "-",

    // location
    "lat": 0.0,
    "lng": 0.0,
    "address": "-",

    // device
    "os_name": "unknown",
    "device": "unknown",
    "product_name": "unknown",
    "no_serial": "unknown",
  };

  // get current location
  final hasPermission = await Geolocator.checkPermission()
      .then((p) {
        return p == LocationPermission.always ||
            p == LocationPermission.whileInUse;
      })
      .onError((e, st) => false);
  log("SCHEDULER RUNNING: hasPermission? $hasPermission");
  if (hasPermission) {
    Position? position;
    log("SCHEDULER RUNNING: sedang mendapatkan lokasi...");
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: Platform.isIOS
            ? AppleSettings(accuracy: LocationAccuracy.best)
            : AndroidSettings(accuracy: LocationAccuracy.best),
      );
      sendData = {
        ...sendData,
        "lat": position.latitude,
        "lng": position.longitude,
      };
    } catch (e) {
      position = null;
      sendData = {
        ...sendData,
        "reason": "Gagal mendapatkan koordinat lokasi terkini.",
      };
    }
    log(
      "SCHEDULER RUNNING: current location = ${{"lat": sendData['lat'], "lng": sendData['lng']}}",
    );

    // fetch address
    if (position != null) {
      final addr =
          await placemarkFromCoordinates(position.latitude, position.longitude)
              .then((pcl) {
                if (pcl.isEmpty) return "";
                var parts = <String?>[
                  pcl[0].administrativeArea,
                  pcl[0].subAdministrativeArea,
                  pcl[0].street,
                  pcl[0].country,
                ];
                return parts.where((p) => p != null && p.isNotEmpty).join(", ");
              })
              .onError((e, st) => "");

      if (addr.isNotEmpty) {
        sendData = {
          ...sendData,
          "address": addr,
          "reason": "Berhasil mendapatkan lokasi terkini.",
        };
      } else {
        sendData = {
          ...sendData,
          "reason": "Gagal mendapatkan alamat pengguna.",
        };
      }

      log("SCHEDULER RUNNING: address = ${sendData['address'] ?? "-"}");
    }
  } else {
    sendData = {
      ...sendData,
      "reason": "Pengguna tidak memberikan izin lokasi pada perangkatnya.",
    };
  }

  // send data
  deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    final iOSInfo = await deviceInfo.iosInfo;
    sendData = {
      ...sendData,
      "os_name": "iOS",
      "device": iOSInfo.model,
      "product_name": iOSInfo.modelName,
      "no_serial": iOSInfo.systemName,
    };
  } else if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    sendData = {
      ...sendData,
      "os_name": "Android",
      "device": androidInfo.model,
      "product_name": androidInfo.product,
      "no_serial": androidInfo.product,
    };
  }

  // hit api
  try {
    log("SCHEDULER RUNNING: mencoba mengirim data..");
    await client.post("/profile/insert-user-track", data: sendData);
    log("SCHEDULER RUNNING: send data berhasil= $sendData");
    return true;
  } on DioException catch (e) {
    log(
      "SCHEDULER RUNNING: Error posting data DioException: ${e.response?.data ?? "-"}",
    );
    return false;
  } catch (e) {
    log("SCHEDULER RUNNING: Error posting data: $e");
    return false;
  }
}
