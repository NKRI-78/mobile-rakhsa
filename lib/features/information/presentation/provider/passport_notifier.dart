import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/information/data/models/passport.dart';

import 'package:rakhsa/features/information/domain/usecases/get_passport.dart';

class PassportNotifier extends ChangeNotifier {
  final GetPassportUseCase useCase;

  PassportNotifier({required this.useCase});

  PassportContentModel _entity = PassportContentModel();
  PassportContentModel get entity => _entity;

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> infoPassport({
    required String stateId
  }) async {
    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute(
      stateId: stateId
    );
    result.fold((l) {
      _state = ProviderState.error;
      notifyListeners();
      
      _message = l.message;
    }, (r) {
      _entity = r;

      _state = ProviderState.loaded;
      notifyListeners();
    });
  }
}