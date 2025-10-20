import 'dart:async';
import 'dart:io';
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
import 'package:provider/provider.dart';

import 'package:awesome_notifications/awesome_notifications.dart' as an;

import 'package:rakhsa/awesome_notification.dart';
import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/features/auth/presentation/pages/on_boarding_page.dart';

import 'package:rakhsa/features/auth/presentation/pages/welcome_page.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';

import 'package:rakhsa/firebase.dart';
import 'package:rakhsa/firebase_options.dart';

import 'package:rakhsa/global.dart';

import 'package:rakhsa/injection.dart' as di;

import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          "os_name": androidInfo.version.baseOS.toString() == ""
              ? "Android"
              : "IOS",
          "lat": position.latitude,
          "lng": position.longitude,
        },
      );
    } on DioException catch (e) {
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

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

  await initializeDateFormatting('id_ID', null);

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

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late FirebaseProvider firebaseProvider;

  Widget home = const SizedBox();

  bool isResumedProcessing = false;

  Future<Widget> getInitPage() async {
    Dio dio = Dio();
    Response res = await dio.get(
      "https://api-rakhsa.inovatiftujuh8.com/api/v1/admin/toggle/feature",
    );

    // tampilkan onboarding ketika key tidak ditemukan
    // key tidak ditemukan karena belum di set
    // akan di set dihalaman on boarding pada action button ('selesai')
    bool showOnBoarding = !StorageHelper.containsOnBoardingKey();

    if (res.data["data"]["feature_onboarding"] == true) {
      if (showOnBoarding) {
        return const OnBoardingPage();
      } else {
        return const WelcomePage();
      }
    } else {
      return const WelcomePage();
    }
  }

  Future<void> getData() async {
    bool? isLoggedIn = await StorageHelper.isLoggedIn();
    Widget initPage = await getInitPage();

    if (isLoggedIn != null) {
      if (isLoggedIn) {
        if (mounted) {
          setState(() => home = const DashboardScreen());
        }
      } else {
        if (mounted) {
          setState(() => home = initPage);
        }
      }
    } else {
      if (mounted) {
        setState(() => home = initPage);
      }
    }

    if (!mounted) return;
    await firebaseProvider.setupInteractedMessage(context);

    if (!mounted) return;
    firebaseProvider.listenNotification(context);
  }

  // Future<void> recheckRequestNotification() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;

  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );

  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     debugPrint('User granted [notification] permission');
  //   } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  //     debugPrint('User granted [notification] provisional permission');
  //   } else {
  //     if(await Permission.notification.isPermanentlyDenied) {
  //       if (!isDialogNotificationShowing) {
  //         setState(() => isDialogNotificationShowing = true);
  //         await GeneralModal.dialogRequestPermission(
  //           msg: "Perizinan akses notifikasi dibutuhkan, silahkan aktifkan terlebih dahulu",
  //           type: "notification"
  //         );
  //         setState(() => isDialogNotificationShowing = false);
  //       }
  //       debugPrint('User declined [notification] or has not accepted permission');
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    firebaseProvider = context.read<FirebaseProvider>();

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  // bool isDialogShowing = false; // Prevent multiple dialogs

  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   if (state != AppLifecycleState.resumed || isDialogShowing) return; // Prevent re-entry

  //   debugPrint("=== APP RESUME ===");
  //   isDialogShowing = true;

  //   if (await requestPermission(Permission.location, "location")) return;

  //   if (!await Geolocator.isLocationServiceEnabled()) {
  //     await showDialog("Perizinan akses device lokasi dibutuhkan, silahkan aktifkan terlebih dahulu", "GPS");
  //     isDialogShowing = false;
  //     return;
  //   }

  //   if (await requestPermission(Permission.notification, "notification")) return;

  //   if (await requestPermission(Permission.microphone, "microphone")) return;

  //   if (await requestPermission(Permission.camera, "camera")) return;

  //   debugPrint("ALL PERMISSIONS GRANTED");
  //   isDialogShowing = false;
  // }

  // Future<bool> requestPermission(Permission permission, String type) async {
  //   var status = await permission.request();

  //   if (status == PermissionStatus.permanentlyDenied) {
  //     await showDialog("Perizinan akses $type dibutuhkan, silahkan aktifkan terlebih dahulu", type);
  //     isDialogShowing = false;
  //     return true; // Stop further execution
  //   }

  //   if (status != PermissionStatus.granted) {
  //     debugPrint("Permission $type denied, stopping process.");
  //     isDialogShowing = false;
  //     return true; // Stop further execution
  //   }

  //   return false; // Continue to the next permission
  // }

  // Future<void> showDialog(String message, String type) async {
  //   if (!isDialogShowing) return; // Prevent showing multiple dialogs
  //   await GeneralModal.dialogRequestPermission(msg: message, type: type);
  // }

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
