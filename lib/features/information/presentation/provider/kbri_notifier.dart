import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/features/information/data/models/kbri.dart';

import 'package:rakhsa/features/information/domain/usecases/get_kbri.dart';

class KbriNotifier extends ChangeNotifier {
  final GetKbriUseCase useCase;

  KbriNotifier({required this.useCase});

  KbriInfoModel _entity = KbriInfoModel();
  KbriInfoModel get entity => _entity;

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> infoKbri({
    required String stateId
  }) async {
    _state = ProviderState.loading;
    Future.delayed(Duration.zero, () => notifyListeners());

    final result = await useCase.execute(
      stateId: stateId
    );
    result.fold((l) {
      _state = ProviderState.error;
      Future.delayed(Duration.zero, () => notifyListeners());
      
      _message = l.message;
    }, (r) {
      _entity = r;

      _state = ProviderState.loaded;
      Future.delayed(Duration.zero, () => notifyListeners());
    });
  }
}