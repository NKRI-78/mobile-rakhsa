
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:awesome_notifications/awesome_notifications.dart' as an;

import 'package:rakhsa/awesome_notification.dart';
import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';

import 'package:rakhsa/features/auth/presentation/pages/login.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';

import 'package:rakhsa/firebase.dart';
import 'package:rakhsa/firebase_options.dart';

import 'package:rakhsa/global.dart';

import 'package:rakhsa/injection.dart' as di;

import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

final service = FlutterBackgroundService();

void initializeNotifications() {
  an.AwesomeNotifications().setListeners(
    onActionReceivedMethod: AwesomeNotificationService.onActionReceivedMethod,
    onNotificationCreatedMethod: AwesomeNotificationService.onNotificationCreated,
    onNotificationDisplayedMethod: AwesomeNotificationService.onNotificationDisplay,
    onDismissActionReceivedMethod: AwesomeNotificationService.onDismissAction,
  );
}

const notificationId = 888;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  service.on("stop").listen((event) {
    service.stopSelf();
    debugPrint("background process is now stopped");
  });

  debugPrint("=== ON START ===");

  final sharedPreferences = await SharedPreferences.getInstance();

  await an.AwesomeNotifications().createNotification(
    content: an.NotificationContent(
      id: notificationId, 
      notificationLayout: an.NotificationLayout.Default,
      roundedLargeIcon: false,
      hideLargeIconOnExpand: true,
      locked: true,
      icon: "resource://drawable/ic_launcher",
      title: "Background Service",
      body: "Preparing",
      channelKey: "notification",
    )
  );

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    // DateTime now = DateTime.now();

    // Check if current time is 4 AM or 4 PM
    // if (now.hour == 4 && now.minute == 0) {
    String? userId = sharedPreferences.getString("user_id");

    if (userId == null) {
      debugPrint("No user_id found, skipping data posting.");
      return;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
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
      await Dio().post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile/insert-user-track",
        data: {
          "user_id": userId,
          "address": address,
          "device": androidInfo.model,
          "lat": position.latitude,
          "lng": position.longitude,
        },
      );
    } catch (e) {
      debugPrint("Error posting data: $e");
    }
    // }
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

void startBackgroundService() {
  service.startService();
}

void stopBackgroundService() {
  service.invoke("stop");
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "fetchBackground":

        // final sharedPreferences = await SharedPreferences.getInstance();

        // String? userId = sharedPreferences.getString("user_id");

        // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        // List<Placemark> placemarks = await placemarkFromCoordinates(
        //   position.latitude,
        //   position.longitude,
        // );

        // String address = [
        //   placemarks[0].administrativeArea,
        //   placemarks[0].subAdministrativeArea,
        //   placemarks[0].street,
        //   placemarks[0].country,
        // ].where((part) => part != null && part.isNotEmpty).join(", ");

        // try {
        //   await Dio().post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile/insert-user-track",
        //     data: {
        //       "user_id": userId,
        //       "address": address,
        //       "device": androidInfo.model,
        //       "lat": position.latitude,
        //       "lng": position.longitude,
        //     },
        //   );
        // } catch (e) {
        //   debugPrint("Error posting data: $e");
        // }

        debugPrint("=== RUNNING ON BACKGROUND ===");

        debugPrint("Lat : ${position.latitude.toString()} Lng : ${position.longitude.toString()}");

      break;
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(
    callbackDispatcher, 
    isInDebugMode: false 
  );
  Workmanager().registerPeriodicTask(
    "1",
    "fetchBackground",
    frequency: const Duration(minutes: 15),
  );
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

  await initializeDateFormatting('id_ID', null);

  await an.AwesomeNotifications().initialize(
    'resource://drawable/ic_notification',
    [
      an.NotificationChannel(
        channelKey: 'notification',
        channelName: 'notification',
        channelDescription: 'Notification',
        playSound: true,
        channelShowBadge: true,
        criticalAlerts: true,
        importance: an.NotificationImportance.High,
      )
    ],
    debug: false
  );

  an.AwesomeNotifications().getInitialNotificationAction().then((receivedAction) {
    if (receivedAction != null) {
      AwesomeNotificationService.onActionReceivedMethod(receivedAction);
    }
  });

  await StorageHelper.init();

  di.init();

  Gemini.init(apiKey: 'AIzaSyBROwuSIdITYdSU7GWWWg-oBZntbSX_D8E');

  EasyLoading.instance
    ..userInteractions = false
    ..dismissOnTap = false;

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  late FirebaseProvider firebaseProvider;

  static const String isolateName = "LocatorIsolate";
  ReceivePort port = ReceivePort();

  Widget home = const SizedBox();

  Future<void> getData() async {
    bool? isLoggedIn = await StorageHelper.isLoggedIn();
    
    if(isLoggedIn != null) {

      if(isLoggedIn) {
        if(mounted) {
          setState(() => home = const DashboardScreen()); 
        }
      } else {
        if(mounted) {
          setState(() => home = const LoginPage()); 
        }
      }

    } else {
      if(mounted) {
        setState(() => home = const LoginPage()); 
      }
    }

    if (!mounted) return;
      await context.read<FirebaseProvider>().setupInteractedMessage(context);

    if(!mounted) return;
      firebaseProvider.listenNotification(context);
  }

  @override 
  void initState() {
    super.initState();

    firebaseProvider = context.read<FirebaseProvider>();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldKey,
      navigatorKey: navigatorKey,
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RoutesNavigation.onGenerateRoute,
      home: home,
      builder: EasyLoading.init(),
    );
  }
}

