import 'package:flutter/material.dart';

import 'package:rakhsa/core/enums/provider_state.dart';

import 'package:rakhsa/modules/chat/data/models/inbox.dart';

import 'package:rakhsa/modules/chat/domain/usecases/get_inbox.dart';

class GetInboxNotifier with ChangeNotifier {
  final GetInboxUseCase useCase;

  GetInboxNotifier({required this.useCase});

  List<InboxData> _inbox = [];
  List<InboxData> get inbox => [..._inbox];

  ProviderState _state = .loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  Future<void> getInbox() async {
    final result = await useCase.execute();

    result.fold(
      (l) {
        _message = l.message;
        setStateProvider(.error);
      },
      (r) {
        _inbox = [];
        _inbox.addAll(r.data);
        setStateProvider(.loaded);

        if (inbox.isEmpty) {
          setStateProvider(.empty);
        }
      },
    );
  }
}
