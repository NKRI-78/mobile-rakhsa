import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';
import 'package:rakhsa/global.dart';
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
}

Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  final Soundpool soundpool = Soundpool.fromOptions(options: SoundpoolOptions.kDefault);
  try {
    int soundId = await rootBundle.load("assets/sounds/notification.mp3").then((ByteData soundData) {
      return soundpool.load(soundData);
    });
    await soundpool.play(soundId);
  } catch (e) {
    debugPrint("Error playing notification sound: $e");
  }
  if (message.notification != null) {
    
  }
  return;
}

class FirebaseProvider with ChangeNotifier {
  final Dio dio;

  FirebaseProvider({required this.dio});

  final Soundpool _soundpool = Soundpool.fromOptions(options: SoundpoolOptions.kDefault);

  Future<void> initFcm() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      await dio.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/fcm",
        data: {
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
        _handleMessage(context, message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(context, message);
    });
  }

  void listenNotification(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      try {
        await _playNotificationSound();
        _processMessage(context, message.data);
        _showNotification(message.notification);
      } catch (e) {
        debugPrint("Error processing notification: $e");
      }
    });
  }

  Future<void> _playNotificationSound() async {
    try {
      int soundId = await rootBundle.load("assets/sounds/notification.mp3").then((ByteData soundData) {
        return _soundpool.load(soundData);
      });
      await _soundpool.play(soundId);
    } catch (e) {
      debugPrint("Error playing notification sound: $e");
    }
  }

  void _processMessage(BuildContext context, Map<String, dynamic> payload) {
    switch (payload["type"]) {
      case NotificationType.resolvedSos:
        _handleResolvedSos(context, payload);
        break;
      case NotificationType.closedSos:
        _handleClosedSos(context, payload);
        break;
      case NotificationType.confirmSos:
        _handleConfirmSos(context, payload);
        break;
      default:
        debugPrint("Unhandled notification type: ${payload["type"]}");
    }
  }

  void _handleResolvedSos(BuildContext context, Map<String, dynamic> payload) {
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushAndRemoveUntil(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) => const DashboardScreen(index: 0)), (route) => false);
    }); 
  }

  void _handleClosedSos(BuildContext context, Map<String, dynamic> payload) {
    String msg = payload["message"].toString();
    Future.microtask(() {
      context.read<ProfileNotifier>().getProfile();
      var messageNotifier = context.read<GetMessagesNotifier>();
      messageNotifier.setStateNote(val: msg);
    });
  }

  void _handleConfirmSos(BuildContext context, Map<String, dynamic> payload) {
    Future.microtask(() {
      var messageNotifier = context.read<GetMessagesNotifier>();
      messageNotifier.navigateToChat(
        chatId: payload["chat_id"].toString(),
        status: "NONE",
        recipientId: payload["recipient_id"].toString(),
        sosId: payload["sos_id"].toString(),
      );
      context.read<ProfileNotifier>().getProfile();
      context.read<SosNotifier>().stopTimer();
      messageNotifier.resetTimer();
      messageNotifier.startTimer();
    });
  }

  Future<void> _showNotification(RemoteNotification? notification) async {
    if (notification != null) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: Random().nextInt(100),
          channelKey: 'notification',
          title: notification.title,
          body: notification.body,
        ),
      );
    }
  }

  void _handleMessage(BuildContext context, RemoteMessage message) {
    _processMessage(context, message.data);
  }
}
