// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
// import 'package:rakhsa/common/helpers/storage.dart';

// import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
// import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
// import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';

// import 'package:rakhsa/global.dart';

// import 'package:web_socket_channel/web_socket_channel.dart';

// enum ConnectionIndicator { red, yellow, green }

// class WebSocketsService extends ChangeNotifier {

//   WebSocketsService() {
//     connect();
//   }

//   ConnectionIndicator _connectionIndicator = ConnectionIndicator.yellow;
//   ConnectionIndicator get connectionIndicator => _connectionIndicator;

//   List<Map<String, dynamic>> messageQueue = [];

//   WebSocketChannel? channel;
//   StreamSubscription? channelSubscription;
//   Timer? reconnectTimer;

//   bool isConnected = false;

//   void setStateConnectionIndicator(ConnectionIndicator connectionIndicators) {
//     _connectionIndicator = connectionIndicators;
    
//     notifyListeners();
//   }

//   void toggleConnection(bool connection) {
//     isConnected = connection;

//     notifyListeners();
//   }

//   void connect() {
//     try {
//       channel = WebSocketChannel.connect(Uri.parse(RemoteDataSourceConsts.websocketUrlProd));

//       channelSubscription = channel!.stream.listen(
//         (message) async {
//           debugPrint("=== MESSAGE ${message.toString()} ===");
//           setStateConnectionIndicator(ConnectionIndicator.yellow);

//           Future.delayed(const Duration(seconds: 1), () {
//             setStateConnectionIndicator(ConnectionIndicator.green);
//             toggleConnection(true);
//           });

//           final data = jsonDecode(message);
//           onMessageReceived(data);
//         },
//         onDone: () {
//           toggleConnection(false);
//           reconnect();
//         },
//         onError: (error) {
//           toggleConnection(false);
//           handleError(error);
//         },
//       );

//       join();
//       debugPrint("Connected to socket.");
//     } catch (e) {
//       debugPrint("Connection error: $e");
//       reconnect();
//     }
//   }

//   void sendMessageQueue(Map<String, dynamic> message) {
//     try {
//       channel!.sink.add(jsonEncode(message));
//       debugPrint("SOS Message Sent: $message");
//     } catch (e) {
//       debugPrint("Failed to send SOS message: $e");
//       messageQueue.add(message); // Re-add message to queue if sending fails
//     }
//   }

//   void reconnect() {
//     debugPrint("Attempting to reconnect...");

//     reconnectTimer?.cancel();

//     if (isConnected) {
//       debugPrint("Already connected, skipping reconnection.");
//       return;
//     }

//     setStateConnectionIndicator(ConnectionIndicator.red);

//     reconnectTimer = Timer(const Duration(seconds: 5), () {
//       if (channel == null || !isConnected) {
//         connect();
//       }
//     });
//   }

//   void handleError(dynamic error) {
//     debugPrint("WebSocket Error: $error");
//     reconnect();
//   }

//   void typing({
//     required String recipientId,
//     required String chatId,
//     required bool isTyping
//   }) {
//     final userId = StorageHelper.getUserId();

//     channel?.sink.add(jsonEncode({
//       "type": "typing",
//       "chat_id": chatId,
//       "sender": userId,
//       "recipient": recipientId,
//       "is_typing": isTyping
//     }));
//   }

//   void join() {
//     final userId = StorageHelper.getUserId();

//     channel?.sink.add(jsonEncode({
//       "type": "join",
//       "user_id": userId,
//     }));
//   }

//   void leave() {
//     final userId = StorageHelper.getUserId();

//     channel?.sink.add(jsonEncode({
//       "type": "leave",
//       "user_id": userId,
//     }));
//   }

//   void sos({
//     required String location,
//     required String country,
//     required String media,
//     required String ext,
//     required String lat,
//     required String lng,
//   }) async {
//     final userId = StorageHelper.getUserId();

//     channel?.sink.add(jsonEncode({
//       "type": "sos",
//       "user_id": userId,
//       "location": location,
//       "media": media,
//       "ext": ext,
//       "lat": lat,
//       "lng": lng,
//       "country": country,
//       "platform_type": "raksha"
//     }));
//   }

//   void sendMessage({
//     required String chatId,
//     required String recipientId,
//     required String message,
//     required String createdAt
//   }) {
//     final userId = StorageHelper.getUserId();

//     channel?.sink.add(jsonEncode({
//       "type": "message",
//       "chat_id": chatId,
//       "sender": userId,
//       "recipient": recipientId,
//       "text": message,
//       "created_at": createdAt
//     }));
//   }

//   void userResolvedSos({
//     required String sosId,
//   }) {
//     channel?.sink.add(jsonEncode({
//       "type": "user-resolved-sos",
//       "sos_id": sosId,
//     }));
//   }

//   void onMessageReceived(Map<String, dynamic> message) {

//     if (message["type"] == "fetch-message") {
//       debugPrint("=== FETCH MESSAGE ===");

//       final context = navigatorKey.currentContext;

//       if (context == null) {
//         return;
//       }

//       context.read<GetMessagesNotifier>().appendMessage(data: message);
//     }

//     if(message["type"] == "typing") {
//       debugPrint("=== TYPING ===");

//       final context = navigatorKey.currentContext;

//       if (context == null) {
//         return;
//       }

//       context.read<GetMessagesNotifier>().updateUserTyping(data: message);
//     }

//     if(message["type"] == "resolved-by-user") {
//       debugPrint("=== RESOLVED BY USER ===");

//       final context = navigatorKey.currentContext;

//       if(context == null) {
//         return;
//       }

//       context.read<ProfileNotifier>().getProfile();
//     }

//     if(message["type"] == "closed-by-agent") { 
//       debugPrint("=== CLOSED BY AGENT ===");

//       final context = navigatorKey.currentContext;

//       if(context == null) {
//         return;
//       }

//       context.read<ProfileNotifier>().getProfile();

//       context.read<GetMessagesNotifier>().setStateNote(val: message["note"].toString());
//     }

//     if(message["type"] == "confirmed-by-agent") {
//       debugPrint("=== CONFIRMED BY AGENT ===");

//       final context = navigatorKey.currentContext;

//       if(context == null) {
//         return;
//       }

//       context.read<ProfileNotifier>().getProfile();

//       if(message["sender"] == StorageHelper.getUserId()) {
//         context.read<GetMessagesNotifier>().navigateToChat(
//           chatId: message["chat_id"].toString(),
//           status: "NONE",
//           recipientId: message["recipient_id"].toString(),
//           sosId: message["sos_id"].toString(),
//         );
//       }

//       Future.delayed(const Duration(seconds: 1), () {
//         context.read<SosNotifier>().stopTimer();
//       });
//     }

//   }

//   void disposeChannel() {
//     channelSubscription?.cancel();
//     channel?.sink.close();
    
//     channel = null;
//   }

//   @override
//   void dispose() {
//     reconnectTimer?.cancel();
//     disposeChannel();

//     super.dispose();
//   }
// }