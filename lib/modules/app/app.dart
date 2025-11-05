import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/firebase.dart';
import 'package:rakhsa/routes/nav_key.dart';
import 'package:rakhsa/routes/routes_navigation.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  late FirebaseProvider firebaseProvider;

  @override
  void initState() {
    super.initState();
    firebaseProvider = context.read<FirebaseProvider>();
    _setup();
  }

  void _setup() async {
    if (!mounted) return;
    await firebaseProvider.setupInteractedMessage(context);

    if (!mounted) return;
    firebaseProvider.listenNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldKey,
      navigatorKey: navigatorKey,
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RoutesNavigation.onGenerateRoute,
      initialRoute: RoutesNavigation.splash,
    );
  }
}
