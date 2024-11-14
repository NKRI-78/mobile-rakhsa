import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/chat/presentation/pages/chat.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_chats_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';

import 'package:rakhsa/global.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketsService extends ChangeNotifier {

  final GetChatsNotifier chatsNotifier;
  final GetMessagesNotifier messageNotifier;

  int maxReconnectAttempts = 5;
  int reconnectAttempts = 0;

  WebSocketChannel? channel;
  StreamSubscription? channelSubscription;
  Timer? reconnectTimer;
  ValueNotifier<bool> isConnected = ValueNotifier(false); 

  WebSocketsService({
    required this.chatsNotifier,
    required this.messageNotifier
  }) {
    connect();
  }

  Future<void> connect() async {
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

      await join();

      isConnected.value = true; 
      reconnectAttempts = 0; 
      debugPrint("Connected to socket.");
    } catch (e) {
      debugPrint("Connection error: $e");
      handleDisconnect();
    }
  }

  Future<void> join() async {
    final userId = await StorageHelper.getUserId();

    channel?.sink.add(jsonEncode({
      "type": "join",
      "user_id": userId
    }));
  }

  Future<void> sos({
    required String location,
    required String country,
    required String media,
    required String ext,
    required String lat, 
    required String lng,
    required String time
  }) async {
    final userId = await StorageHelper.getUserId();
    
    channel?.sink.add(jsonEncode({
      "type": "sos",
      "user_id": userId,
      "location": location,
      "media": media,
      "ext": ext,
      "lat": lat, 
      "lng": lng,
      "country": country,
      "time": time,
    }));
  }

  Future<void> sendMessage({
    required String chatId,
    required String recipientId, 
    required String message
  }) async {
    final userId = await StorageHelper.getUserId();

    channel?.sink.add(jsonEncode({
      "type": "message",
      "sender": userId,
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

        Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) {
          return ChatPage(
            chatId: chatId, 
            recipientId: recipientId
          );
        })).then((_) {
          chatsNotifier.getChats();
        });
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
