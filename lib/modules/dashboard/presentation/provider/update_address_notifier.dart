import 'package:flutter/material.dart';

import 'package:rakhsa/core/enums/provider_state.dart';

import 'package:rakhsa/modules/dashboard/domain/usecases/update_address.dart';

class UpdateAddressNotifier with ChangeNotifier {
  final UpdateAddressUseCase useCase;

  UpdateAddressNotifier({required this.useCase});

  ProviderState _state = .idle;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  Future<void> updateAddress({
    required String address,
    required String state,
    required double lat,
    required double lng,
  }) async {
    setStateProvider(.loading);

    final result = await useCase.execute(
      address: address,
      state: state,
      lat: lat,
      lng: lng,
    );

    result.fold(
      (l) {
        _message = l.message;
        setStateProvider(.error);
      },
      (r) {
        setStateProvider(.loaded);
      },
    );
  }
}
