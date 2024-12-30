import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';

import 'package:rakhsa/global.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

enum ConnectionIndicator { red, yellow, green }

class WebSocketsService extends ChangeNotifier {

  WebSocketsService() {
    connect();
  }

  ConnectionIndicator _connectionIndicator = ConnectionIndicator.yellow;
  ConnectionIndicator get connectionIndicator => _connectionIndicator;

  WebSocketChannel? channel;
  StreamSubscription? channelSubscription;
  Timer? reconnectTimer;

  bool isConnected = false;

  void setStateConnectionIndicator(ConnectionIndicator connectionIndicators) {
    _connectionIndicator = connectionIndicators;
    
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void toggleConnection(bool connection) {
    isConnected = connection;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void connect() {
    try {
      channel = WebSocketChannel.connect(Uri.parse(RemoteDataSourceConsts.websocketUrlProd));

      channelSubscription = channel!.stream.listen(
        (message) async {
          debugPrint("=== MESSAGE ${message.toString()} ===");
          setStateConnectionIndicator(ConnectionIndicator.yellow);

          Future.delayed(const Duration(seconds: 1), () {
            setStateConnectionIndicator(ConnectionIndicator.green);
            toggleConnection(true);
          });

          final data = jsonDecode(message);
          onMessageReceived(data);
        },
        onDone: () {
          toggleConnection(false);
          reconnect();
        },
        onError: (error) {
          toggleConnection(false);
          handleError(error);
        },
      );

      join();
      debugPrint("Connected to socket.");
    } catch (e) {
      debugPrint("Connection error: $e");
      reconnect();
    }
  }

  void reconnect() {
    debugPrint("Attempting to reconnect...");

    reconnectTimer?.cancel();

    if (isConnected) {
      debugPrint("Already connected, skipping reconnection.");
      return;
    }

    setStateConnectionIndicator(ConnectionIndicator.red);

    reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (channel == null || !isConnected) {
        connect();
      }
    });
  }

  void handleError(dynamic error) {
    debugPrint("WebSocket Error: $error");
    reconnect();
  }

  void join() {
    final userId = StorageHelper.getUserId();

    channel?.sink.add(jsonEncode({
      "type": "join",
      "user_id": userId,
    }));
  }

  void leave() {
    final userId = StorageHelper.getUserId();

    channel?.sink.add(jsonEncode({
      "type": "leave",
      "user_id": userId,
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
    required String time,
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
      "platform_type": "raksha",
    }));
  }

  void sendMessage({
    required String chatId,
    required String recipientId,
    required String message,
    required DateTime createdAt
  }) {
    final userId = StorageHelper.getUserId();

    channel?.sink.add(jsonEncode({
      "type": "message",
      "chat_id": chatId,
      "sender": userId,
      "recipient": recipientId,
      "text": message,
      "created_at": DateFormat('yyyy-MM-dd hh:mm:ss').format(createdAt)
    }));
  }

  void userResolvedSos({
    required String sosId,
  }) {
    channel?.sink.add(jsonEncode({
      "type": "user-resolved-sos",
      "sos_id": sosId,
    }));
  }

  void onMessageReceived(Map<String, dynamic> message) {

    if (message["type"] == "fetch-message") {
      debugPrint("=== FETCH MESSAGE ===");

      final context = navigatorKey.currentContext;

      if (context == null) {
        return;
      }

      context.read<GetMessagesNotifier>().appendMessage(data: message);
    }

  }

  void disposeChannel() {
    channelSubscription?.cancel();
    channel?.sink.close();
    
    channel = null;
  }

  @override
  void dispose() {
    reconnectTimer?.cancel();
    disposeChannel();

    super.dispose();
  }
}
