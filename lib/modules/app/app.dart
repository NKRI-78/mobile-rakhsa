import 'package:flutter/material.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/service/notification/notification_manager.dart';
import 'package:rakhsa/routes/nav_key.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/service/storage/storage.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  final _showOnBoarding = !StorageHelper.containsKey("on_boarding_key");
  final _userIsLoggedIn = StorageHelper.isLoggedIn();

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
    final initialRoute = _showOnBoarding
        ? RoutesNavigation.onBoarding
        : _userIsLoggedIn
        ? RoutesNavigation.dashboard
        : RoutesNavigation.welcomePage;

    return MaterialApp(
      scaffoldMessengerKey: scaffoldKey,
      navigatorKey: navigatorKey,
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RoutesNavigation.onGenerateRoute,
      initialRoute: initialRoute,
      builder: BuildConfig.isStag
          ? (_, child) => Banner(
              message: "Staging",
              location: BannerLocation.topEnd,
              child: child,
            )
          : null,
    );
  }
}
