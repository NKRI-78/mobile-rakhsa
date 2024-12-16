import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/chat/presentation/pages/chat.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';

import 'package:rakhsa/global.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketsService extends ChangeNotifier {

  final GetMessagesNotifier getMessagesNotifier;

  Timer? pingTimer;
  Timer? pongTimeoutTimer;
  bool isPongReceived = true;

  int maxReconnectAttempts = 5;
  int reconnectAttempts = 0;

  WebSocketChannel? channel;
  StreamSubscription? channelSubscription;
  Timer? reconnectTimer;
  ValueNotifier<bool> isConnected = ValueNotifier(false); 

  WebSocketsService({
    required this.getMessagesNotifier
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

      startPing();

      join();

      isConnected.value = true; 
      reconnectAttempts = 0; 
      debugPrint("Connected to socket.");
    } catch (e) {
      debugPrint("Connection error: $e");
      handleDisconnect();
    }
  }

  void startPing() {
    pingTimer?.cancel();

    pingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!isPongReceived) {
        debugPrint('No pong response, disconnecting...');
        handleDisconnect();
      } else {
        isPongReceived = false;
        sendPing();
        startPongTimeout();
      }
    });
  }

  void startPongTimeout() {
    pongTimeoutTimer?.cancel();

    pongTimeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!isPongReceived) {
        debugPrint('Pong timeout reached, disconnecting...');
        handleDisconnect();
      }
    });
  }

  void sendPing() {
    final pingMessage = jsonEncode({"type": "ping"});

    channel?.sink.add(pingMessage);
    debugPrint('Ping sent to server');
  }

  void userFinishSos({required String sosId}) {

    channel?.sink.add(jsonEncode({
      "type": "user-finish-sos",
      "sos_id": sosId
    }));
  }

  void join() {
    final userId = StorageHelper.getUserId();

    channel?.sink.add(jsonEncode({
      "type": "join",
      "user_id": userId
    }));
  }

  void leave() {
    final userId = StorageHelper.getUserId();

    channel?.sink.add(jsonEncode({
      "type": "leave",
      "user_id": userId
    }));
  }

  void sos({
    required String sosId,
    required String location,
    required String country,
    required String media,
    required String ext,
    required String lat, 
    required String lng,
    required String time
  }) async {
    final userId = StorageHelper.getUserId();
    
    channel?.sink.add(jsonEncode({
      "sos_id": sosId,
      "type": "sos",
      "user_id": userId,
      "location": location,
      "media": media,
      "ext": ext,
      "lat": lat, 
      "lng": lng,
      "country": country,
      "time": time,
      "platform_type": "raksha"
    }));
  }

  void sendMessage({
    required String chatId,
    required String recipientId, 
    required String message
  }) {
    final userId = StorageHelper.getUserId();

    channel?.sink.add(jsonEncode({
      "type": "message",
      "sender": userId,
      "chat_id": chatId,
      "recipient": recipientId,
      "text": message
    }));
  }

  void userResolvedSos({
    required String sosId,
  }) {

    channel?.sink.add(jsonEncode({
      "type": "user-resolved-sos",
      "sos_id": sosId 
    }));
  }

  void onMessageReceived(Map<String, dynamic> message) {

    String? userId = StorageHelper.getUserId();

    if(message["type"] == "fetch-message-${getMessagesNotifier.activeChatId}") {
      debugPrint("=== FETCH MESSAGE ===");
      getMessagesNotifier.appendMessage(data: message);
    }

    if(message["type"] == "confirm-sos-${userId.toString()}") {
      
      debugPrint("=== CONFIRM SOS ===");

      String chatId = message["chat_id"];
      String recipientId = message["recipient_id"];
      String sosId = message["sos_id"];
      String status = message["status"];
   
      Future.delayed(const Duration(milliseconds: 1000), () {
        navigatorKey.currentContext!.read<SosNotifier>().stopTimer();
      });

      getMessagesNotifier.resetTimer();
      getMessagesNotifier.startTimer();

      Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) {
        return ChatPage(
          chatId: chatId, 
          status: status,
          recipientId: recipientId,
          sosId: sosId,
          autoGreetings: true
        );
      }));
    }

    switch (message["type"]) {

      case "pong":
        isPongReceived = true;
        debugPrint('Pong received from server');
      break;

      case "expire-sos": 
        debugPrint("=== EXPIRE SOS ===");
      break;
      
      case "finish-sos": 
        debugPrint("=== FINISH SOS ===");
        getMessagesNotifier.showBtnSessionEnd();
      break;

      default:
        break;
    }

    Future.delayed(Duration.zero, () =>  notifyListeners());
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
