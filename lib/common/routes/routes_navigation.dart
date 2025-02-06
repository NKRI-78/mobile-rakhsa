import 'package:flutter/material.dart';
import 'package:rakhsa/features/auth/presentation/pages/login.dart';
import 'package:rakhsa/features/auth/presentation/pages/login_fr.dart';
import 'package:rakhsa/features/auth/presentation/pages/register_fr.dart';
import 'package:rakhsa/features/auth/presentation/pages/scan_register_passport_page.dart';
import 'package:rakhsa/features/auth/presentation/pages/welcome_page.dart';
import 'package:rakhsa/features/chat/presentation/pages/chat.dart';
import 'package:rakhsa/features/chat/presentation/pages/chats.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/weather_page.dart';
import 'package:rakhsa/features/document/presentation/pages/passport_document_page.dart';
import 'package:rakhsa/features/document/presentation/pages/visa_document_page.dart';
import 'package:rakhsa/features/event/persentation/pages/create.dart';
import 'package:rakhsa/features/event/persentation/pages/list.dart';
import 'package:rakhsa/features/information/presentation/pages/list.dart';
import 'package:rakhsa/features/nearme/presentation/pages/near_me_page.dart';
import 'package:rakhsa/features/nearme/presentation/pages/near_me_page_list_type.dart';
import 'package:rakhsa/features/news/persentation/pages/detail.dart';
import 'package:rakhsa/features/news/persentation/pages/list.dart';
import 'package:rakhsa/views/screens/ecommerce/product/products.dart';

class RoutesNavigation {
  RoutesNavigation._();

  static const dashboard = '/dashboard';
  static const mart = '/mart';
  static const nearMe = '/near-me';
  static const welcomePage = '/welcome';
  // static const register = '/register';
  static const weather = '/weather';
  static const chats = '/chats';
  static const chat = '/chat';
  static const loginFr = '/login-fr';
  static const login = '/login';
  static const registerFr = '/register-fr';
  // static const registerPassport = '/register-passport';
  static const registerPassport = '/register-passport';
  static const nearMeTypeList = '/near-me-type-list';
  static const information = '/information';
  static const news = '/news';
  static const newsDetail = '/news-detail';
  static const visaDocument = '/visa-document';
  static const passportDocument = '/passport-document';
  static const deviceNotSupport = '/device-not-support';

  static const itinerary = '/itinerary';
  static const itineraryCreate = '/itinerary/create';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard: 
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case deviceNotSupport: 
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case mart: 
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      // case register: 
      //   return MaterialPageRoute(builder: (_) => const RegisterPage());
      // case registerPassport: 
      //   return MaterialPageRoute(builder: (_) => const RegisterPassportPage());
      case registerPassport: 
        return MaterialPageRoute(builder: (_) => const ScanRegisterPassportPage());
      case information:
        return MaterialPageRoute(builder: (_) => const InformationListPage());
      case weather:
        final data = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => WeatherPage(data));
      case chats: 
        return MaterialPageRoute(builder: (_) => const ChatsPage());
      case chat: 
        final data = settings.arguments as Map<String, dynamic>;
        bool autoGreetings = data["auto_greetings"];
        String chatId = data["chat_id"];
        String sosId = data["sos_id"];
        String recipientId = data["recipient_id"];
        String status = data["status"];

        return MaterialPageRoute(builder: (_) => ChatPage(
          autoGreetings: autoGreetings,
          chatId: chatId,
          recipientId: recipientId,
          sosId: sosId,
          status: status,
        ));
      case nearMeTypeList:
        return MaterialPageRoute(builder: (_) => const NearMeListTypePage());
      case visaDocument: 
        return MaterialPageRoute(builder: (_) => const VisaDocumentPage());
      case welcomePage: 
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case passportDocument: 
        return MaterialPageRoute(builder: (_) => const PassportDocumentPage());
      case loginFr: 
        return MaterialPageRoute(builder: (_) => const LoginFrPage(fromHome: false));
      case login: 
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case registerFr: 
        final data = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => RegisterFrPage(
          userId: data["user_id"],  
          passportPic: data["passport_pic"],
          passport: data["passport"]
        ));
      case nearMe:
        final type = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => NearMePage(type: type));
      case news:
        return MaterialPageRoute(builder: (_) => const NewsListPage());
      case newsDetail:
        final data = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => NewsDetailPage(
          id: data['id'],
          type: data['type'],
        ));
      case itinerary:
        return MaterialPageRoute(builder: (_) => const EventListPage());
      case itineraryCreate:
        return MaterialPageRoute(builder: (_) => const EventCreatePage());
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
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}