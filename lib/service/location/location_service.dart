import 'dart:async';
import 'dart:io' show Platform;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/core/debug/logger.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';

Future<bool> sendLatestLocation(
  String event, {
  LocationData? otherSource,
}) async {
  Dio? client;
  DeviceInfoPlugin? deviceInfo;

  // fallback kalau baseUrl null || isEmpty ambil dari api production
  final apiBaseUrl = BuildConfig.getCacheConfig()?.apiBaseUrl;
  final baseUrl = (apiBaseUrl?.isNotEmpty ?? false)
      ? apiBaseUrl!
      : "https://api-rakhsa.inovatiftujuh8.com/api/v1";
  log("base url = $baseUrl", label: "SEND_LATEST_LOCATION");

  // set dio client
  final token = await StorageHelper.loadlocalSession().then((session) {
    return session?.token;
  });
  client = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      sendTimeout: Duration(seconds: 7),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
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
  log("user id = $uid", label: "SEND_LATEST_LOCATION");
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
  log("has koneksi? $hasConn", label: "SEND_LATEST_LOCATION");
  if (!hasConn) return false;

  //* KIRIM LOKASI VIA FOREGROUND
  if (otherSource != null) {
    log("send lokasi via foreground", label: "SEND_LATEST_LOCATION");
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

        "lat": otherSource.coord.lat,
        "lng": otherSource.coord.lng,
        "address": otherSource.placemark?.getAddress(),
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

        "lat": otherSource.coord.lat,
        "lng": otherSource.coord.lng,
        "address": otherSource.placemark?.getAddress(),
      };
    }
    try {
      log("mencoba mengirim data..", label: "SEND_LATEST_LOCATION");
      await client.post("/profile/insert-user-track", data: sendData);
      log("send data berhasil= $sendData", label: "SEND_LATEST_LOCATION");
      return true;
    } on DioException catch (e) {
      log(
        "error send data DioException: ${e.response?.data ?? "-"}",
        label: "SEND_LATEST_LOCATION",
      );
      return false;
    } catch (e) {
      log(
        "error send data UnhandledException: $e",
        label: "SEND_LATEST_LOCATION",
      );
      return false;
    }
  }

  //* KIRIM LOKASI VIA BACKGROUND
  log("send lokasi via background", label: "SEND_LATEST_LOCATION");

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
  log("hasPermission? $hasPermission", label: "SEND_LATEST_LOCATION");
  if (hasPermission) {
    Position? position;
    log("sedang mendapatkan lokasi...", label: "SEND_LATEST_LOCATION");

    // handle service gps jika tidak aktif maka akan menggunakan get lastknown position dari native
    final isGPSEnabled = await Geolocator.isLocationServiceEnabled();
    log("isGPSEnabled? $isGPSEnabled", label: "SEND_LATEST_LOCATION");
    if (isGPSEnabled) {
      log(
        "mengambil lokasi dari getCurrentPosition...",
        label: "SEND_LATEST_LOCATION",
      );
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
        "get koordinat lokasi berhasil dari getCurrentPosition = ${{"lat": sendData['lat'], "lng": sendData['lng']}}",
        label: "SEND_LATEST_LOCATION",
      );
    } else {
      log(
        "mengambil lokasi dari lastKnownPosition...",
        label: "SEND_LATEST_LOCATION",
      );
      try {
        position = await Geolocator.getLastKnownPosition();
        if (position != null) {
          sendData = {
            ...sendData,
            "lat": position.latitude,
            "lng": position.longitude,
          };
        } else {
          position = null;
          sendData = {
            ...sendData,
            "reason": "Gagal mendapatkan koordinat lokasi terkini.",
          };
        }
      } catch (e) {
        position = null;
        sendData = {
          ...sendData,
          "reason": "Gagal mendapatkan koordinat lokasi terkini.",
        };
      }
      log(
        "get koordinat lokasi berhasil dari getLastKnownPosition = ${{"lat": sendData['lat'], "lng": sendData['lng']}}",
        label: "SEND_LATEST_LOCATION",
      );
    }

    // fetch address
    if (position != null) {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        sendData = {
          ...sendData,
          "address": placemarks[0].getAddress(),
          "reason": "Berhasil mendapatkan lokasi terkini.",
        };
      } else {
        sendData = {
          ...sendData,
          "reason": "Gagal mendapatkan alamat pengguna.",
        };
      }

      log(
        "fetch alamat berhasil = ${sendData['address'] ?? "-"}",
        label: "SEND_LATEST_LOCATION",
      );
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
    log("mencoba mengirim data..", label: "SEND_LATEST_LOCATION");
    await client.post("/profile/insert-user-track", data: sendData);
    log("send data berhasil = $sendData", label: "SEND_LATEST_LOCATION");
    return true;
  } on DioException catch (e) {
    log(
      "error send data DioException: ${e.response?.data ?? "-"}",
      label: "SEND_LATEST_LOCATION",
    );
    return false;
  } catch (e) {
    log(
      "error send data UnhandledException: $e",
      label: "SEND_LATEST_LOCATION",
    );
    return false;
  }
}
