import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:awesome_notifications/awesome_notifications.dart' as an;

import 'package:rakhsa/awesome_notification.dart';
import 'package:rakhsa/injection.dart';

import 'package:rakhsa/firebase.dart';
import 'package:rakhsa/firebase_options.dart';

import 'package:rakhsa/injection.dart' as di;
import 'package:rakhsa/misc/constants/remote_data_source_consts.dart';

import 'package:rakhsa/misc/helpers/storage.dart';

import 'package:rakhsa/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './modules/app/app.dart' as app;

final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();

late List<CameraDescription> cameras;

final service = FlutterBackgroundService();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  debugPrint("=== ON START ===");

  final sharedPreferences = await SharedPreferences.getInstance();

  Timer.periodic(const Duration(hours: 12), (timer) async {
    debugPrint("=== SCHEDULER RUNNING ===");
    // DateTime now = DateTime.now();

    // Check if current time is exactly 4:00 AM or 4:00 PM
    // if ((now.hour == 4 || now.hour == 16) && now.minute == 0) {
    String? userId = sharedPreferences.getString("user_id");

    if (userId == null) {
      return;
    }

    final androidInfo = await locator<DeviceInfoPlugin>().androidInfo;

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

    try {
      await Dio().post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile/insert-user-track",
        data: {
          "user_id": userId,
          "address": address,
          "device": androidInfo.model,
          "product_name": androidInfo.product,
          "no_serial": androidInfo.product,
          "os_name": Platform.isAndroid ? "Android" : "iOS",
          "lat": position.latitude,
          "lng": position.longitude,
        },
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

void startBackgroundService() {
  service.startService();
}

void stopBackgroundService() {
  service.invoke("stop");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await initializeDateFormatting('id_ID', null);

  if (Platform.isIOS) {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        );
  }

  await an.AwesomeNotifications()
      .initialize('resource://drawable/ic_notification', [
        an.NotificationChannel(
          channelKey: 'notification',
          channelName: 'notification',
          channelDescription: 'Notification',
          playSound: true,
          channelShowBadge: true,
          criticalAlerts: true,
          importance: an.NotificationImportance.High,
        ),
      ], debug: false);

  an.AwesomeNotifications().getInitialNotificationAction().then((
    receivedAction,
  ) {
    if (receivedAction != null) {
      AwesomeNotificationService.onActionReceivedMethod(receivedAction);
      AwesomeNotificationService.onDismissAction(receivedAction);
    }
  });

  await StorageHelper.init();

  di.init();

  cameras = await availableCameras();

  HttpOverrides.global = MyHttpOverrides();

  runApp(MultiProvider(providers: providers, child: app.App()));
}
