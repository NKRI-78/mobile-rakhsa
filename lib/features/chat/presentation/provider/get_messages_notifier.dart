import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/chat/data/models/messages.dart';
import 'package:rakhsa/features/chat/domain/usecases/get_messages.dart';

class GetMessagesNotifier with ChangeNotifier {
  final GetMessagesUseCase useCase;

  GetMessagesNotifier({
    required this.useCase
  });

  String _activeChatId = "";
  String get activeChatId => _activeChatId;

  String _note = "";
  String get note => _note;

  bool _isBtnSessionEnd = false;
  bool get isBtnSessionEnd => _isBtnSessionEnd;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  bool _isCaseClosed = false;
  bool get isCaseClosed => _isCaseClosed;
  
  int _time = 5;
  int get time => _time;

  late Timer _timer;

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_time > 0) {
        _time--;
        Future.delayed(Duration.zero, () => notifyListeners());
      } else {
        _timer.cancel();
        _isBtnSessionEnd = true;
        Future.delayed(Duration.zero, () => notifyListeners());
      }
    });
  }

  void cancelTimer() {
    if (_isRunning) {
      _timer.cancel();
      _isBtnSessionEnd = false;
      _isRunning = false;
      Future.delayed(Duration.zero, () => notifyListeners());
    }
  }

  void resetTimer() {
    cancelTimer();
    _time = 5; 
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  ScrollController sC = ScrollController();

  RecipientUser _recipient = RecipientUser();
  RecipientUser get recipient => _recipient;

  List<MessageData> _messages = [];
  List<MessageData> get messages => [..._messages];

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  Map<String, bool> onlineStatus = {};
  Map<String, String?> typingStatus = {};

  void clearActiveChatId() {
    _activeChatId = "";

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void setStateIsCaseClosed() {
    _isCaseClosed = true;
    
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void setStateNote({required String val}) {
    _note = val;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void updateUserStatus({required Map<String, dynamic> data}) {
    onlineStatus[data["recipient"]] = data["type"] == "online" ? true : false;
  
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  bool isOnline(String userId) {
    return onlineStatus[userId] ?? false;
  }

  void updateUserTyping({required Map<String, dynamic> data}) {
    if (data["is_typing"]) {
      typingStatus[data["chat_id"]] = data["sender"];
    } else {
      typingStatus.remove(data["chat_id"]);
    }
    
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  bool isTyping(String chatId) {
    return typingStatus.containsKey(chatId);
  }

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void initializeBtnSessionEnd() {
    _isBtnSessionEnd = false;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void showBtnSessionEnd() {
    _isBtnSessionEnd = true;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> getMessages({required String chatId}) async {
    final result = await useCase.execute(chatId: chatId);
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (sC.hasClients) {
        sC.animateTo(
          sC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut, 
        );
      }
    });

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {
      _recipient = r.data.recipient;

      _note = r.data.note;

      _activeChatId = r.data.chatId;

      _messages = [];
      _messages.addAll(r.data.messages);

      setStateProvider(ProviderState.loaded);
    });

  }

  void appendMessage({required Map<String, dynamic> data}) {
    String incomingChatId = data["data"]["chat_id"];
    String incomingMessageId = data["data"]["id"];
    bool isRead = data["data"]["is_read"];

    // Ensure the message belongs to the current chat
    if (incomingChatId != activeChatId) {
      return; // Ignore messages for other chats
    }

    // Check for duplicate messages
    if (_messages.any((message) => message.id == incomingMessageId)) {
      return;
    }

    // Add the new message at the beginning of the messages list
    _messages.insert(
      0,
      MessageData(
        id: incomingMessageId,
        chatId: incomingChatId,
        user: MessageUser(
          id: data["data"]["user"]["id"],
          isMe: data["data"]["user"]["is_me"],
          avatar: data["data"]["user"]["avatar"],
          name: data["data"]["user"]["name"],
        ),
        isRead: isRead,
        sentTime: data["data"]["sent_time"],
        text: data["data"]["text"],
        createdAt: DateTime.now(),
      ),
    );

    // Scroll to the bottom of the chat after adding the message
    Future.delayed(const Duration(milliseconds: 300), () {
      if (sC.hasClients) {
        sC.animateTo(
          sC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Notify listeners of the state change
    Future.delayed(Duration.zero, () => notifyListeners());
  }

}