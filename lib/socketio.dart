import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';

import 'package:rakhsa/global.dart';

import 'package:socket_io_client/socket_io_client.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

// check socket socket?.connected ?? false

enum ConnectionIndicator { red, yellow, green }

class SocketIoService with ChangeNotifier {
  static final shared = SocketIoService();

  IO.Socket? socket;

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

  Future<void> init() async {
    String token = await StorageHelper.getToken();

    socket = IO.io('https://socketio-rakhsa.langitdigital78.com', 
      OptionBuilder().setTransports(['websocket'])
      .setAuth({
        'token': token
      })
      .disableAutoConnect()
      .enableForceNew()
      .enableForceNewConnection()
      .build()
    );

    socket?.connect();

    socket?.onConnect((_) {
      debugPrint("=== CONNECTED SOCKET IO ===");

      setStateConnectionIndicator(ConnectionIndicator.yellow);
      Future.delayed(const Duration(seconds: 1), () {
        setStateConnectionIndicator(ConnectionIndicator.green);
        toggleConnection(true);
      });
      isConnected = true;
    });

    socket?.on("message", (message) {
      debugPrint("=== FETCH MESSAGE ===");

      final context = navigatorKey.currentContext;

      if (context == null) {
        return;
      }

      context.read<GetMessagesNotifier>().appendMessage(data: message);
    });

    socket?.on("typing", (message) {
      debugPrint("=== TYPING ===");

      final context = navigatorKey.currentContext;

      if (context == null) {
        return;
      }

      context.read<GetMessagesNotifier>().updateUserTyping(data: message);
    });

    socket?.on("resolved-by-user", (message) {
      debugPrint("=== RESOLVED BY USER ===");

      final context = navigatorKey.currentContext;

      if(context == null) {
        return;
      }

      context.read<ProfileNotifier>().getProfile();
    });

    socket?.on("closed-by-agent", (message) {
      debugPrint("=== CLOSED BY AGENT ===");

      final context = navigatorKey.currentContext;

      if(context == null) {
        return;
      }

      context.read<ProfileNotifier>().getProfile();

      context.read<GetMessagesNotifier>().setStateNote(val: message["note"].toString());
    });

    socket?.on("confirmed-by-agent", (message) {
      debugPrint("=== CONFIRMED BY AGENT ===");

      final context = navigatorKey.currentContext;

      if(context == null) {
        return;
      }

      context.read<ProfileNotifier>().getProfile();

      if(message["sender"] == StorageHelper.getUserId()) {
        context.read<GetMessagesNotifier>().navigateToChat(
          chatId: message["chat_id"].toString(),
          status: "NONE",
          recipientId: message["recipient_id"].toString(),
          sosId: message["sos_id"].toString(),
        );
      }

      context.read<SosNotifier>().stopTimer();
    });

    socket?.onReconnect((_) {
      isConnected = true;
      setStateConnectionIndicator(ConnectionIndicator.red);
    });
    
    socket?.onConnectError((data) {
      debugPrint("=== ERROR CONNECTION SOCKET IO ${data.toString()} ===");
    });
  }

  void connect() {
    init();

    isConnected = true;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void sos({
    required String location,
    required String country,
    required String media,
    required String ext,
    required String lat,
    required String lng,
  }) {
    final userId = StorageHelper.getUserId();
    var payload = {
      "user_id": userId,
      "location": location,
      "media": media,
      "ext": ext,
      "lat": lat,
      "lng": lng,
      "country": country,
      "platform_type": "raksha"
    };
    socket?.emit("sos", payload);
  }
  
  void typing({
    required String recipientId,
    required String chatId,
    required bool isTyping
  }) {
    final userId = StorageHelper.getUserId();
    var payload = {
      "type": "typing",
      "chat_id": chatId,
      "sender": userId,
      "recipient": recipientId,
      "is_typing": isTyping
    };
    socket?.emit("typing", payload);
  }

  void sendMessage({
    required String chatId,
    required String recipientId,
    required String message,
    required String createdAt
  }) {
    final userId = StorageHelper.getUserId();
    var payload = {
      "chat_id": chatId,
      "sender": userId,
      "recipient": recipientId,
      "text": message,
      "created_at": createdAt
    };
    socket?.emit("message", payload);
  }

  void userResolvedSos({
    required String sosId,
  }) {
    var payload = {
      "type": "user-resolved-sos",
      "sos_id": sosId
    };
    socket?.emit("user-resolved-sos", payload);
  }
}