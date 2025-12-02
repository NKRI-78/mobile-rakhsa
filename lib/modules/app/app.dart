import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/misc/utils/logger.dart';
import 'package:rakhsa/modules/referral/provider/referral_provider.dart';
import 'package:rakhsa/repositories/referral/referral_repository.dart';
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

  final _upgrader = Upgrader(countryCode: 'ID', debugLogging: true);

  StreamSubscription<Uri>? _linkSubs;

  @override
  void initState() {
    super.initState();
    router = AppRouter().generateRoute(
      locator<AuthProvider>(),
      locator<ReferralProvider>(),
    );
    _initializeService();
  }

  @override
  void dispose() {
    _linkSubs?.cancel();
    _linkSubs = null;
    super.dispose();
  }

  void _initializeService() async {
    await _initDeepLinks();
    await NotificationManager().initializeFcmHandlers();
    await NotificationManager().setForegroundMessageActionListeners();
  }

  Future<void> _initDeepLinks() async {
    _linkSubs?.cancel();
    _linkSubs = AppLinks().uriLinkStream.listen((uri) async {
      log('onAppLink: $uri', label: "APP_LINKS");
      final referralCode = uri.queryParameters['telkom_trx'];
      log('referralCode: $referralCode', label: "REFERRAL_CODE");
      if (referralCode != null) {
        await locator<ReferralRepository>().saveReferralCode(referralCode);
      }
    });
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
