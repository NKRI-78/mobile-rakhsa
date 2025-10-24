import 'package:flutter/material.dart';

import 'package:rakhsa/misc/helpers/enum.dart';

import 'package:rakhsa/features/chat/data/models/chats.dart';

import 'package:rakhsa/features/chat/domain/usecases/get_chats.dart';

class GetChatsNotifier with ChangeNotifier {
  final GetChatsUseCase useCase;

  GetChatsNotifier({required this.useCase});

  List<ChatsData> _chats = [];
  List<ChatsData> get chats => [..._chats];

  ProviderState _state = ProviderState.loading;
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
        setStateProvider(ProviderState.error);
      },
      (r) {
        _chats = [];
        _chats.addAll(r.data);
        setStateProvider(ProviderState.loaded);

        if (chats.isEmpty) {
          setStateProvider(ProviderState.empty);
        }
      },
    );
  }
}
