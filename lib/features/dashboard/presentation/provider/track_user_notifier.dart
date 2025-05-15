import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/dashboard/domain/usecases/track_user.dart';

class TrackUserNotifier with ChangeNotifier {
  final TrackUserUseCase useCase;

  TrackUserNotifier({required this.useCase});

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  Future<void> trackUser({
    required String address,
    required double lat,
    required double lng
  }) async {
    setStateProvider(ProviderState.loading);

    final result = await useCase.execute(
      address: address,
      lat: lat,
      lng: lng
    );

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {
      setStateProvider(ProviderState.loaded);
    });
  }
  
}