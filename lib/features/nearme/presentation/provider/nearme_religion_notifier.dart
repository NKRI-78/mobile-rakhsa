import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/nearme/domain/usecases/get_place_nearby.dart';

class GetNearbyPlaceReligionNotifier extends ChangeNotifier {
  final GetPlaceNearbyUseCase useCase;

  GetNearbyPlaceReligionNotifier({required this.useCase});

  List<Map<String, dynamic>> _entity = [];
  List<Map<String, dynamic>> get entity => [..._entity];

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> getNearmeReligion({
    required String keyword,
    required double currentLat,
    required double currentLng,
  }) async {
    final List<String> types = ['mosque', 'church', 'hindu_temple'];
    _state = ProviderState.loading;
    notifyListeners();

    _entity.clear(); 

    for (final type in types) {
      final result = await useCase.execute(
        keyword: keyword,
        currentLat: currentLat,
        currentLng: currentLng,
        type: type,
      );
      debugPrint(currentLat.toString());
      debugPrint(currentLng.toString());


      result.fold(
        (l) {
          _state = ProviderState.error;
          _message = l.message;
          notifyListeners();
        },
        (r) {
          debugPrint(r.status);
          for (var el in r.results) {
            String name = el.name;
            debugPrint(name.toString());
          }
          // Add type-specific results
          // _entity.addAll(r.map((place) => {
          //   'type': type,
          //   'data': place, // Assuming `place` is your entity data
          // }));
        },
      );
    }

    if (_state != ProviderState.error) {
      _state = ProviderState.loaded;
    }
    notifyListeners();
  }
}