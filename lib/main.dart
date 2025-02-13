
import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:awesome_notifications/awesome_notifications.dart' as an;

import 'package:rakhsa/awesome_notification.dart';
import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';

import 'package:rakhsa/features/auth/presentation/pages/welcome_page.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';

import 'package:rakhsa/firebase.dart';
import 'package:rakhsa/firebase_options.dart';

import 'package:rakhsa/global.dart';

import 'package:rakhsa/injection.dart' as di;

import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/providers.dart';
import 'package:rakhsa/shared/basewidgets/modal/modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

late List<CameraDescription> cameras;

final service = FlutterBackgroundService();

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  service.on("stop").listen((event) {
    service.stopSelf();
    debugPrint("== BACKGROUND PROCESS IS NOW STOPPED");
  });

  debugPrint("=== ON START ===");

  final sharedPreferences = await SharedPreferences.getInstance();

  Timer.periodic(const Duration(minutes: 2), (timer) async {
    debugPrint("=== SCHEDULER RUNNING ===");
    // DateTime now = DateTime.now();

    // Check if current time is exactly 4:00 AM or 4:00 PM
    // if ((now.hour == 4 || now.hour == 16) && now.minute == 0) {
      String? userId = sharedPreferences.getString("user_id");

      if (userId == null) {
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
            "product_name": androidInfo.product,
            "no_serial": androidInfo.serialNumber,
            "os_name": androidInfo.version.baseOS.toString() == "" ? "Android" : "IOS",
            "lat": position.latitude,
            "lng": position.longitude,
          },
        );
      } on DioException catch(e) {
        debugPrint(e.response?.data.toString());
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);
  
  await initializeDateFormatting('id_ID', null);

  await an.AwesomeNotifications().initialize('resource://drawable/ic_notification',
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

  cameras = await availableCameras();

  runApp(MultiProvider(
    providers: providers, 
    child: const MyApp()
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {

  late FirebaseProvider firebaseProvider;

  Widget home = const SizedBox();

  bool isDialogLocationShowing = false;
  bool isDialogLocationGpsShowing = false;
  bool isDialogNotificationShowing = false;
  bool isDialogMicrophoneShowing = false;
  bool isDialogCameraShowing = false;

  bool isResumedProcessing = false;

  Future<void> getData() async {
    bool? isLoggedIn = await StorageHelper.isLoggedIn();
    
    if(isLoggedIn != null) {
      if(isLoggedIn) {
        if(mounted) {
          setState(() => home = const DashboardScreen()); 
        }
      } else {
        if(mounted) {
          setState(() => home = const WelcomePage()); 
        }
      }
    } else {
      if(mounted) {
        setState(() => home = const WelcomePage()); 
      }
    }

    if (!mounted) return;
      await firebaseProvider.setupInteractedMessage(context);

    if(!mounted) return;
      firebaseProvider.listenNotification(context);
  }

  Future<void> getDataPermission() async {
    if(!mounted) return;
      await requestNotificationPermission();

    if(!mounted) return;
      await requestLocationMicrophoneCameraPermission();
  }

  Future<void> requestNotificationPermission() async {
    await Permission.notification.request();
    return;
  }

  Future<void> requestLocationMicrophoneCameraPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.microphone,
      Permission.camera,
    ].request();

    if(statuses[Permission.location] == PermissionStatus.denied || statuses[Permission.location] == PermissionStatus.permanentlyDenied) {
      await checkPermissionLocation();
      return;
    }

    if(statuses[Permission.microphone] == PermissionStatus.denied || statuses[Permission.microphone] == PermissionStatus.permanentlyDenied) {
      await checkPermissionMicrophone();
      return;
    }

    if(statuses[Permission.camera] == PermissionStatus.denied || statuses[Permission.camera] == PermissionStatus.permanentlyDenied) {
      await checkPermissionCamera();
      return;
    }
  }

  Future<void> checkPermissionNotification() async {
    bool isNotificationDenied = await Permission.notification.isDenied || await Permission.notification.isPermanentlyDenied;

    if(isNotificationDenied) {
      if (!isDialogNotificationShowing) {
        setState(() => isDialogNotificationShowing = true);
        await GeneralModal.dialogRequestPermission(
          msg: "Izin Notifikasi Dibutuhkan",
          type: "notification"
        );
        Future.delayed(const Duration(seconds: 1),() {
          setState(() => isDialogNotificationShowing = false);
        });

        return;
      }
    }
  }

  Future<void> checkPermissionCamera() async {
    bool isCameraDenied = await Permission.camera.isDenied || await Permission.camera.isPermanentlyDenied;

    if(isCameraDenied) {
      if (!isDialogCameraShowing) {
        setState(() => isDialogCameraShowing = true);
        await GeneralModal.dialogRequestPermission(
          msg: "Izin Kamera Dibutuhkan",
          type: "camera"
        );
        Future.delayed(const Duration(seconds: 1),() {
          if(mounted) {
            setState(() => isDialogCameraShowing = false);
          }
        });

        return;
      }
    }
  }

  Future<void> checkPermissionMicrophone() async {
    bool isMicrophoneDenied = await Permission.microphone.isDenied || await Permission.microphone.isPermanentlyDenied;  

    if(isMicrophoneDenied) {
      if (!isDialogMicrophoneShowing) {
        setState(() => isDialogMicrophoneShowing = true);
        await GeneralModal.dialogRequestPermission(
          msg: "Izin Microphone Dibutuhkan",
          type: "microphone"
        );
        Future.delayed(const Duration(seconds: 1),() {
          if(mounted) {
            setState(() => isDialogMicrophoneShowing = false);
          }
        });

        return;
      }
    }
  }

  Future<void> checkPermissionLocation() async {
    bool isLocationDenied = await Permission.location.isDenied || await Permission.location.isPermanentlyDenied;

    bool isGpsEnabled = await Geolocator.isLocationServiceEnabled();

    if(!isGpsEnabled) {
      if (!isDialogLocationGpsShowing) {
        setState(() => isDialogLocationGpsShowing = true);
        await GeneralModal.dialogRequestPermission(
          msg: "Perizinan akses lokasi dibutuhkan, silahkan aktifkan terlebih dahulu",
          type: "location-gps"
        );

        Future.delayed(const Duration(seconds: 1),() {
          if(mounted) {
            setState(() => isDialogLocationGpsShowing = false);
          }
        });
      }
    } else {
      await checkPermissionNotification();
      return;
    }

    if(isLocationDenied) {
      if (!isDialogLocationShowing) {
        setState(() => isDialogLocationShowing = true);
        await GeneralModal.dialogRequestPermission(
          msg: "Perizinan akses lokasi dibutuhkan, silahkan aktifkan terlebih dahulu",
          type: "location-app"
        );

        Future.delayed(const Duration(seconds: 1),() {
          if(mounted) {
            setState(() => isDialogLocationShowing = false);
          }
        });
      }
    } else {
      await checkPermissionNotification();
      return;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && !isResumedProcessing) {
      debugPrint("=== APP RESUME ===");

      isResumedProcessing = true;

      await Future.delayed(const Duration(milliseconds: 500)); 
    
      await getDataPermission();

      isResumedProcessing = false;
    }
  }

  @override 
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    firebaseProvider = context.read<FirebaseProvider>();

    Future.microtask(() => getData());

    Future.microtask(() => getDataPermission());
  }

  @override 
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

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
    );
  }
}

