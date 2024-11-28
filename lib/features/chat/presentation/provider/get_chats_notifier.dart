import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/chat/data/models/chats.dart';

import 'package:rakhsa/features/chat/domain/usecases/get_chats.dart';

class GetChatsNotifier with ChangeNotifier {
  final GetChatsUseCase useCase;

  GetChatsNotifier({
    required this.useCase
  });  

  List<ChatsData> _chats = [];
  List<ChatsData> get chats => [..._chats];

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> getChats() async {
    final result = await useCase.execute();

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {

      _chats = [];
      _chats.addAll(r.data);

      setStateProvider(ProviderState.loaded);
    });
  }

  void appendMessage({required Map<String, dynamic> data}) {
    bool isMe = data["data"]["user"]["is_me"];
    bool isRead = data["data"]["is_read"];

    int chatIndex = chats.indexWhere((el) => el.chat.id == data["data"]["chat_id"]);

    if(chatIndex != -1) {

      _chats[chatIndex].messages.insert(0, Message(
        id: data["data"]["id"],
        content: data["data"]["text"],
        isRead: isRead,
        isMe: isMe,
        time: data["data"]["sent_time"],
        type: data["data"]["type"]
      ));

      _chats[chatIndex].countUnread += 1;

    }

    Future.delayed(Duration.zero, () => notifyListeners());
  }
  
}