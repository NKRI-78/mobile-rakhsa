import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';

import 'package:rakhsa/features/chat/data/models/messages.dart';
import 'package:rakhsa/features/chat/domain/usecases/get_messages.dart';
import 'package:rakhsa/global.dart';

class GetMessagesNotifier with ChangeNotifier {
  final GetMessagesUseCase useCase;

  GetMessagesNotifier({
    required this.useCase
  }) {
    sC = ScrollController();
  }

  String _activeChatId = "";
  String get activeChatId => _activeChatId;

  String _note = "";
  String get note => _note;

  bool _isBtnSessionEnd = false;
  bool get isBtnSessionEnd => _isBtnSessionEnd;

  bool _isRunning = false;
  bool get isRunning => _isRunning;
  
  int _time = 60;
  int get time => _time;

  late ScrollController sC;

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

  void clearActiveChatId() {
    _activeChatId = "";

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void setStateNote({required String val}) {
    _note = val;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  bool isTyping(String chatId) {
    return typingStatus[chatId] ?? false;
  }

  void updateUserTyping({required Map<String, dynamic> data}) {
    String chatId = data["data"]["chat_id"];
    bool isTyping = data["data"]["is_typing"];

    if (isTyping) {
      typingStatus[chatId] = true; 
    } else {
      typingStatus.remove(chatId); 
    }

    Future.delayed(Duration.zero, () => notifyListeners());
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

  Future<void> getMessages({required String chatId, required String status}) async {
    setStateProvider(ProviderState.loading);

    final result = await useCase.execute(chatId: chatId, status: status);
 
    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.loaded);
    }, (r) {
      _recipient = r.data.recipient;

      _note = r.data.note;

      _activeChatId = r.data.chatId;

      _messages = [];
      _messages.addAll(r.data.messages);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (sC.hasClients) {
          sC.animateTo(
            sC.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), 
            curve: Curves.easeOut, 
          );
        }
      });

      setStateProvider(ProviderState.loaded);
    });

  }

  void navigateToChat({
    required String chatId,
    required String status, 
    required String recipientId,
    required String sosId
  }) {
    Navigator.pushNamedAndRemoveUntil(
      navigatorKey.currentContext!, 
      RoutesNavigation.dashboard, (route) => false
    );
    Navigator.pushNamed(
      navigatorKey.currentContext!, 
      arguments: {
        "chat_id": chatId,
        "status": status,
        "recipient_id": recipientId,
        "sos_id": sosId,
        "auto_greetings": true
      },
      RoutesNavigation.chat
    );
  }

  void appendMessage({required Map<String, dynamic> data}) {
    String incomingChatId = data["data"]["chat_id"];
    String incomingMessageId = data["data"]["id"];
    bool isRead = data["data"]["is_read"];

    if (incomingChatId != activeChatId) {
      return;
    }

    if (_messages.any((message) => message.id == incomingMessageId)) {
      return;
    }

    _messages.insert(0,
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

    Future.delayed(Duration.zero, () => notifyListeners());

    // Future.delayed(const Duration(milliseconds: 300), () {
    //   if (sC.hasClients) {
    //     sC.animateTo(
    //       sC.position.maxScrollExtent,
    //       duration: const Duration(milliseconds: 300),
    //       curve: Curves.easeOut,
    //     );
    //     Future.delayed(Duration.zero, () => notifyListeners());
    //   }
    // });

    
  }

}