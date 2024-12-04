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

  CountryData? selectedContinent;

  void setSelectedContinent(CountryData continent) {
    selectedContinent = continent;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void updateContinent(String continent) {

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  GetContinentNotifier({
    required this.useCase
  });

  void setStateProviderState(ProviderState param) {
    _state = param;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> getContinent({required int continentId}) async {
    setStateProviderState(ProviderState.loading);

    final continent = await useCase.execute();
    
    continent.fold(
      (l) { 
        _message = l.message;
        setStateProviderState(ProviderState.error);
      }, (r) {

        _entity = [];
        _entity = r.data;

        if (entity.isNotEmpty) {
          if(continentId != -1) {
            selectedContinent = _entity.where((el) => el.id == continentId).first;
          } else {
            selectedContinent = entity.first;
          }
        }

        setStateProviderState(ProviderState.loaded);
      }
    );
   
  }

}