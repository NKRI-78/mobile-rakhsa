import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/injection.dart';

import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/repositories/sos/sos_coordinator.dart';
import 'package:rakhsa/routes/nav_key.dart';
import 'package:rakhsa/routes/routes_navigation.dart';

import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';

class NotificationType {
  static const resolvedSos = "resolved-sos";
  static const closedSos = "closed-sos";
  static const confirmSos = "confirm-sos";
  static const ews = "ews";
  static const news = "news";
  static const chat = "chat";
  static const historyUser = "history-user";
}

@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final data = message.data;
  final type = data['type'];
  if (type == NotificationType.confirmSos) {
    await SosCoordinator.markPendingStopFromBackground();
  }
}

class FirebaseProvider with ChangeNotifier {
  final Dio dio;

  FirebaseProvider({required this.dio});

  Future<void> initFcm() async {
    try {
      final session = await StorageHelper.loadlocalSession();
      String? token = await FirebaseMessaging.instance.getToken();
      debugPrint(
        "Loading initFCM = ${{"uid": session?.user.id ?? "-", "fcm_token": token ?? "-"}}",
      );
      await dio.post(
        "${BuildConfig.instance.apiBaseUrl}/fcm",
        data: {"user_id": session?.user.id, "token": token},
      );
      debugPrint(
        "initFCM Berhasil = ${{"uid": session?.user.id ?? "-", "fcm_token": token ?? "-"}}",
      );
    } catch (e) {
      debugPrint("Error initFCM: $e");
    }
  }

  Future<void> setupInteractedMessage(BuildContext context) async {
    await FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        processMessage(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      processMessage(message);
    });
  }

  void listenNotification(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      try {
        // await playNotificationSound();
        showNotification(message.notification, message.data);
      } catch (e) {
        debugPrint("Error processing notification: $e");
      }
    });
  }

  void processMessage(RemoteMessage message) {
    switch (message.data["type"]) {
      case NotificationType.resolvedSos:
        handleResolvedSos(navigatorKey.currentContext!, message.data);
        break;
      case NotificationType.closedSos:
        handleClosedSos(navigatorKey.currentContext!, message.data);
        break;
      case NotificationType.confirmSos:
        handleConfirmSos(navigatorKey.currentContext!, message.data);
        break;
      case NotificationType.news:
        String newsId = message.data["news_id"] ?? "0";

        Navigator.pushNamed(
          navigatorKey.currentContext!,
          RoutesNavigation.news,
          arguments: {"id": int.parse(newsId), "type": "news"},
        );
        break;
      case NotificationType.ews:
        navigatorKey.currentContext!.read<UserProvider>().getUser();

        Future.delayed(const Duration(seconds: 1), () {
          var lat =
              double.tryParse(
                navigatorKey.currentContext!.read<UserProvider>().user?.lat ??
                    "0",
              ) ??
              0;
          var lng =
              double.tryParse(
                navigatorKey.currentContext!.read<UserProvider>().user?.lng ??
                    "0",
              ) ??
              0;
          var state =
              navigatorKey.currentContext!.read<UserProvider>().user?.state ??
              "Indonesia";

          navigatorKey.currentContext!.read<DashboardNotifier>().getEws(
            lat: lat,
            lng: lng,
            state: state,
          );
        });
        break;
      case NotificationType.chat:
        String chatId = message.data["chat_id"] ?? "-";
        String recipientId = message.data["recipient_id"] ?? "-";
        String sosId = message.data["sos_id"] ?? "-";

        Navigator.pushNamed(
          navigatorKey.currentContext!,
          RoutesNavigation.chat,
          arguments: {
            "chat_id": chatId,
            "recipient_id": recipientId,
            "status": "NONE",
            "sos_id": sosId,
            "auto_greetings": false,
          },
        );
        break;
      default:
        debugPrint("Unhandled notification type: ${message.data["type"]}");
    }
  }

  void handleResolvedSos(BuildContext context, Map<String, dynamic> payload) {
    context.read<UserProvider>().getUser();
  }

  void handleClosedSos(BuildContext context, Map<String, dynamic> payload) {
    context.read<UserProvider>().getUser();
  }

  void handleConfirmSos(BuildContext context, Map<String, dynamic> payload) {
    context.read<UserProvider>().getUser();
    // context.read<SosNotifier>().stopTimer();
    locator<SosCoordinator>().stop(reason: "fcm-opened-app");
  }

  Future<void> showNotification(
    RemoteNotification? notification,
    Map<String, dynamic> payload,
  ) async {
    // fetch realtime when notification without title and description
    if (payload['type'] == 'ews-delete') {
      navigatorKey.currentContext!.read<UserProvider>().getUser();

      var lat =
          double.tryParse(
            navigatorKey.currentContext!.read<UserProvider>().user?.lat ?? "0",
          ) ??
          0;
      var lng =
          double.tryParse(
            navigatorKey.currentContext!.read<UserProvider>().user?.lng ?? "0",
          ) ??
          0;
      var state =
          navigatorKey.currentContext!.read<UserProvider>().user?.state ??
          "Indonesia";

      navigatorKey.currentContext!.read<DashboardNotifier>().getEws(
        lat: lat,
        lng: lng,
        state: state,
      );

      // fetch realtime when notification with title and description
    } else if (payload['type'] == 'ews') {
      navigatorKey.currentContext!.read<UserProvider>().getUser();

      var lat =
          double.tryParse(
            navigatorKey.currentContext!.read<UserProvider>().user?.lat ?? "0",
          ) ??
          0;
      var lng =
          double.tryParse(
            navigatorKey.currentContext!.read<UserProvider>().user?.lng ?? "0",
          ) ??
          0;
      var state =
          navigatorKey.currentContext!.read<UserProvider>().user?.state ??
          "Indonesia";

      navigatorKey.currentContext!.read<DashboardNotifier>().getEws(
        lat: lat,
        lng: lng,
        state: state,
      );
    } else {
      if (notification != null) {
        debugPrint("notifikasi masuk dengan payload = $payload");
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            payload: {
              "type": payload["type"].toString(),
              "news_id": payload["news_id"].toString(),
              "chat_id": payload["chat_id"].toString(),
              "recipient_id": payload["recipient_id"].toString(),
              "sos_id": payload["sos_id"].toString(),
            },
            notificationLayout: NotificationLayout.Default,
            actionType: ActionType.Default,
            id: Random().nextInt(100),
            channelKey: 'notification',
            title: notification.title,
            body: notification.body,
          ),
        );
      }
    }
  }
}
