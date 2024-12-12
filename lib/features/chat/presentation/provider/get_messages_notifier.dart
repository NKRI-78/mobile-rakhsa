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

  bool isBtnSessionEnd = false;
  
  int _time = 60;
  int get time => _time;

  late Timer _timer;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_time > 0) {
        _time--;
        notifyListeners();
      } else {
        _timer.cancel();
        showBtnSessionEnd();
      }
    });
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
    isBtnSessionEnd = false;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void showBtnSessionEnd() {
    isBtnSessionEnd = true;

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

      _messages = [];
      _messages.addAll(r.data.messages);

      setStateProvider(ProviderState.loaded);
    });

  }

  void appendMessage({required Map<String, dynamic> data}) {
    bool isRead = data["data"]["is_read"];

    _messages.insert(0, MessageData(
      id: data["data"]["id"],
      chatId: data["data"]["chat_id"],
      user: MessageUser(
        id: data["data"]["user"]["id"],
        isMe: data["data"]["user"]["is_me"],
        avatar: data["data"]["user"]["avatar"],
        name: data["data"]["user"]["name"]
      ), 
      isRead: isRead, 
      sentTime: data["data"]["sent_time"], 
      text: data["data"]["text"], 
      createdAt: DateTime.now()
    ));

    Future.delayed(Duration.zero, () => notifyListeners());

    Future.delayed(const Duration(milliseconds: 300), () {
      if (sC.hasClients) {
        sC.animateTo(
          sC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut, 
        );
      }
    });
  } 

  void ackRead({required Map<String, dynamic> data}) {
    bool recipientView = data["recipient_view"];

    if(!recipientView) {
      for (MessageData message in messages) {
        message.isRead = true;
      }
    }

    Future.delayed(Duration.zero, () => notifyListeners());
  }

}