import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/dashboard/domain/usecases/update_address.dart';

class UpdateAddressNotifier with ChangeNotifier {
  final UpdateAddressUseCase useCase;

  UpdateAddressNotifier({
    required this.useCase
  });

  late AnimationController? pulseController;
  late AnimationController? timerController;  

  late Animation<double> pulseAnimation;

  late int countdownTime;

  bool isPressed = false;

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> updateAddress({
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