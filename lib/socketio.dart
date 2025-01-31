import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:rakhsa/common/helpers/storage.dart';

import 'package:socket_io_client/socket_io_client.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

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
    String? token = await StorageHelper.getToken();

    socket = IO.io('https://socketio-rakhsa.langitdigital78.com', 
      OptionBuilder().setTransports(['websocket'])
      .disableAutoConnect()
      .setExtraHeaders({'Authorization': token ?? "-"})
      .enableForceNew()
      .enableForceNewConnection()
      .build()
    );

    socket?.connect();

    socket?.onConnect((_) {
      debugPrint("=== CONNECTED SOCKET IO ===");

      final userId = StorageHelper.getUserId();

      if(userId != "-") { 
        socket?.emit("join", {
          "user_id": userId
        });
      }

      setStateConnectionIndicator(ConnectionIndicator.yellow);
      Future.delayed(const Duration(seconds: 1), () {
        setStateConnectionIndicator(ConnectionIndicator.green);
        toggleConnection(true);
      });
      isConnected = true;
    });

    socket?.on("user_online", (data) {
      debugPrint("=== JOIN ${data["user_id"]} ===");
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

  void join() {
    if (socket?.connected ?? false) {
      final userId = StorageHelper.getUserId();
      socket!.emit("join", {
        "user_id": userId
      });
    } else {
      debugPrint("Socket not connected.");
    }
  }

  void leave() {
    final userId = StorageHelper.getUserId();

    socket?.emit('leave', {
      "user_id": userId
    });
  }
}