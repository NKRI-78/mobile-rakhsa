import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rakhsa/misc/constants/remote_data_source_consts.dart';
import 'package:rakhsa/misc/helpers/storage.dart';

final service = FlutterBackgroundService();

void startBackgroundService() {
  service.startService();
}

void stopBackgroundService() {
  service.invoke("stop");
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  debugPrint("=== ON START ===");

  Timer.periodic(const Duration(hours: 12), (timer) async {
    debugPrint("=== SCHEDULER RUNNING ===");

    String? userId = await StorageHelper.loadlocalSession().then((v) {
      return v?.user.id;
    });

    if (userId == null) return;

    final deviceInfo = DeviceInfoPlugin();

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(accuracy: LocationAccuracy.best),
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String address = [
      placemarks[0].administrativeArea,
      placemarks[0].subAdministrativeArea,
      placemarks[0].street,
      placemarks[0].country,
    ].where((part) => part != null && part.isNotEmpty).join(", ");

    Map<String, dynamic> sendData = {};
    if (Platform.isIOS) {
      final iOSInfo = await deviceInfo.iosInfo;
      sendData = {
        "user_id": userId,
        "address": address,
        "device": iOSInfo.model,
        "product_name": iOSInfo.model,
        "no_serial": iOSInfo.systemName,
        "os_name": "iOS",
        "lat": position.latitude,
        "lng": position.longitude,
      };
    } else {
      final androidInfo = await deviceInfo.androidInfo;
      sendData = {
        "user_id": userId,
        "address": address,
        "device": androidInfo.model,
        "product_name": androidInfo.product,
        "no_serial": androidInfo.product,
        "os_name": "Android",
        "lat": position.latitude,
        "lng": position.longitude,
      };
    }

    try {
      //TODO: base api send user location setiap 12 sekali masih pakai yg production
      await Dio().post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile/insert-user-track",
        data: sendData,
      );
    } on DioException catch (e) {
      debugPrint(e.response?.data.toString());
      throw Exception(e.response?.data['message'] ?? '-');
    } catch (e) {
      debugPrint("Error posting data: $e");
      throw Exception(e.toString());
    }
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  // WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}
