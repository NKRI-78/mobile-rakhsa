import 'package:flutter/material.dart';

import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/features/information/data/models/visa.dart';

import 'package:rakhsa/features/information/domain/usecases/get_visa.dart';

class VisaNotifier extends ChangeNotifier {
  final GetVisaUseCase useCase;

  VisaNotifier({required this.useCase});

  VisaContentModel _entity = VisaContentModel();
  VisaContentModel get entity => _entity;

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> infoVisa({required String stateId}) async {
    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute(stateId: stateId);
    result.fold(
      (l) {
        _state = ProviderState.error;
        notifyListeners();

        _message = l.message;
      },
      (r) {
        _entity = r;

        _state = ProviderState.loaded;
        notifyListeners();
      },
    );
  }
}
