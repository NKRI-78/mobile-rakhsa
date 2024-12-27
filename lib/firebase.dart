import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';

import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

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

      Map<String, dynamic> payload = message.data;
      
      int soundId = await rootBundle.load("assets/sounds/notification.mp3").then((ByteData soundData) {
        return soundpool.load(soundData);
      });
      
      await soundpool.play(soundId);
      
      if(payload["type"] == "resolved-sos") {
        String msg = payload["message"].toString();

        Future.delayed(Duration.zero, () {
          context.read<ProfileNotifier>().getProfile();

          GeneralModal.infoResolvedSos(msg: msg);
        });
      }

      if(payload["type"] == "closed-sos") {
        String msg = payload["message"].toString();

        Future.delayed(Duration.zero, () {
          context.read<ProfileNotifier>().getProfile();

          context.read<GetMessagesNotifier>().setStateIsCaseClosed(true);
          context.read<GetMessagesNotifier>().setStateNote(val: msg);
        });
      }

      if(payload["type"] == "confirm-sos") {
        String chatId = payload["chat_id"].toString();
        String recipientId = payload["recipient_id"].toString();
        String sosId = payload["sos_id"].toString();

        Future.delayed(Duration.zero, () {
          context.read<GetMessagesNotifier>().navigateToChat(
            chatId: chatId, 
            status: "NONE",
            recipientId: recipientId, 
            sosId: sosId,
          );

          context.read<ProfileNotifier>().getProfile();
          
          context.read<SosNotifier>().stopTimer();

          context.read<GetMessagesNotifier>().resetTimer();
          context.read<GetMessagesNotifier>().startTimer();
        });
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: Random().nextInt(100),
          channelKey: 'notification',
          title: notification.title,
          body: notification.body,
        ),
      );
    });
  }

}