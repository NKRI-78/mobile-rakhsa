import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/administration/data/models/continent.dart';
import 'package:rakhsa/features/administration/domain/usecases/get_continent.dart';

class GetContinentNotifier with ChangeNotifier {
  final GetContinentUseCase useCase;

  List<CountryData> _entity = [];
  List<CountryData> get entity => [..._entity];

  String _message = "";
  String get message => _message;

  ProviderState _providerState = ProviderState.idle; 
  ProviderState get providerState => _providerState;

  GetContinentNotifier({
    required this.useCase
  });

  void setStateProviderState(ProviderState param) {
    _providerState = param;

    notifyListeners();
  }

  Future<void> login({
    required String value, 
    required String password
  }) async {
    setStateProviderState(ProviderState.loading);

    final continent = await useCase.execute();
    
    continent.fold(
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