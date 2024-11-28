import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/features/event/domain/usecases/delete_event.dart';

class DeleteEventNotifier extends ChangeNotifier {
  final DeleteEventUseCase useCase;

  DeleteEventNotifier({required this.useCase});

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> delete({
    required int id
  }) async {
    _state = ProviderState.loading;
    Future.delayed(Duration.zero, () => notifyListeners());

    final result = await useCase.execute(
      id: id
    );
    result.fold((l) {
      _state = ProviderState.error;
      Future.delayed(Duration.zero, () => notifyListeners());
      
      _message = l.message;
    }, (r) {
      _state = ProviderState.loaded;
      Future.delayed(Duration.zero, () => notifyListeners());
    });
  }
}