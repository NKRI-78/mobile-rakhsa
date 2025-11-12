import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/routes/routes_navigation.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _opacity = 0.2;

  final holdDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    // save base url yang nanti digunakan untuk di background service
    _presistBaseUrlFromEnv();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _opacity = 1.0);
    });
    Future.delayed(holdDuration).then((_) async {
      final showOnBoarding = !StorageHelper.containsKey("on_boarding_key");
      if (showOnBoarding) {
        _navigateTo(RoutesNavigation.onBoarding);
      } else {
        final loggedIn = await StorageHelper.isLoggedIn();
        if (loggedIn) {
          _navigateTo(RoutesNavigation.dashboard);
        } else {
          _navigateTo(RoutesNavigation.welcomePage);
        }
      }
    });
  }

  void _navigateTo(String newPath) {
    if (mounted) Navigator.pushNamed(context, newPath);
  }

  void _presistBaseUrlFromEnv() async {
    // fallback string kosong yang nanti bisa dihandle dari bg service
    final baseUrl = BuildConfig.instance.apiBaseUrl ?? "";
    await StorageHelper.write("base_url_cache", baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: holdDuration,
          curve: Curves.easeInOut,
          child: Image.asset(
            "assets/images/logo-marlinda-no-title.png",
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }
}
