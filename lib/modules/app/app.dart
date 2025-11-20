import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rakhsa/build_config.dart';
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

  @override
  void initState() {
    super.initState();
    router = AppRouter().generateRoute(locator<AuthProvider>());
    _initializeService();
  }

  void _initializeService() async {
    await NotificationManager().initializeFcmHandlers();
    await NotificationManager().setForegroundMessageActionListeners();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      scaffoldMessengerKey: scaffoldKey,
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
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
