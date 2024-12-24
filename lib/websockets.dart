import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/chat/presentation/pages/chat.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';

import 'package:rakhsa/global.dart';
import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

enum ConnectionIndicator { red, yellow, green }

class WebSocketsService extends ChangeNotifier {
  final GetMessagesNotifier messagesNotifier;

  ConnectionIndicator _connectionIndicator = ConnectionIndicator.yellow;
  ConnectionIndicator get connectionIndicator => _connectionIndicator;

  WebSocketChannel? channel;
  StreamSubscription? channelSubscription;
  Timer? reconnectTimer;

  bool isConnected = false;

  WebSocketsService({
    required this.messagesNotifier,
  });

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

      debugPrint(channel.toString());

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
    required String recipientId,
    required String message,
  }) {
    final userId = StorageHelper.getUserId();

    channel?.sink.add(jsonEncode({
      "type": "message",
      "sender": userId,
      "recipient": recipientId,
      "text": message,
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
    String? userId = StorageHelper.getUserId();

    if (message["type"] == "fetch-message") {
      debugPrint("=== FETCH MESSAGE ===");
      messagesNotifier.appendMessage(data: message);
    }

    if (message["type"] == "resolved-sos-$userId") {
      debugPrint("=== RESOLVED SOS ===");
      
      String msg = message["message"].toString();

      Future.delayed(const Duration(seconds: 1), () async {
        GeneralModal.infoResolvedSos(msg: msg);
      });
    }

    if (message["type"] == "closed-sos-$userId") {
      debugPrint("=== CLOSED SOS ===");

      String msg = message["message"].toString();

      Future.delayed(const Duration(seconds: 1), () async {
        navigatorKey.currentContext!.read<ProfileNotifier>().getProfile();
      });

      messagesNotifier.setStateIsCaseClosed(true);
      messagesNotifier.setStateNote(val: msg);
    }

    if (message["type"] == "confirm-sos") {
      debugPrint("=== CONFIRM SOS ===");

      String chatId = message["chat_id"];
      String recipientId = message["recipient_id"];
      String sosId = message["sos_id"];
      String status = message["status"];
    
      Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (BuildContext context) {
        return ChatPage(
          chatId: chatId,
          status: status,
          recipientId: recipientId,
          sosId: sosId,
          autoGreetings: true,
        );
      }));

      Future.delayed(const Duration(seconds: 1), () {
        navigatorKey.currentContext!.read<ProfileNotifier>().getProfile();
      });

      navigatorKey.currentContext!.read<SosNotifier>().stopTimer();

      messagesNotifier.resetTimer();
      messagesNotifier.startTimer();
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
