import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/modules/referral/provider/referral_provider.dart';
import 'package:rakhsa/service/app/new_version/app_upgrader.dart';
import 'package:rakhsa/service/app/universal_link.dart';
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

  final uniLink = UniversalLink();
  final notif = NotificationManager();

  final _upgrader = Upgrader(countryCode: 'ID', debugLogging: kDebugMode);

  @override
  void initState() {
    super.initState();
    _initializeRouter();
    _initializeService();
  }

  @override
  void dispose() {
    uniLink.dispose();
    super.dispose();
  }

  void _initializeService() async {
    if (BuildConfig.isProd) await uniLink.initializeUriHandlers();
    await notif.initializeFcmHandlers();
    await notif.setForegroundMessageActionListeners();
  }

  void _initializeRouter() {
    router = AppRouter().generateRoute(
      locator<AuthProvider>(),
      locator<ReferralProvider>(),
    );
  }

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
