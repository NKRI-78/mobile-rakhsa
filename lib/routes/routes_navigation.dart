import 'package:flutter/material.dart';
import 'package:rakhsa/modules/auth/page/forgot_password_page.dart';
import 'package:rakhsa/modules/auth/page/login_page.dart';
import 'package:rakhsa/modules/auth/page/register_page.dart';
import 'package:rakhsa/modules/auth/page/welcome_page.dart';
import 'package:rakhsa/modules/chat/presentation/pages/chat_room_page.dart';
import 'package:rakhsa/modules/chat/presentation/pages/notification_page.dart';
import 'package:rakhsa/modules/dashboard/presentation/pages/dashboard_page.dart';
import 'package:rakhsa/modules/weather/page/weather_page.dart';
import 'package:rakhsa/modules/information/presentation/pages/list.dart';
import 'package:rakhsa/modules/nearme/presentation/pages/near_me_page.dart';
import 'package:rakhsa/modules/nearme/presentation/pages/near_me_page_list_type.dart';
import 'package:rakhsa/modules/news/persentation/pages/detail.dart';
import 'package:rakhsa/modules/news/persentation/pages/list.dart';
import 'package:rakhsa/modules/on_boarding/page/on_boarding_page.dart';

class RoutesNavigation {
  RoutesNavigation._();

  static const dashboard = '/dashboard';
  static const nearMe = '/near-me';
  static const forgotPassword = '/forgot-password';
  static const onBoarding = '/on-boarding';
  static const welcomePage = '/welcome';
  static const register = '/register';
  static const weather = '/weather';
  static const chats = '/chats';
  static const chat = '/chat';
  static const login = '/login';
  static const nearMeTypeList = '/near-me-type-list';
  static const information = '/information';
  static const news = '/news';
  static const newsDetail = '/news-detail';
  static const deviceNotSupport = '/device-not-support';

  static const itinerary = '/itinerary';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              DashboardScreen(fromRegister: args?['from_register'] ?? false),
        );
      case onBoarding:
        return MaterialPageRoute(builder: (_) => const OnBoardingPage());
      case deviceNotSupport:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case information:
        return MaterialPageRoute(builder: (_) => const InformationListPage());
      case weather:
        final data = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => WeatherPage(data));
      case chats:
        return MaterialPageRoute(builder: (_) => const NotificationPage());
      case chat:
        final data = settings.arguments as Map<String, dynamic>;
        bool autoGreetings = data["auto_greetings"];
        String chatId = data["chat_id"];
        String sosId = data["sos_id"];
        String recipientId = data["recipient_id"];
        String status = data["status"];
        bool newNesssion = data['new_session'] ?? false;

        return MaterialPageRoute(
          builder: (_) => ChatRoomPage(
            autoGreetings: autoGreetings,
            chatId: chatId,
            recipientId: recipientId,
            sosId: sosId,
            status: status,
            newSession: newNesssion,
          ),
        );
      case nearMeTypeList:
        return MaterialPageRoute(builder: (_) => const NearMeListTypePage());
      case welcomePage:
        return MaterialPageRoute(builder: (_) => WelcomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case nearMe:
        final type = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => NearMePage(type: type));
      case news:
        return MaterialPageRoute(builder: (_) => const NewsListPage());
      case newsDetail:
        final data = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => NewsDetailPage(id: data['id'], type: data['type']),
        );
      default:
        return MaterialPageRoute(builder: (_) => const _InvalidRoute());
    }
  }
}

class _InvalidRoute extends StatelessWidget {
  const _InvalidRoute();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Text(
          'INVALID ROUTE',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
