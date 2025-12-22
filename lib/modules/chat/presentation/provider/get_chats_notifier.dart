import 'package:flutter/material.dart';

import 'package:rakhsa/core/enums/provider_state.dart';

import 'package:rakhsa/modules/chat/data/models/chats.dart';

import 'package:rakhsa/modules/chat/domain/usecases/get_chats.dart';

class GetChatsNotifier with ChangeNotifier {
  final GetChatsUseCase useCase;

  GetChatsNotifier({required this.useCase});

  List<ChatsData> _chats = [];
  List<ChatsData> get chats => [..._chats];

  ProviderState _state = .loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  Future<void> getChats() async {
    final result = await useCase.execute();

    result.fold(
      (l) {
        _message = l.message;
        setStateProvider(.error);
      },
      (r) {
        _chats = [];
        _chats.addAll(r.data);
        setStateProvider(.loaded);
      },
    );
  }
}
