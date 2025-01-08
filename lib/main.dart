import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';


import 'package:awesome_notifications/awesome_notifications.dart' as an;

import 'package:provider/provider.dart';
import 'package:rakhsa/awesome_notification.dart';

import 'package:rakhsa/features/auth/presentation/pages/login.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';

import 'package:rakhsa/firebase.dart';
import 'package:rakhsa/firebase_options.dart';

import 'package:rakhsa/global.dart';

import 'package:rakhsa/injection.dart' as di;

import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/providers.dart';

void initializeNotifications() {
  an.AwesomeNotifications().setListeners(
    onActionReceivedMethod: AwesomeNotificationController.onActionReceivedMethod,
    onNotificationCreatedMethod: AwesomeNotificationController.onNotificationCreated,
    onNotificationDisplayedMethod: AwesomeNotificationController.onNotificationDisplay,
    onDismissActionReceivedMethod: AwesomeNotificationController.onDismissAction,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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

  // Listen for initial action (when app is terminated)
  an.AwesomeNotifications().getInitialNotificationAction().then((receivedAction) {
    if (receivedAction != null) {
      AwesomeNotificationController.onActionReceivedMethod(receivedAction);
    }
  });

  await FirebaseProvider.registerBackgroundHandler();

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

    initializeNotifications();

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
      title: 'Home',
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}
