import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:awesome_notifications/awesome_notifications.dart' as an;

import 'package:provider/provider.dart';
import 'package:rakhsa/awesome_notification.dart';

import 'package:rakhsa/features/auth/presentation/pages/login.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';

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

  await initializeDateFormatting('id_ID', null);

  await an.AwesomeNotifications().initialize(
    null, 
    [
      an.NotificationChannel(
        channelKey: 'notification',
        channelName: 'notification_channel',
        channelDescription: 'Notification',
        playSound: true,
        channelShowBadge: true,
        onlyAlertOnce: true,
        criticalAlerts: true,
        groupAlertBehavior: an.GroupAlertBehavior.Children,
        importance: an.NotificationImportance.High,
        defaultPrivacy: an.NotificationPrivacy.Private,
        defaultColor: Colors.deepPurple,
        ledColor: Colors.deepPurple
      )
    ],
    debug: false
  );


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
  }

  @override 
  void initState() {
    super.initState();

    initializeNotifications();

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
