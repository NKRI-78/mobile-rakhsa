
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/event/data/models/list.dart';
import 'package:rakhsa/features/event/domain/usecases/list_event.dart';

class ListEventNotifier extends ChangeNotifier {
  final ListEventUseCase useCase;

  ListEventNotifier({required this.useCase});

  List<EventData> _entity = [];
  List<EventData> get entity => [..._entity];

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> send({
    required File file,
    required String folderName
  }) async {
    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute();
    result.fold((l) {
      _state = ProviderState.error;
      _message = l.message;
      debugPrint(l.message);
    }, (r) {
      _state = ProviderState.loaded;
      _entity = [];
      _entity.addAll(r.data);
    });
    notifyListeners();
  }
}