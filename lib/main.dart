import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/features/auth/presentation/pages/login.dart';
import 'package:rakhsa/features/auth/presentation/pages/profile.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';

// import 'package:rakhsa/features/auth/presentation/pages/login.dart';

import 'package:rakhsa/global.dart';

import 'package:rakhsa/injection.dart' as di;

import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageHelper.init();

  di.init();

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  Widget home = const SizedBox();

  Future<void> getData() async {
    bool? isLoggedIn = await StorageHelper.isLoggedIn();
    
    if(isLoggedIn != null) {

      if(isLoggedIn) {
        if(mounted) {
          setState(() => home = const DashboardScreen()); 
        }
      } else {
        if(mounted) {
          setState(() => home = const LoginPage()); 
        }
      }

    } else {

      if(mounted) {
        setState(() => home = const LoginPage()); 
      }

    }
  }

  @override 
  void initState() {
    super.initState();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldKey,
      navigatorKey: navigatorKey,
      title: 'Home',
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}
