import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:flutter/material.dart';

import 'package:rakhsa/features/chat/presentation/pages/chat.dart';
import 'package:rakhsa/features/news/persentation/pages/detail.dart';

import 'package:rakhsa/global.dart';

class AwesomeNotificationService {

  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // TYPE
    String type = receivedAction.payload!["type"] ?? "-";

    // NEWS ID
    String newsId = receivedAction.payload!["news_id"] ?? "0";

    String chatId = receivedAction.payload!["chat_id"] ?? "-";
    String recipientId = receivedAction.payload!["recipient_id"] ?? "-";
    String sosId = receivedAction.payload!["sos_id"] ?? "-";

    // CHAT
    if(type == "chat") {
      Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (BuildContext context) =>  
        ChatPage(
          chatId: chatId,
          recipientId: recipientId,
          sosId: sosId,
          status: "NONE",
          autoGreetings: false,
        )
      ));
    }

    // NEWS 
     if(type == "news") {
      Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (BuildContext context) =>  
        NewsDetailPage(
          id: int.parse(newsId),
          type: "news",
        )
      ));
    }

    // EWS
    if(type == "ews") {
      Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (BuildContext context) =>  
        NewsDetailPage(
          id: int.parse(newsId),
          type: "ews",
        )
      ));
    }
  }

  static Future<void> onNotificationCreated(ReceivedNotification receivedNotification) async {


  }

  static Future<void> onNotificationDisplay(ReceivedNotification receivedNotification) async {


  }

  static Future<void> onDismissAction(ReceivedNotification receivedNotification) async {

  }
 
}