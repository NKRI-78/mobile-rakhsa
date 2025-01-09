import 'package:flutter/material.dart';
import 'package:rakhsa/features/event/persentation/pages/list.dart';
import 'package:rakhsa/features/information/presentation/pages/list.dart';
import 'package:rakhsa/features/news/persentation/pages/list.dart';

class RoutesNavigation {
  RoutesNavigation._();
 
  static const initialRoute = '/';
  static const mart = '/mart';
  static const nearMe = '/near-me';
  static const information = '/information';
  static const news = '/news';
  static const itinerary = '/itinerary';
 
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case information:
        return MaterialPageRoute(builder: (_) => const InformationListPage());
      case news:
        return MaterialPageRoute(builder: (_) => const NewsListPage());
      case itinerary:
        return MaterialPageRoute(builder: (_) => const EventListPage());
      default:
        return MaterialPageRoute(builder: (context) => const _InvalidRoute());
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