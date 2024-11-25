import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/dashboard/domain/usecases/expire_sos.dart';

class SosNotifier with ChangeNotifier {
  final ExpireSosUseCase useCase;

  SosNotifier({
    required this.useCase
  });  

  late AnimationController pulseController;
  late AnimationController timerController;  

  late Animation<double> pulseAnimation;

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void stopTimer() {
    timerController.stop();

    notifyListeners();
  }

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  Future<void> expireSos({required String sosId}) async {
    final result = await useCase.execute(sosId: sosId);

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {
      setStateProvider(ProviderState.loaded);
    });
  }

  
}