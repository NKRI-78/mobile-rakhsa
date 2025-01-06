import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:flutter/material.dart';

import 'package:rakhsa/features/chat/presentation/pages/chat.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';
import 'package:rakhsa/global.dart';

class AwesomeNotificationController {

  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    String type = receivedAction.payload!["type"] ?? "-";

    // CHAT
    String chatId = receivedAction.payload!["chat_id"] ?? "-";
    String recipientId = receivedAction.payload!["recipient_id"] ?? "-";
    String sosId = receivedAction.payload!["sos_id"] ?? "-";

    if(type == "chat") {
      Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) =>  
        ChatPage(
          chatId: chatId,
          recipientId: recipientId,
          sosId: sosId,
          status: "NONE",
          autoGreetings: false,
        )
      ));
    }

    // EWS
    if(type == "ews") {
      Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) =>  
        const DashboardScreen()
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