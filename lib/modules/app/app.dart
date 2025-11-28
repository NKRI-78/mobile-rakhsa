import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/misc/utils/logger.dart';
import 'package:rakhsa/modules/auth/page/welcome_page.dart';
import 'package:rakhsa/modules/dashboard/presentation/pages/dashboard_page.dart';
import 'package:rakhsa/modules/on_boarding/page/on_boarding_page.dart';
import 'package:rakhsa/service/app/new_version/app_upgrader.dart';
import 'package:rakhsa/service/notification/notification_manager.dart';
import 'package:rakhsa/routes/nav_key.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:upgrader/upgrader.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  final _showOnBoarding = !StorageHelper.containsKey("on_boarding_key");
  final _userIsLoggedIn = StorageHelper.isLoggedIn();

  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    _linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      log('onAppLink: $uri', label: "APP_LINKS");
    });
  }

  void _initializeService() async {
    _initDeepLinks();
    await NotificationManager().initializeFcmHandlers();
    await NotificationManager().setForegroundMessageActionListeners();
  }

  final _upgrader = Upgrader(countryCode: 'ID', debugLogging: true);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldKey,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RoutesNavigation.onGenerateRoute,
      home: AppUpgradeAlert(
        upgrader: _upgrader,
        child: _showOnBoarding
            ? OnBoardingPage()
            : _userIsLoggedIn
            ? DashboardPage()
            : WelcomePage(),
      ),
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
