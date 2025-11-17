import 'dart:async';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/notification_manager.dart';
import 'package:rakhsa/build_config.dart';

import 'package:rakhsa/firebase_options.dart';

import 'package:rakhsa/injection.dart' as di;

import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/repositories/sos/sos_coordinator.dart';

import 'package:rakhsa/providers.dart';
import 'package:rakhsa/socketio.dart';

import './modules/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageHelper.init();

  await dotenv
      .load(fileName: 'assets/env/.env.prod')
      .then((_) => debugPrint("env production berhasil dimuat"))
      .onError((e, st) {
        debugPrint("Gagal memuat env production = ${e.toString()}");
        throw Exception("Gagal memuat env production = ${e.toString()}");
      });
  await BuildConfig.initialize(
    flavor: Flavor.prod,
    apiBaseUrl: dotenv.env['API_BASE_URL'],
    socketBaseUrl: dotenv.env['SOCKET_BASE_URL'],
  );

  di.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

  await initializeDateFormatting('id_ID', null);

  await NotificationManager().initializeLocalNotification();

  await SosCoordinator().initAndRestore();

  HttpOverrides.global = HttpOverridesConfig();

  runApp(MultiProvider(providers: providers, child: App()));
}
