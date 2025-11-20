import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/router/route_invalid_page.dart';

import 'route_trees.dart';

final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static AppRouter? _instance;

  AppRouter._private();

  factory AppRouter() {
    _instance ??= AppRouter._private();
    return _instance!;
  }

  GoRouter generateRoute(AuthProvider auth) {
    return GoRouter(
      routes: $appRoutes,
      navigatorKey: navigatorKey,
      initialLocation: WelcomeRoute().location,
      debugLogDiagnostics: kDebugMode || kProfileMode,
      // extraCodec: RouteParamDecoder(),
      errorBuilder: (_, s) => RouteInvalidPage(s),
      redirect: (c, s) {
        final currentRoute = s.matchedLocation;

        final goingToOnBoarding = currentRoute == OnBoardingRoute().location;
        final goingToWelcome = currentRoute == WelcomeRoute().location;
        final goingToLogin = currentRoute == LoginRoute().location;
        final goingToRegister = currentRoute == RegisterRoute().location;
        final goingToDashboard = currentRoute == DashboardRoute().location;

        if (auth.showOnBoarding()) {
          if (!goingToOnBoarding) return OnBoardingRoute().location;
          return null;
        }

        if (!auth.userIsLoggedIn()) {
          if (!goingToWelcome && !goingToLogin && !goingToRegister) {
            return WelcomeRoute().location;
          }
          return null;
        }

        if (goingToWelcome ||
            goingToLogin ||
            goingToRegister ||
            goingToOnBoarding ||
            currentRoute == '/') {
          if (!goingToDashboard) return DashboardRoute().location;
        }

        return null;
      },
    );
  }
}
