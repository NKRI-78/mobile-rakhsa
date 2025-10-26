import 'package:flutter/material.dart';

import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/modules/information/data/models/kbri.dart';

import 'package:rakhsa/modules/information/domain/usecases/get_kbri_id.dart';

class KbriIdNotifier extends ChangeNotifier {
  final GetKbriIdUseCase useCase;

  KbriIdNotifier({required this.useCase});

  KbriInfoModel _entity = KbriInfoModel();
  KbriInfoModel get entity => _entity;

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> infoKbri({required String stateId}) async {
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
