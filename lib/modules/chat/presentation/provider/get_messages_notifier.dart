import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rakhsa/main.dart';

import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/routes/routes_navigation.dart';

import 'package:rakhsa/modules/chat/data/models/messages.dart';
import 'package:rakhsa/modules/chat/domain/usecases/get_messages.dart';

class GetMessagesNotifier with ChangeNotifier {
  final GetMessagesUseCase useCase;

  GetMessagesNotifier({required this.useCase});

  String _activeChatId = "";
  String get activeChatId => _activeChatId;

  String _note = "";
  String get note => _note;

  bool _isBtnSessionEnd = false;
  bool get isBtnSessionEnd => _isBtnSessionEnd;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  bool _showAutoGreetings = false;
  bool get showAutoGreetings => _showAutoGreetings;

  int _time = 60;
  int get time => _time;

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

  late Timer _timer;

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_time > 0) {
        _time--;
        notifyListeners();
      } else {
        _timer.cancel();
        _isBtnSessionEnd = true;
        notifyListeners();
      }
    });
  }

  void cancelTimer() {
    if (_isRunning) {
      _timer.cancel();
      _isBtnSessionEnd = false;
      _isRunning = false;
      notifyListeners();
    }
  }

  void resetTimer() {
    cancelTimer();
    _time = 5;
    notifyListeners();
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

  void initializeBtnSessionEnd() {
    _isBtnSessionEnd = false;

    notifyListeners();
  }

  void showBtnSessionEnd() {
    _isBtnSessionEnd = true;

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
        debugPrint('chat dari _messages = $_messages');

        notifyListeners();
      },
    );
  }

  void navigateToChat({
    required String chatId,
    required String status,
    required String recipientId,
    required String sosId,
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
      debugPrint(
        "incomingChatId dari appendMessage = ${incomingChatId.isNotEmpty ? incomingChatId : "-"}",
      );
      debugPrint(
        "incomingChatId dari appendMessage = ${incomingChatId.isNotEmpty ? incomingChatId : "-"}",
      );
      debugPrint(
        "incomingMessageId dari appendMessage = ${incomingMessageId.isNotEmpty ? incomingMessageId : "-"}",
      );
      debugPrint(
        "activeChatId dari appendMessage = ${activeChatId.isNotEmpty ? activeChatId : "-"}",
      );
      debugPrint(
        "apakah incomingChatId != activeChatId? ${incomingChatId != activeChatId}",
      );
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
      final filteredMsg = _messages.map((e) => e.text);
      debugPrint(
        "_messages dari appendMessage setelah di notifyListeners() = $filteredMsg",
      );
    }
  }
}
