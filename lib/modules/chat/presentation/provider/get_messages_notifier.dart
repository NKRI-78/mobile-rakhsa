import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/routes/nav_key.dart';
import 'package:rakhsa/routes/routes_navigation.dart';

import 'package:rakhsa/modules/chat/data/models/messages.dart';
import 'package:rakhsa/modules/chat/domain/usecases/get_messages.dart';

class GetMessagesNotifier with ChangeNotifier {
  final GetMessagesUseCase useCase;

  GetMessagesNotifier({required this.useCase});

  final sessionCacheKey = "end_session";
  final endSessionDuration = 5; // dalam hitungan menit

  String _activeChatId = "";
  String get activeChatId => _activeChatId;

  String _note = "";
  String get note => _note;

  bool _isBtnSessionEnd = false;
  bool get isBtnSessionEnd => _isBtnSessionEnd;

  bool _showAutoGreetings = false;
  bool get showAutoGreetings => _showAutoGreetings;

  RecipientUser _recipient = RecipientUser();
  RecipientUser get recipient => _recipient;

  List<MessageData> _messages = [];
  List<MessageData> get messages => [..._messages];

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  Map<String, bool> onlineStatus = {};
  Map<String, bool> typingStatus = {};

  void initTimeSession() async {
    await StorageHelper.write(sessionCacheKey, DateTime.now().toString());
  }

  void initTimeSessionWhenIsNull() async {
    if (StorageHelper.containsKey(sessionCacheKey)) return;
    await StorageHelper.write(sessionCacheKey, DateTime.now().toString());
  }

  void checkTimeSession() {
    final cSession = StorageHelper.read(sessionCacheKey);
    if (cSession != null) {
      final savedSession = DateTime.parse(cSession);
      final diffInMinutes = DateTime.now().difference(savedSession).inMinutes;
      log("diffInMinutes? ${diffInMinutes}s");

      // dibaca cuy 🙏😋
      // jika selisih waktu sudah/lebih dari 5 menit maka _isBtnSessionEnd = true
      if (diffInMinutes >= endSessionDuration) {
        _isBtnSessionEnd = true;
        notifyListeners();
      } else {
        _isBtnSessionEnd = false;
        notifyListeners();
      }
    } else {
      _isBtnSessionEnd = false;
      notifyListeners();
    }
  }

  void clearTimeSession() async {
    await StorageHelper.delete(sessionCacheKey);
  }

  void clearActiveChatId() {
    _activeChatId = "";

    notifyListeners();
  }

  void setStateNote({required String val}) {
    _note = val;

    notifyListeners();
  }

  bool isTyping(String chatId) {
    return typingStatus[chatId] ?? false;
  }

  void updateUserTyping({required Map<String, dynamic> data}) {
    String chatId = data["chat_id"];
    bool isTyping = data["is_typing"];

    if (isTyping) {
      typingStatus[chatId] = true;
    } else {
      typingStatus.remove(chatId);
    }

    notifyListeners();
  }

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  void initShowAutoGreetings(bool show) {
    _showAutoGreetings = show;
    notifyListeners();
  }

  Future<void> getMessages({
    required String chatId,
    required String status,
  }) async {
    setStateProvider(ProviderState.loading);

    final result = await useCase.execute(chatId: chatId, status: status);

    result.fold(
      (l) {
        _message = l.message;
        setStateProvider(ProviderState.loaded);
      },
      (r) {
        _recipient = r.data.recipient;

        _note = r.data.note;

        _activeChatId = r.data.chatId;

        _state = ProviderState.loaded;

        debugPrint('chat masuk = ${r.data.messages}');

        _messages = [];
        debugPrint('chat dari _messages = $_messages');

        _messages.addAll(r.data.messages);
        debugPrint(
          'chat dari _messages = ${_messages.map((e) => {"time": e.sentTime, "message": e.text}).toList()}',
        );

        notifyListeners();
      },
    );
  }

  void navigateToChat({
    required String chatId,
    required String status,
    required String recipientId,
    required String sosId,
    bool newSession = false,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      navigatorKey.currentContext!,
      RoutesNavigation.dashboard,
      (route) => false,
    );
    Navigator.pushNamed(
      navigatorKey.currentContext!,
      arguments: {
        "chat_id": chatId,
        "status": status,
        "recipient_id": recipientId,
        "sos_id": sosId,
        "auto_greetings": true,
        "new_session": newSession,
      },
      RoutesNavigation.chat,
    );
  }

  void appendMessage({required Map<String, dynamic> data}) {
    _showAutoGreetings = false;
    notifyListeners();

    // flag closed by agent untuk create data dummy catatan penutup chat jadi bubble chat
    // diakhir sesi chat sos
    bool closedByAgent = data['closed_by_agent'] ?? false;

    if (closedByAgent) {
      debugPrint("closedByAgent di trigger");
      if (_messages.any((m) => m.id == "closed_by_agent")) return;
      _messages.insert(
        0,
        MessageData(
          id: "closed_by_agent",
          chatId: activeChatId,
          user: MessageUser(id: null, isMe: false, avatar: null, name: null),
          isRead: true,
          sentTime: DateTime.now().format("HH.mm"),
          text: _note,
          createdAt: DateTime.now(),
        ),
      );
      // notifyListeners();
      debugPrint(
        "closedByAgent _messages dari appendMessage ketika closed by agent = ${_messages.map((e) => e.text).toList()}",
      );
    } else {
      String incomingChatId = data["chat_id"];
      String incomingMessageId = data["id"];
      bool isRead = data["is_read"];

      final msgData = {
        "msg_id": incomingMessageId,
        "chat_id": incomingChatId,
        "is_read": isRead,
        "user": {
          "id": data['user']['id'],
          "isMe": data['user']['is_me'],
          "avatar": data["user"]["avatar"],
          "name": data["user"]["name"],
        },
        "sentTime": data["sent_time"],
        "text": data["text"],
      };

      debugPrint("msg data = $msgData");

      final containIncomingMsgId = _messages.any(
        (msg) => msg.id == incomingMessageId,
      );
      debugPrint(
        "apakah _messages memuat id yang sama dengan incomingMessageId? $containIncomingMsgId",
      );
      if (containIncomingMsgId) return;
      _messages.insert(
        0,
        MessageData(
          id: incomingMessageId,
          chatId: incomingChatId,
          user: MessageUser(
            id: data["user"]["id"],
            isMe: data["user"]["is_me"],
            avatar: data["user"]["avatar"],
            name: data["user"]["name"],
          ),
          isRead: isRead,
          sentTime: data["sent_time"],
          text: data["text"],
          createdAt: DateTime.now(),
        ),
      );
      notifyListeners();
      final filteredMsg = _messages
          .map((e) => {"time": e.sentTime, "message": e.text})
          .toList();
      debugPrint(
        "_messages dari appendMessage setelah di notifyListeners() = $filteredMsg",
      );
    }
  }
}
