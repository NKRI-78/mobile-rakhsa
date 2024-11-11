import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/remote_data_source_consts.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketsService extends ChangeNotifier {
  int maxReconnectAttempts = 5;
  int reconnectAttempts = 0;

  WebSocketChannel? channel;
  StreamSubscription? channelSubscription;
  Timer? reconnectTimer;
  ValueNotifier<bool> isConnected = ValueNotifier(false); 

  WebSocketsService() {
    connect();
  }

  void connect() {
    try {
      disposeChannel();

      channel = WebSocketChannel.connect(Uri.parse(RemoteDataSourceConsts.websocketUrl));

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
    required String country
  }) {

    channel?.sink.add(jsonEncode({
      "type": "sos",
      "user_id": "64cdba1f-01ca-464d-a7d4-5c109de0a251",
      "location": location,
      "country": country
    }));
  }

  void onMessageReceived(Map<String, dynamic> message) {

    switch (message["type"]) {
      
      case "confirm-sos":
        debugPrint(message.toString());
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
