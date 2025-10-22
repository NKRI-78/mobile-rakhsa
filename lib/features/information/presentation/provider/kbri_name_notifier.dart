import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/information/data/models/kbri.dart';
import 'package:rakhsa/features/information/domain/usecases/get_kbri_name.dart';

class KbriNameNotifier extends ChangeNotifier {
  final GetKbriNameUseCase useCase;

  KbriNameNotifier({required this.useCase});

  KbriInfoModel _entity = KbriInfoModel();
  KbriInfoModel get entity => _entity;

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> infoKbri() async {
    _state = ProviderState.loading;
    notifyListeners();

    String stateName = StorageHelper.getUserNationality() ?? "-";

    final result = await useCase.execute(stateName: stateName);
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
