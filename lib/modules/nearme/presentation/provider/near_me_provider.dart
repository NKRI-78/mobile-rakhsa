import 'package:flutter/material.dart';
import 'package:rakhsa/core/client/errors/errors.dart';

import 'package:rakhsa/repositories/location/model/location_data.dart';
import 'package:rakhsa/repositories/nearme/nearme_repository.dart';

import 'near_me_state.dart';
export 'near_me_state.dart';

class NearMeProvider extends ChangeNotifier {
  final NearMeRepository _repository;

  NearMeProvider(this._repository);

  var _state = NearMeState();
  NearMeState get state => _state;

  void _setState(NearMeState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> fetchNearbyPlaces(String type, Coord coord) async {
    // if (_state.places.hasType(type)) {
    //   _setState(_state.copyWith(state: RequestState.success));
    //   return;
    // }

    _setState(_state.copyWith(state: .loading));
    try {
      final newPlaces = await _repository.fetchNearbyPlaces(type, coord);
      _setState(_state.copyWith(state: .success, places: newPlaces));
    } on NetworkException catch (e) {
      _setState(
        _state.copyWith(
          state: .error,
          error: ErrorState(title: e.title, message: e.message),
        ),
      );
    }
  }
}
