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

  StateData? selectedState;

  void setSelectedState(StateData state) {
    selectedState = state;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void updateState(String state) {

    Future.delayed(Duration.zero, () => notifyListeners());
  }


  GetStateNotifier({
    required this.useCase
  });

  void setStateProviderState(ProviderState param) {
    _providerState = param;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> getState({
    required int continentId,
    required int stateId
  }) async {
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

        if (entity.isNotEmpty) {
          if(stateId != -1) {
            selectedState = _entity.where((el) => el.id == stateId).first;
          } else {
            selectedState = entity.first;
          }
        }

        setStateProviderState(ProviderState.loaded);
      }
    );
   
  }

}