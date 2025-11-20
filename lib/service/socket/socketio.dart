// ignore_for_file: library_prefixes

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/injection.dart';
import 'package:rakhsa/router/router.dart';

import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/misc/utils/logger.dart';

import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/service/sos/sos_coordinator.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum SocketConnectionStatus { idle, connect, reconnect, error }

class HttpOverridesConfig extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

extension SocketConnectionStatusExtension on SocketConnectionStatus {
  Color get color => switch (this) {
    SocketConnectionStatus.idle => Colors.grey.shade600,
    SocketConnectionStatus.connect => Colors.green,
    SocketConnectionStatus.reconnect => Colors.yellow,
    SocketConnectionStatus.error => Colors.red,
  };
}

class SocketIoService with ChangeNotifier {
  static final shared = SocketIoService();

  IO.Socket? socket;

  SocketConnectionStatus _connStatus = SocketConnectionStatus.idle;
  SocketConnectionStatus get connStatus => _connStatus;
  bool get isConnected => _connStatus == SocketConnectionStatus.connect;

  void _setConnectionStatus(SocketConnectionStatus newStatus) {
    _connStatus = newStatus;
    notifyListeners();
  }

  String get _baseUrl => BuildConfig.instance.socketBaseUrl ?? "-";

  Future<void> init() async {
    final session = await StorageHelper.loadlocalSession();
    if (session != null) {
      socket = IO.io(
        _baseUrl,
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
      log("🛜 SOKET BERHASIL TERSAMBUNG $_baseUrl", label: "SOCKET_SERVICE");
      _setConnectionStatus(SocketConnectionStatus.connect);
    });

    socket?.onReconnect((_) {
      log("🔃 MENCOBA MENGHUBUNGKAN SOKET", label: "SOCKET_SERVICE");
      _setConnectionStatus(SocketConnectionStatus.reconnect);
    });

    socket?.onConnectError((data) {
      log(
        "⚠️ GAGAL MENGHUBUNGKAN SOKET ${data.toString()}",
        label: "SOCKET_SERVICE",
      );
      _setConnectionStatus(SocketConnectionStatus.error);
    });

    socket?.on("message", (message) {
      log("chat masuk via soket $message", label: "SOCKET_SERVICE");
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.read<GetMessagesNotifier>().appendMessage(data: message);
      }
    });

    socket?.on("typing", (message) {
      log("agent typing", label: "SOCKET_SERVICE");

      final context = navigatorKey.currentContext;
      if (context != null) {
        context.read<GetMessagesNotifier>().updateUserTyping(data: message);
      }
    });

    socket?.on("resolved-by-user", (message) async {
      log("resolved by user", label: "SOCKET_SERVICE");

      final context = navigatorKey.currentContext;
      if (context != null) {
        context.read<UserProvider>().getUser();
      }
    });

    socket?.on("closed-by-agent", (message) async {
      log("closed by agent", label: "SOCKET_SERVICE");

      final context = navigatorKey.currentContext;
      if (context != null) {
        context.read<UserProvider>().getUser();
        context.read<GetMessagesNotifier>().setStateNote(
          val: message["note"].toString(),
        );
        context.read<GetMessagesNotifier>().appendMessage(
          data: {"closed_by_agent": true},
        );
      }
    });

    socket?.on("confirmed-by-agent", (message) {
      log(
        "confirmed by agent, recipient_id = ${message["recipient_id"] ?? "-"}",
        label: "SOCKET_SERVICE",
      );

      locator<SosCoordinator>().stop(reason: "socket-admin-confirmed");

      final context = navigatorKey.currentContext;
      if (context != null) {
        context.read<UserProvider>().getUser();
        if (message["sender"] == session?.user.id) {
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
        // context.read<SosNotifier>().stopTimer();
      }
    });
  }

  void connect() {
    if (socket == null || !(socket?.connected ?? false)) {
      init();
    }
  }

  void close() {
    socket?.close();
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    log("soket dihapus", label: "SOCKET_SERVICE");
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
    final session = StorageHelper.session;
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
      log('SOS BERHASIL DIKIRIM $payload', label: "SOCKET_SERVICE");
      socket?.emit("sos", payload);
    }
  }

  void typing({
    required String recipientId,
    required String chatId,
    required bool isTyping,
  }) async {
    final session = StorageHelper.session;
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
    final session = StorageHelper.session;
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
