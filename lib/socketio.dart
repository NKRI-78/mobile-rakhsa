// ignore_for_file: library_prefixes

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';

import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/expire_sos_notifier.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'main.dart';

// check socket socket?.connected ?? false

enum ConnectionIndicator { red, yellow, green }

class SocketIoService with ChangeNotifier {
  static final shared = SocketIoService();

  IO.Socket? socket;

  ConnectionIndicator _connectionIndicator = ConnectionIndicator.yellow;
  ConnectionIndicator get connectionIndicator => _connectionIndicator;

  StreamSubscription<List<ConnectivityResult>>? connection;

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

    if (session != null) {
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

    socket?.onConnect((message) {
      debugPrint("🛜 SOKET BERHASIL TERSAMBUNG $message");

      setStateConnectionIndicator(ConnectionIndicator.yellow);
      Future.delayed(const Duration(seconds: 1), () {
        setStateConnectionIndicator(ConnectionIndicator.green);
        toggleConnection(true);
      });
      isConnected = true;
    });

    socket?.onReconnect((_) {
      debugPrint("🔃 MENCOBA MENGHUBUNGKAN SOKET");
      isConnected = true;
      setStateConnectionIndicator(ConnectionIndicator.red);
    });

    socket?.onConnectError((data) {
      debugPrint("⚠️ GAGAL MENGHUBUNGKAN SOKET ${data.toString()}");
    });

    socket?.on("message", (message) {
      debugPrint(
        "PESAN MASUK VIA SOKET socket?.on(message, (message)) = $message",
      );
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.read<GetMessagesNotifier>().appendMessage(data: message);
      }
    });

    socket?.on("typing", (message) {
      debugPrint("=== TYPING ===");

      final context = navigatorKey.currentContext;
      if (context != null) {
        context.read<GetMessagesNotifier>().updateUserTyping(data: message);
      }
    });

    socket?.on("resolved-by-user", (message) {
      debugPrint("=== RESOLVED BY USER ===");

      final context = navigatorKey.currentContext;
      if (context != null) {
        context.read<UserProvider>().getUser();
        context.read<GetMessagesNotifier>().resetTimer();
      }
    });

    socket?.on("closed-by-agent", (message) {
      debugPrint("=== CLOSED BY AGENT ===");

      final context = navigatorKey.currentContext;
      if (context != null) {
        context.read<UserProvider>().getUser();
        context.read<GetMessagesNotifier>().setStateNote(
          val: message["note"].toString(),
        );
        context.read<GetMessagesNotifier>().appendMessage(
          data: {"closed_by_agent": true},
        );
        context.read<GetMessagesNotifier>().resetTimer();
      }
    });

    socket?.on("confirmed-by-agent", (message) {
      debugPrint("=== CONFIRMED BY AGENT ===");

      final context = navigatorKey.currentContext;
      if (context != null) {
        context.read<UserProvider>().getUser();
        StorageHelper.getUserSession().then((v) {
          if (v == null) return;
          if (message["sender"] == v.user.id) {
            if (context.mounted) {
              context.read<GetMessagesNotifier>().navigateToChat(
                chatId: message["chat_id"].toString(),
                status: "NONE",
                recipientId: message["recipient_id"].toString(),
                sosId: message["sos_id"].toString(),
                newSession: true,
              );
            }
          }
        });
        context.read<SosNotifier>().stopTimer();
      }
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
    if (session != null) {
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
  }

  void typing({
    required String recipientId,
    required String chatId,
    required bool isTyping,
  }) async {
    final session = await StorageHelper.getUserSession();
    if (session != null) {
      var payload = {
        "type": "typing",
        "chat_id": chatId,
        "sender": session.user.id,
        "recipient": recipientId,
        "is_typing": isTyping,
      };
      socket?.emit("typing", payload);
    }
  }

  void sendMessage({
    required String chatId,
    required String recipientId,
    required String message,
    required String createdAt,
  }) async {
    final session = await StorageHelper.getUserSession();
    if (session != null) {
      var payload = {
        "chat_id": chatId,
        "sender": session.user.id,
        "recipient": recipientId,
        "text": message,
        "created_at": createdAt,
      };
      socket?.emit("message", payload);
    }
  }

  void userResolvedSos({required String sosId}) {
    var payload = {"type": "user-resolved-sos", "sos_id": sosId};
    socket?.emit("user-resolved-sos", payload);
  }
}
