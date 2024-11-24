import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/administration/data/models/state.dart';
import 'package:rakhsa/features/administration/domain/usecases/get_state.dart';

class GetStateNotifier with ChangeNotifier {
  final GetStateUseCase useCase;

  List<StateData> _entity = [];
  List<StateData> get entity => [..._entity];

  String _message = "";
  String get message => _message;

  ProviderState _providerState = ProviderState.idle; 
  ProviderState get providerState => _providerState;

  GetStateNotifier({
    required this.useCase
  });

  void setStateProviderState(ProviderState param) {
    _providerState = param;

    notifyListeners();
  }

  Future<void> getState({required int continentId}) async {
    setStateProviderState(ProviderState.loading);

    final state = await useCase.execute(
      continentId: continentId
    );
    
    state.fold(
      (l) { 
        _message = l.message;
        setStateProviderState(ProviderState.error);
      }, (r) {

        _entity = [];
        _entity = r.data;

        setStateProviderState(ProviderState.loaded);
      }
    );
   
  }

}