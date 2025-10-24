// ignore_for_file: library_prefixes

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';

import 'package:rakhsa/global.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// check socket socket?.connected ?? false

enum ConnectionIndicator { red, yellow, green }

class SocketIoService with ChangeNotifier {
  static final shared = SocketIoService();

  IO.Socket? socket;

  ConnectionIndicator _connectionIndicator = ConnectionIndicator.yellow;
  ConnectionIndicator get connectionIndicator => _connectionIndicator;

  StreamSubscription<List<ConnectivityResult>>? connection;

  StreamSubscription? channelSubscription;
  Timer? reconnectTimer;

  bool isConnected = false;

  Color get indicatorColor {
    switch (connectionIndicator) {
      case ConnectionIndicator.green:
        return ColorResources.green;
      case ConnectionIndicator.yellow:
        return ColorResources.yellow;
      case ConnectionIndicator.red:
        return ColorResources.error;
    }
  }

  void startListenConnection() {
    connection = Connectivity().onConnectivityChanged.listen((result) {
      final hasConnectionResult =
          (result.contains(ConnectivityResult.mobile)) ||
          (result.contains(ConnectivityResult.wifi)) ||
          (result.contains(ConnectivityResult.vpn));

      isConnected = hasConnectionResult;
      notifyListeners();

      if (hasConnectionResult) {
        setStateConnectionIndicator(ConnectionIndicator.green);
      } else {
        setStateConnectionIndicator(ConnectionIndicator.red);
      }
    });
  }

  void stopListenConnection() async {
    connection?.cancel();
    connection = null;
  }

  void setStateConnectionIndicator(ConnectionIndicator connectionIndicators) {
    _connectionIndicator = connectionIndicators;

    notifyListeners();
  }

  void toggleConnection(bool connection) {
    isConnected = connection;

    notifyListeners();
  }

  Future<void> init() async {
    final session = await StorageHelper.getUserSession();

    if (session.token != "-") {
      socket = IO.io(
        'https://socketio-rakhsa.langitdigital78.com',
        OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': session.token})
            .disableAutoConnect()
            .enableForceNew()
            .enableForceNewConnection()
            .build(),
      );

      socket?.connect();
    }

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

      debugPrint(
        "cek context dari socket?.on(message, (message) apakah null? = ${context != null}",
      );
      if (context == null) return;
      FirebaseCrashlytics.instance.recordError(
        "context di socket.on(message) == null",
        StackTrace.fromString(
          "socket?.on(message, (message) lib/socketio.dart line 116",
        ),
      );

      debugPrint("messages dari socket?.on(message, (message) = $message");

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

      if (context == null) {
        return;
      }

      context.read<ProfileNotifier>().getProfile();
    });

    socket?.on("closed-by-agent", (message) {
      debugPrint("=== CLOSED BY AGENT ===");

      final context = navigatorKey.currentContext;

      if (context == null) {
        return;
      }

      context.read<ProfileNotifier>().getProfile();

      context.read<GetMessagesNotifier>().setStateNote(
        val: message["note"].toString(),
      );
    });

    socket?.on("confirmed-by-agent", (message) {
      debugPrint("=== CONFIRMED BY AGENT ===");

      final context = navigatorKey.currentContext;

      if (context == null) {
        return;
      }

      context.read<ProfileNotifier>().getProfile();

      StorageHelper.getUserSession().then((v) {
        if (message["sender"] == v.user.id) {
          if (context.mounted) {
            context.read<GetMessagesNotifier>().navigateToChat(
              chatId: message["chat_id"].toString(),
              status: "NONE",
              recipientId: message["recipient_id"].toString(),
              sosId: message["sos_id"].toString(),
            );
          }
        }
      });

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
    if (socket == null || !(socket?.connected ?? false)) {
      init();
    }
    isConnected = true;
    notifyListeners();
  }

  void subscribeChat(String chatId) {
    socket?.emitWithAck('subscribe_chat', {'chat_id': chatId}, ack: (res) {});
  }

  void unsubscribeChat(String chatId) {
    socket?.emitWithAck('unsubscribe_chat', {'chat_id': chatId}, ack: (_) {});
  }

  void sos({
    required String location,
    required String country,
    required String media,
    required String ext,
    required String lat,
    required String lng,
  }) async {
    final session = await StorageHelper.getUserSession();
    var payload = {
      "user_id": session.user.id,
      "location": location,
      "media": media,
      "ext": ext,
      "lat": lat,
      "lng": lng,
      "country": country,
      "platform_type": "raksha",
    };
    socket?.emit("sos", payload);
  }

  void typing({
    required String recipientId,
    required String chatId,
    required bool isTyping,
  }) async {
    final session = await StorageHelper.getUserSession();
    var payload = {
      "type": "typing",
      "chat_id": chatId,
      "sender": session.user.id,
      "recipient": recipientId,
      "is_typing": isTyping,
    };
    socket?.emit("typing", payload);
  }

  void sendMessage({
    required String chatId,
    required String recipientId,
    required String message,
    required String createdAt,
  }) async {
    final session = await StorageHelper.getUserSession();
    var payload = {
      "chat_id": chatId,
      "sender": session.user.id,
      "recipient": recipientId,
      "text": message,
      "created_at": createdAt,
    };
    socket?.emit("message", payload);
  }

  void userResolvedSos({required String sosId}) {
    var payload = {"type": "user-resolved-sos", "sos_id": sosId};
    socket?.emit("user-resolved-sos", payload);
  }
}
