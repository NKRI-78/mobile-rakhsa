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

  ProviderState _state = ProviderState.idle; 
  ProviderState get state => _state;

  GetContinentNotifier({
    required this.useCase
  });

  void setStateProviderState(ProviderState param) {
    _state = param;

    notifyListeners();
  }

  Future<void> getContinent() async {
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