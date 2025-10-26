import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/firebase.dart';
import 'package:rakhsa/injection.dart';
import 'package:rakhsa/main.dart';
import 'package:rakhsa/misc/client/dio_client.dart';
import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/modules/auth/page/welcome_page.dart';
import 'package:rakhsa/modules/dashboard/presentation/pages/dashboard.dart';
import 'package:rakhsa/modules/on_boarding/page/on_boarding_page.dart';
import 'package:rakhsa/routes/routes_navigation.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> with WidgetsBindingObserver {
  late FirebaseProvider firebaseProvider;
  final _client = locator<DioClient>();

  Widget home = const SizedBox();

  bool isResumedProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    firebaseProvider = context.read<FirebaseProvider>();

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Future<Widget> getInitPage() async {
    final res = await _client.get(endpoint: "/admin/toggle/feature");
    if (res.data["feature_onboarding"] == true) {
      final showOnBoarding = !StorageHelper.containsOnBoardingKey();
      if (showOnBoarding) return OnBoardingPage();
    }
    return const WelcomePage();
  }

  Future<void> getData() async {
    final isLoggedIn = await StorageHelper.isLoggedIn();
    Widget initPage = await getInitPage();

    if (isLoggedIn) {
      if (mounted) {
        setState(() => home = DashboardScreen());
      }
    } else {
      if (mounted) {
        setState(() => home = initPage);
      }
    }

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
      home: home,
    );
  }
}
