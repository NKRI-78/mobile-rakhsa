import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/features/event/data/models/detail.dart';
import 'package:rakhsa/features/event/domain/usecases/detail_event.dart';

class DetailEventNotifier extends ChangeNotifier {
  final DetailEventUseCase useCase;

  DetailEventNotifier({required this.useCase});

  EventDetailData _entity = EventDetailData();
  EventDetailData get entity => _entity;

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> find({
    required int id
  }) async {
    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute(
      id: id
    );
    result.fold((l) {
      _state = ProviderState.error;
      _message = l.message;
    }, (r) {
      _entity = r.data;
      _state = ProviderState.loaded;
    });
    notifyListeners();
  }
}