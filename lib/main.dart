
import 'dart:async';
// import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:awesome_notifications/awesome_notifications.dart' as an;

import 'package:rakhsa/awesome_notification.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';

import 'package:rakhsa/features/auth/presentation/pages/login.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';

import 'package:rakhsa/firebase.dart';
import 'package:rakhsa/firebase_options.dart';

import 'package:rakhsa/global.dart';

import 'package:rakhsa/injection.dart' as di;

import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/providers.dart';

// void initializeNotifications() {
//   an.AwesomeNotifications().setListeners(
//     onActionReceivedMethod: AwesomeNotificationService.onActionReceivedMethod,
//     onNotificationCreatedMethod: AwesomeNotificationService.onNotificationCreated,
//     onNotificationDisplayedMethod: AwesomeNotificationService.onNotificationDisplay,
//     onDismissActionReceivedMethod: AwesomeNotificationService.onDismissAction,
//   );
// }

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   Timer.periodic(const Duration(seconds: 5), (timer) async {
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.bestForNavigation,
//       forceAndroidLocationManager: true
//     );

//     debugPrint(position.latitude.toString());
//     debugPrint(position.longitude.toString());
//   });
// }

// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();

//   return true;
// }

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();

//   await service.configure(
//     iosConfiguration: IosConfiguration(
//       autoStart: true,
//       onForeground: onStart,
//       onBackground: onIosBackground,
//     ),
//     androidConfiguration: AndroidConfiguration(
//       autoStart: true,
//       isForegroundMode: false,
//       autoStartOnBoot: true,
//       onStart: onStart,
//       foregroundServiceTypes: [
//         AndroidForegroundType.location
//       ],
//     ),
//   );
// }

// void startBackgroundService() {
//   final service = FlutterBackgroundService();
//   service.startService();
// }

// void stopBackgroundService() {
//   final service = FlutterBackgroundService();
//   service.invoke("stop");
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await initializeService();

  // startBackgroundService();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        onlyAlertOnce: true,
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

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  late FirebaseProvider firebaseProvider;

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

    // initializeNotifications();

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
    );
  }
}
