import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/chat/presentation/pages/chat.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/features/news/persentation/pages/detail.dart';
import 'package:rakhsa/global.dart';

// import 'package:rxdart/rxdart.dart';

class NotificationType {
  static const resolvedSos = "resolved-sos";
  static const closedSos = "closed-sos";
  static const confirmSos = "confirm-sos";
  static const ews = "ews";
  static const chat = "chat";
}


Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  if (message.notification != null) {}
  return;
}

class FirebaseProvider with ChangeNotifier {
  final Dio dio;

  // static final onNotifications = BehaviorSubject<RemoteMessage>();

  FirebaseProvider({required this.dio});

  // final Soundpool soundpool = Soundpool.fromOptions(options: SoundpoolOptions.kDefault);

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
  Future<void> setupInteractedMessage(BuildContext context) async {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        handleMessage(context, message);
      }
    });

    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(context, message);
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

  // Future<void> playNotificationSound() async {
  //   try {
  //     int soundId = await rootBundle.load("assets/sounds/notification.mp3").then((ByteData soundData) {
  //       return soundpool.load(soundData);
  //     });
  //     await soundpool.play(soundId);
  //   } catch (e) {
  //     debugPrint("Error playing notification sound: $e");
  //   }
  // }
  
  void handleMessage(BuildContext context, RemoteMessage message) {
    processMessage(context, message);
  }

  void processMessage(BuildContext context, RemoteMessage message) {
    switch (message.data["type"]) {
      case NotificationType.resolvedSos:
        handleResolvedSos(context, message.data);
      break;
      case NotificationType.closedSos:
        handleClosedSos(context, message.data);
      break;
      case NotificationType.confirmSos:
        handleConfirmSos(context, message.data);
      break;
      case NotificationType.ews:
        String newsId = message.data["news_id"] ?? "0";
        
        Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (BuildContext context) =>  
          NewsDetailPage(
            id: int.parse(newsId),
            type: "ews",
          )
        ));
      break;
      case NotificationType.chat:
        String chatId =  message.data["chat_id"] ?? "-";
        String recipientId = message.data["recipient_id"] ?? "-";
        String sosId = message.data["sos_id"] ?? "-";

        Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (BuildContext context) =>  
          ChatPage(
            chatId: chatId,
            recipientId: recipientId,
            sosId: sosId,
            status: "NONE",
            autoGreetings: false,
          )
        ));
      break;
      default:
        debugPrint("Unhandled notification type: ${message.data["type"]}");
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
