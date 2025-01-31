import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';
import 'package:rakhsa/features/news/persentation/pages/detail.dart';

import 'package:rakhsa/global.dart';

class NotificationType {
  static const resolvedSos = "resolved-sos";
  static const closedSos = "closed-sos";
  static const confirmSos = "confirm-sos";
  static const ews = "ews";
  static const news = "news";
  static const chat = "chat";
  static const historyUser = "history-user";
}

@pragma('vm:entry-point') // add this for production
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // debugPrint("=== INCOMING BACKGROUND MESSAGE ===");
  // final sharedPreferences = await SharedPreferences.getInstance();

  // Position position = await Geolocator.getCurrentPosition(
  //   desiredAccuracy: LocationAccuracy.best,
  //   forceAndroidLocationManager: true,
  // );

  // final lat = position.latitude;
  // final lng = position.longitude;

  // List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
  // String country = placemarks[0].country ?? "-";
  // String street = placemarks[0].street ?? "-";
  // String administrativeArea = placemarks[0].administrativeArea ?? "-";
  // String subadministrativeArea = placemarks[0].subAdministrativeArea ?? "-"; 

  // String address = "$administrativeArea $subadministrativeArea\n$street, $country";

  // save to db
  // if(sharedPreferences.getString("user_id") != null) {
  //   await Dio().post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile/insert-user-track",
  //     data: {
  //       "user_id": sharedPreferences.getString("user_id"),
  //       "address": address,
  //       "lat": lat,
  //       "lng": lng
  //     }
  //   );
  // }
}

class FirebaseProvider with ChangeNotifier {
  final Dio dio;

  FirebaseProvider({required this.dio});

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
      case NotificationType.news: 
        String newsId = message.data["news_id"] ?? "0";
        
        Navigator.pushNamed(context, RoutesNavigation.news, 
          arguments: {
            "id": int.parse(newsId),
            "type": "news"
          }
        );
      break;  
      case NotificationType.ews:
        String newsId = message.data["news_id"] ?? "0";
        
        Navigator.pushNamed(context, RoutesNavigation.news, 
          arguments: {
            "id": int.parse(newsId),
            "type": "ews"
          }
        );
      break;
      case NotificationType.chat:
        String chatId =  message.data["chat_id"] ?? "-";
        String recipientId = message.data["recipient_id"] ?? "-";
        String sosId = message.data["sos_id"] ?? "-";

        Navigator.pushNamed(context, RoutesNavigation.chat, 
          arguments: {
            "chat_id": chatId,
            "recipient_id": recipientId,
            "status": "NONE",
            "sos_id": sosId,
            "auto_greetings": false
          }
        );
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
