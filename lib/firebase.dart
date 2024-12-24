import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:soundpool/soundpool.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/helpers/storage.dart';

class FirebaseProvider with ChangeNotifier {
  final Dio dio;

  FirebaseProvider({
    required this.dio,
  });

  final soundpool = Soundpool.fromOptions(
    options: SoundpoolOptions.kDefault,
  );

  Future<void> setupInteractedMessage(BuildContext context) async {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if(message != null) {
        handleMessage(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(message);
    });
  }

  Future<void> handleMessage(message) async {}

  Future<void> initFcm() async {
    await dio.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/fcm", 
      data: {
        "user_id": StorageHelper.getUserId(),
        "token": await FirebaseMessaging.instance.getToken(),
      }
    );
  }

  void listenNotification(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification notification = message.notification!;
      
      int soundId = await rootBundle.load("assets/sounds/notification.mp3").then((ByteData soundData) {
        return soundpool.load(soundData);
      });
      
      await soundpool.play(soundId);

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: Random().nextInt(100),
          channelKey: 'notification',
          title:  notification.title,
          body: notification.body,
        ),
      );
    });
  }

}