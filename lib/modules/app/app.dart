import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/misc/utils/logger.dart';
import 'package:rakhsa/service/app/new_version/app_upgrader.dart';
import 'package:upgrader/upgrader.dart';
import 'package:rakhsa/injection.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/router/router.dart';
import 'package:rakhsa/service/notification/notification_manager.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  late GoRouter router;

  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    router = AppRouter().generateRoute(locator<AuthProvider>());
    _initializeService();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      final referralCode = uri.queryParameters['telkom_trx'];
      final userIsLoggedIn = locator<AuthProvider>().userIsLoggedIn();
      log(
        'onAppLink: $uri | userIsLoggedIn? $userIsLoggedIn',
        label: "APP_LINKS",
      );

      if (referralCode != null) {
        if (userIsLoggedIn) {
        } else {}
      }
    });
  }

  void _initializeService() async {
    await _initDeepLinks();
    await NotificationManager().initializeFcmHandlers();
    await NotificationManager().setForegroundMessageActionListeners();
  }

  final _upgrader = Upgrader(countryCode: 'ID', debugLogging: true);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      scaffoldMessengerKey: scaffoldKey,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return AppUpgradeAlert(
          upgrader: _upgrader,
          navigatorKey: router.routerDelegate.navigatorKey,
          child: BuildConfig.isStag
              ? Banner(
                  message: "STAGING",
                  location: BannerLocation.topEnd,
                  child: child,
                )
              : child,
        );
      },
    );
  }
}
