import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/dashboard/domain/usecases/expire_sos.dart';

class SosNotifier with ChangeNotifier {
  final ExpireSosUseCase useCase;

  SosNotifier({
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

  bool get isTimerRunning {
    return timerController?.isAnimating ?? false;
  }

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void initializePulse(TickerProvider vsync) {
    pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: vsync,
    );

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void initializeTimer(TickerProvider vsync) {
    isPressed = false;
    
    timerController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: vsync,
    );
    
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void stopTimer() {
    isPressed = false;

    timerController?.stop();
    timerController?.reset();
    
    Future.delayed(Duration.zero, () => notifyListeners());
  } 

  Future<void> expireSos({required String sosId}) async {
    setStateProvider(ProviderState.loading);

    final result = await useCase.execute(sosId: sosId);

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {
      setStateProvider(ProviderState.loaded);
    });
  }
  
}