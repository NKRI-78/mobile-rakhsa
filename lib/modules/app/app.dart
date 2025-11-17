import 'package:flutter/material.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/service/notification/notification_manager.dart';
import 'package:rakhsa/routes/nav_key.dart';
import 'package:rakhsa/routes/routes_navigation.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() async {
    await NotificationManager().initializeFcmHandlers();
    await NotificationManager().setForegroundMessageActionListeners();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldKey,
      navigatorKey: navigatorKey,
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RoutesNavigation.onGenerateRoute,
      initialRoute: RoutesNavigation.splash,
      builder: BuildConfig.isStag
          ? (context, child) => Banner(
              message: "Staging",
              location: BannerLocation.topEnd,
              child: child,
            )
          : null,
    );
  }
}
