import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:soundpool/soundpool.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/helpers/storage.dart';

class NotificationType {
  static const resolvedSos = "resolved-sos";
  static const closedSos = "closed-sos";
  static const confirmSos = "confirm-sos";
  static const ews = "ews";
}

Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  return;
}

class FirebaseProvider with ChangeNotifier {
  final Dio dio;

  FirebaseProvider({required this.dio});

  final Soundpool soundpool = Soundpool.fromOptions(options: SoundpoolOptions.kDefault);

  Future<void> initFcm() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
        await dio.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/fcm", data: {
          "user_id": StorageHelper.getUserId(),
          "token": token,
        },
      );
    } catch (e) {
      debugPrint("Error initializing FCM: $e");
    }
  }

  static Future<void> registerBackgroundHandler() async {
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);
  }

  Future<void> setupInteractedMessage(BuildContext context) async {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        handleMessage(context, message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(context, message);
    });
  }

  void listenNotification(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      try {
        // await playNotificationSound();
        processMessage(context, message.data);
        showNotification(message.notification, message.data);
      } catch (e) {
        debugPrint("Error processing notification: $e");
      }
    });
  }

  Future<void> playNotificationSound() async {
    try {
      int soundId = await rootBundle.load("assets/sounds/notification.mp3").then((ByteData soundData) {
        return soundpool.load(soundData);
      });
      await soundpool.play(soundId);
    } catch (e) {
      debugPrint("Error playing notification sound: $e");
    }
  }

  void processMessage(BuildContext context, Map<String, dynamic> payload) {
    switch (payload["type"]) {
      case NotificationType.resolvedSos:
        handleResolvedSos(context, payload);
      break;
      case NotificationType.closedSos:
        handleClosedSos(context, payload);
      break;
      case NotificationType.confirmSos:
        handleConfirmSos(context, payload);
      break;
      default:
        debugPrint("Unhandled notification type: ${payload["type"]}");
    }
  }

  void handleResolvedSos(BuildContext context, Map<String, dynamic> payload) {
    Future.microtask(() {
      context.read<ProfileNotifier>().getProfile();
    });
  }

  void handleClosedSos(BuildContext context, Map<String, dynamic> payload) {
    Future.microtask(() {
      context.read<ProfileNotifier>().getProfile();
    });
  }

  void handleConfirmSos(BuildContext context, Map<String, dynamic> payload) {
    Future.microtask(() {
      var messageNotifier = context.read<GetMessagesNotifier>();
      context.read<ProfileNotifier>().getProfile();
      context.read<SosNotifier>().stopTimer();
      
      messageNotifier.resetTimer();
      messageNotifier.startTimer();
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    processMessage(context, message.data);
  }

  Future<void> showNotification(RemoteNotification? notification, Map<String, dynamic> payload) async {
    if (notification != null) {      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          payload: {
            "type": payload["type"].toString(),
            "news_id": payload["news_id"].toString(),
            "chat_id": payload["chat_id"].toString(),
            "recipient_id": payload["recipient_id"].toString(),
            "sos_id": payload["sos_id"].toString()
          },
          id: Random().nextInt(100),
          channelKey: 'notification',
          title: notification.title,
          body: notification.body,
        ),
      );
    }
  }
}
