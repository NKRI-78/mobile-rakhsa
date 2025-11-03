import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:awesome_notifications/awesome_notifications.dart' as an;

import 'package:rakhsa/awesome_notification.dart';
import 'package:rakhsa/build_config.dart';

import 'package:rakhsa/firebase.dart';
import 'package:rakhsa/firebase_options.dart';
import 'package:rakhsa/http_overrides.dart';

import 'package:rakhsa/injection.dart' as di;

import 'package:rakhsa/misc/helpers/storage.dart';

import 'package:rakhsa/providers.dart';

import './modules/app/app.dart' as app;

// late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/env/.env.stag').onError((e, st) {
    debugPrint("Gagal memuat env stagging = ${e.toString()}");
    throw Exception(e.toString());
  });
  BuildConfig.init(
    flavor: Flavor.stag,
    appName: dotenv.env['APP_NAME'] ?? 'Marlinda Stag',
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await initializeDateFormatting('id_ID', null);

  if (Platform.isIOS) {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        );
  }

  await an.AwesomeNotifications()
      .initialize('resource://drawable/ic_notification', [
        an.NotificationChannel(
          channelKey: 'notification',
          channelName: 'notification',
          channelDescription: 'Notification',
          playSound: true,
          channelShowBadge: true,
          criticalAlerts: true,
          importance: an.NotificationImportance.High,
        ),
      ], debug: false);

  an.AwesomeNotifications().getInitialNotificationAction().then((
    receivedAction,
  ) {
    if (receivedAction != null) {
      AwesomeNotificationService.onActionReceivedMethod(receivedAction);
      AwesomeNotificationService.onDismissAction(receivedAction);
    }
  });

  await StorageHelper.init();

  di.init();

  // cameras = await availableCameras();

  HttpOverridesSetup.stup();

  runApp(MultiProvider(providers: providers, child: app.App()));
}
