import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/chat/domain/usecases/insert_message.dart';

class InsertMessageNotifier with ChangeNotifier {
  final InsertMessageUseCase useCase;

  InsertMessageNotifier({
    required this.useCase
  });  

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> insertMessage({required String chatId, required String recipient, required String text, required DateTime createdAt}) async {
    final result = await useCase.execute(
      chatId: chatId, 
      recipient: recipient, 
      text: text,
      createdAt: createdAt
    );

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {
      setStateProvider(ProviderState.loaded);
    });
  }
}