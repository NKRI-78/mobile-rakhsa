import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';

import 'package:rakhsa/features/chat/presentation/pages/chat.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';

import 'package:rakhsa/global.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketsService extends ChangeNotifier {

  final GetMessagesNotifier messageNotifier;

  int maxReconnectAttempts = 5;
  int reconnectAttempts = 0;

  WebSocketChannel? channel;
  StreamSubscription? channelSubscription;
  Timer? reconnectTimer;
  ValueNotifier<bool> isConnected = ValueNotifier(false); 

  WebSocketsService({
    required this.messageNotifier
  }) {
    connect();
  }

  void connect() {
    try {
      disposeChannel();

      channel = WebSocketChannel.connect(Uri.parse(RemoteDataSourceConsts.websocketUrlProd));

      channelSubscription = channel!.stream.listen(
        (message) async {
          final data = jsonDecode(message);
          onMessageReceived(data);
        },
        onDone: () => handleDisconnect(),
        onError: (error) => handleError(error),
      );

      join();

      isConnected.value = true; 
      reconnectAttempts = 0; 
      debugPrint("Connected to socket.");
    } catch (e) {
      debugPrint("Connection error: $e");
      handleDisconnect();
    }
  }

  void join() {
    channel?.sink.add(jsonEncode({
      "type": "join",
      "user_id": "64cdba1f-01ca-464d-a7d4-5c109de0a251"
    }));
  }

  void sos({
    required String location,
    required String country,
    required String lat, 
    required String lng,
    required String time
  }) {
    channel?.sink.add(jsonEncode({
      "type": "sos",
      "user_id": "64cdba1f-01ca-464d-a7d4-5c109de0a251",
      "location": location,
      "lat": lat, 
      "lng": lng,
      "country": country,
      "time": time,
    }));
  }

  void sendMessage({
    required String chatId,
    required String recipientId, 
    required String message
  }) {
    channel?.sink.add(jsonEncode({
      "type": "message",
      "sender": "64cdba1f-01ca-464d-a7d4-5c109de0a251",
      "chat_id": chatId,
      "recipient": recipientId,
      "text": message
    }));
  }

  void onMessageReceived(Map<String, dynamic> message) {

    switch (message["type"]) {
      
      case "confirm-sos":
        String chatId = message["chat_id"];
        String recipientId = message["recipient_id"];

        debugPrint(chatId);
        debugPrint(recipientId);

        Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) {
          return ChatPage(
            chatId: chatId, 
            recipientId: recipientId
          );
        }));
      break;

      case "message":
        messageNotifier.appendMessage(data: message);
      break;

      default:
        break;
    }

    notifyListeners();
  }

  void handleDisconnect() {
    isConnected.value = false;

    if (reconnectAttempts < maxReconnectAttempts) {
      reconnectAttempts++;
      final reconnectDelay = Duration(seconds: 2 * reconnectAttempts);
      reconnectTimer = Timer(reconnectDelay, () {
        connect();
      });
    } else {
      debugPrint("Max reconnection attempts reached. Could not reconnect.");
    }
  }

  void disposeChannel() {
    if (channelSubscription != null) {
      channelSubscription?.cancel();
      channelSubscription = null;
    }

    if (channel != null) {
      channel?.sink.close(); 
      channel = null; 
    }
  }

  void handleError(dynamic error) {
    debugPrint("WebSocket Error: $error");
    handleDisconnect();
  }

  @override
  void dispose() {
    reconnectTimer?.cancel();
    disposeChannel(); 
    isConnected.dispose();
    
    super.dispose();
  }
}
