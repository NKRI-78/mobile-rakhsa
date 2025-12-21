import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rakhsa/core/debug/logger.dart';
import 'package:rakhsa/modules/referral/provider/referral_provider.dart';
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

  GoRouter generateRoute(AuthProvider auth, ReferralProvider referral) {
    return GoRouter(
      routes: $appRoutes,
      navigatorKey: navigatorKey,
      initialLocation: WelcomeRoute().location,
      debugLogDiagnostics: kDebugMode || kProfileMode,
      errorBuilder: (_, s) => RouteInvalidPage(s),
      redirect: (c, s) {
        final currentRoute = s.matchedLocation;

        log("router = ${s.uri.path}", label: "APP_ROUTER");

        final goingToOnBoarding = currentRoute == OnBoardingRoute().location;
        final goingToWelcome = currentRoute == WelcomeRoute().location;
        final goingToLogin = currentRoute == LoginRoute().location;
        final goingToForgotPass =
            currentRoute == ForgotPasswordRoute().location;
        final goingToRegister = currentRoute == RegisterRoute().location;
        final goingToDashboard = currentRoute == DashboardRoute().location;
        final goingToActivateReferral =
            currentRoute == ActivateReferralRoute().location;
        final goingToNoReferral =
            currentRoute == NoReferralCodeRoute().location;

        if (auth.showOnBoarding()) {
          if (!goingToOnBoarding) return OnBoardingRoute().location;
          return null;
        }

        if (!auth.userIsLoggedIn()) {
          if (goingToNoReferral && !referral.hasReferralCode) {
            return NoReferralCodeRoute().location;
          }

          if (!goingToWelcome &&
              !goingToLogin &&
              !goingToRegister &&
              !goingToNoReferral &&
              !goingToForgotPass &&
              !goingToActivateReferral) {
            return WelcomeRoute().location;
          }
          return null;
        }

        if (goingToActivateReferral && referral.hasReferralCode) {
          return ActivateReferralRoute().location;
        }

        if (goingToWelcome ||
            goingToLogin ||
            goingToRegister ||
            goingToForgotPass ||
            goingToOnBoarding ||
            currentRoute == '/' ||
            currentRoute == "/referral") {
          if (!goingToDashboard) return DashboardRoute().location;
        }

        return null;
      },
    );
  }
}
