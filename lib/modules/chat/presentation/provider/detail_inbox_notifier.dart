import 'package:flutter/material.dart';

import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/modules/chat/data/models/detail_inbox.dart';

import 'package:rakhsa/modules/chat/domain/usecases/detail_inbox.dart';

class DetailInboxNotifier with ChangeNotifier {
  final DetailInboxUseCase useCase;

  DetailInboxNotifier({required this.useCase});

  InboxDetailData _inbox = InboxDetailData();
  InboxDetailData get inbox => _inbox;

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  Future<void> getInbox({required int id}) async {
    final result = await useCase.execute(id: id);

    result.fold(
      (l) {
        _message = l.message;
        setStateProvider(ProviderState.error);
      },
      (r) {
        _inbox = r.data;
        setStateProvider(ProviderState.loaded);
      },
    );
  }
}
