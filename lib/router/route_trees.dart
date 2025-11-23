import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rakhsa/modules/auth/page/forgot_password_page.dart';
import 'package:rakhsa/modules/auth/page/login_page.dart';
import 'package:rakhsa/modules/auth/page/register_page.dart';
import 'package:rakhsa/modules/auth/page/welcome_page.dart';
import 'package:rakhsa/modules/chat/presentation/pages/chat_room_page.dart';
import 'package:rakhsa/modules/chat/presentation/pages/notification_page.dart';
import 'package:rakhsa/modules/dashboard/presentation/pages/dashboard_page.dart';
import 'package:rakhsa/modules/information/presentation/pages/kbri.dart';
import 'package:rakhsa/modules/information/presentation/pages/panduan_hukum.dart';
import 'package:rakhsa/modules/information/presentation/pages/passport_visa/index.dart';
import 'package:rakhsa/modules/information/presentation/pages/search.dart';
import 'package:rakhsa/modules/nearme/presentation/pages/near_me_page.dart';
import 'package:rakhsa/modules/news/persentation/pages/detail.dart';
import 'package:rakhsa/modules/on_boarding/page/on_boarding_page.dart';
import 'package:rakhsa/modules/profile/page/profile_page.dart';
import 'package:rakhsa/modules/weather/page/weather_page.dart';

part 'route_trees.g.dart';

//* ON BOARDING
@TypedGoRoute<OnBoardingRoute>(path: '/on-boarding')
class OnBoardingRoute extends GoRouteData with $OnBoardingRoute {
  const OnBoardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OnBoardingPage();
}

//* WELCOME
@TypedGoRoute<WelcomeRoute>(
  path: '/welcome',
  routes: [
    TypedGoRoute<LoginRoute>(path: "login"),
    TypedGoRoute<RegisterRoute>(path: "register"),
    TypedGoRoute<ForgotPasswordRoute>(path: "forgot-password"),
  ],
)
class WelcomeRoute extends GoRouteData with $WelcomeRoute {
  const WelcomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const WelcomePage();
}

//* WELCOME / LOGIN
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginPage();
}

//* WELCOME / REGISTER
class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RegisterPage();
}

//* WELCOME / FORGOT PASSWORD
class ForgotPasswordRoute extends GoRouteData with $ForgotPasswordRoute {
  const ForgotPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ForgotPasswordPage();
}

//* DASHBOARD
@TypedGoRoute<DashboardRoute>(
  path: '/',
  routes: [
    TypedGoRoute<InformasiKBRIRoute>(
      path: "informasi-kbri",
      routes: [
        TypedGoRoute<KBRIDetailRoute>(path: "kbri-detail"),
        TypedGoRoute<KBRIUserDocumentRoute>(path: "kbri-user-document"),
      ],
    ),
    TypedGoRoute<PanduanHukumRoute>(path: "panduan-hukum"),
    TypedGoRoute<NearMeRoute>(path: "near-me"),
    TypedGoRoute<ProfileRoute>(path: "profile"),
    TypedGoRoute<NotificationRoute>(path: "notification"),
    TypedGoRoute<ChatRoomRoute>(path: "chat-room"),
    TypedGoRoute<NewsDetailRoute>(path: "news-detail"),
    TypedGoRoute<WeatherRoute>(path: "weather"),
  ],
)
class DashboardRoute extends GoRouteData with $DashboardRoute {
  const DashboardRoute({this.fromRegister = false});

  final bool fromRegister;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return DashboardPage(fromRegister: fromRegister);
  }
}

//* DASHBOARD / INFORMASI KBRI
class InformasiKBRIRoute extends GoRouteData with $InformasiKBRIRoute {
  const InformasiKBRIRoute({this.info = ""});

  final String info;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SearchPage(info: info);
  }
}

//* DASHBOARD / INFORMASI KBRI / KBRI DETAIL
class KBRIDetailRoute extends GoRouteData with $KBRIDetailRoute {
  const KBRIDetailRoute({required this.stateId});

  final int stateId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return KbriPage(stateId: stateId);
  }
}

//* DASHBOARD / INFORMASI KBRI / KBRI DETAIL
class KBRIUserDocumentRoute extends GoRouteData with $KBRIUserDocumentRoute {
  const KBRIUserDocumentRoute({required this.stateId});

  final int stateId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PassportVisaIndexPage(stateId: stateId);
  }
}

//* DASHBOARD / PANDUAN HUKUM
class PanduanHukumRoute extends GoRouteData with $PanduanHukumRoute {
  const PanduanHukumRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PanduanHukumPage();
  }
}

//* DASHBOARD / NEAR ME
class NearMeRoute extends GoRouteData with $NearMeRoute {
  const NearMeRoute({required this.type});

  final String type;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return NearMePage(type: type);
  }
}

//* DASHBOARD / PROFILE
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProfilePage();
  }
}

//* DASHBOARD / NOTIFICATION
class NotificationRoute extends GoRouteData with $NotificationRoute {
  const NotificationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return NotificationPage();
  }
}

//* DASHBOARD / CHAT ROOM
class ChatRoomRoute extends GoRouteData with $ChatRoomRoute {
  const ChatRoomRoute(this.$extra);

  final ChatRoomParams $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChatRoomPage($extra);
  }
}

//* DASHBOARD / NEWS DETAIL
class NewsDetailRoute extends GoRouteData with $NewsDetailRoute {
  const NewsDetailRoute(this.$extra);

  final NewsDetailPageParams $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return NewsDetailPage(id: $extra.id, type: $extra.type);
  }
}

//* DASHBOARD / WEATHER
class WeatherRoute extends GoRouteData with $WeatherRoute {
  const WeatherRoute(this.$extra);

  final WeatherPageParams $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return WeatherPage($extra);
  }
}
