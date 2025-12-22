import 'dart:async';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/core/debug/logger.dart';
import 'package:rakhsa/service/app/config/remote_config_service.dart';
import 'package:rakhsa/service/haptic/haptic_service.dart';

import 'package:rakhsa/service/notification/notification_manager.dart';
import 'package:rakhsa/build_config.dart';

import 'package:rakhsa/firebase_options.dart';

import 'package:rakhsa/injection.dart' as di;
import 'package:rakhsa/service/notification/notification_sound.dart';

import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/service/sos/sos_coordinator.dart';

import 'package:rakhsa/service/provider/providers.dart';
import 'package:rakhsa/service/socket/socketio.dart';

import './modules/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageHelper.init();
  await StorageHelper.loadlocalSession();

  await dotenv
      .load(fileName: 'assets/env/.env.stag')
      .then((_) => log("env staging berhasil dimuat", label: "DOT_ENV"))
      .onError((e, st) {
        log("Gagal memuat env stagging = ${e.toString()}", label: "DOT_ENV");
        throw Exception("Gagal memuat env stagging = ${e.toString()}");
      });
  await BuildConfig.initialize(
    flavor: .stag,
    apiBaseUrl: dotenv.env['API_BASE_URL'],
    socketBaseUrl: dotenv.env['SOCKET_BASE_URL'],
  );

  di.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

  await initializeDateFormatting('id_ID', null);

  await NotificationManager().initializeLocalNotification();

  if (Platform.isIOS) {
    await FCMSoundService.instance.initialize();
  }

  await RemoteConfigService.instance.initialize();

  await SosCoordinator().initAndRestore();

  await HapticService.instance.initialize();

  HttpOverrides.global = HttpOverridesConfig();

  runApp(MultiProvider(providers: providers, child: App()));
}
