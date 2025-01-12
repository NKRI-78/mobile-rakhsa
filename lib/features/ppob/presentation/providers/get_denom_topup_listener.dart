

import 'package:flutter/material.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/features/ppob/domain/entities/denom_topup.dart';
import 'package:rakhsa/features/ppob/domain/usecases/get_denom_topup.dart';

class GetDenomTopupProvider with ChangeNotifier {
  final GetDenomUseCase useCase;

  GetDenomTopupProvider({
    required this.useCase
  });

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  List<DenomTopupDataListEntity> _entity = [];
  List<DenomTopupDataListEntity> get entity => [..._entity];


  Future<void> fetch() async {
    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute();

    result.fold((l) {
      _state = ProviderState.error;
      _message = l.message;
    }, (r) {

      _entity = [];
      _entity.addAll(r);
      _state = ProviderState.loaded;

      if(entity.isEmpty) {
        _message = "No data found";
        _state = ProviderState.empty;
      }
    });

    notifyListeners();
  }

}