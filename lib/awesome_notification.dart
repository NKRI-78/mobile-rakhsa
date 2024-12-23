import 'package:awesome_notifications/awesome_notifications.dart';

class AwesomeNotificationController {

  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {

    // String chatId = receivedAction.payload!["chat_id"] ?? "-";
    // String sender = receivedAction.payload!["sender"] ?? "-";
    // String recipient = receivedAction.payload!["recipient"] ?? "-";

  }

  static Future<void> onNotificationCreated(ReceivedNotification receivedNotification) async {


  }

  static Future<void> onNotificationDisplay(ReceivedNotification receivedNotification) async {


  }

  static Future<void> onDismissAction(ReceivedNotification receivedNotification) async {

  }
 
}