import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/chat/data/models/inbox.dart';

import 'package:rakhsa/features/chat/domain/usecases/get_inbox.dart';

class GetInboxNotifier with ChangeNotifier {
  final GetInboxUseCase useCase;

  GetInboxNotifier({
    required this.useCase
  });  

  List<InboxData> _inbox = [];
  List<InboxData> get inbox => [..._inbox];

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> getInbox() async {
    final result = await useCase.execute();

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {
      _inbox = [];
      _inbox.addAll(r.data);
      setStateProvider(ProviderState.loaded);

      if(inbox.isEmpty) {
        setStateProvider(ProviderState.empty);
      }
    });
  }
  
}