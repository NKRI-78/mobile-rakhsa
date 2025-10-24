import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rakhsa/misc/helpers/enum.dart';

import 'package:rakhsa/features/dashboard/domain/usecases/expire_sos.dart';

class SosNotifier with ChangeNotifier {
  final ExpireSosUseCase useCase;

  SosNotifier({required this.useCase}) {
    countdownTime = 0;
  }

  late AnimationController? pulseController;
  late AnimationController? timerController;

  late Animation<double> pulseAnimation;

  Timer? holdTimer;

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

    notifyListeners();
  }

  void initializePulse(TickerProvider vsync) {
    pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: vsync,
    );

    pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 2.5,
    ).animate(CurvedAnimation(parent: pulseController!, curve: Curves.easeOut));

    // notifyListeners();
  }

  void resetAnimation() {
    pulseController!.reset();

    notifyListeners();
  }

  void initializeTimer(TickerProvider vsync) {
    timerController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: vsync,
    );

    timerController!.addListener(() {
      countdownTime = (60 - timerController!.value * 60).round();
      notifyListeners();
    });

    if (countdownTime > 0) {
      final elapsedTime = (60 - countdownTime) / 60;
      timerController!.value = elapsedTime;
      notifyListeners();
    }
  }

  void resumeTimer() {
    timerController!.forward().whenComplete(() {
      pulseController!.reverse();
      notifyListeners();

      isPressed = false;
      notifyListeners();
    });

    notifyListeners();
  }

  void startTimer() {
    isPressed = true;
    notifyListeners();

    pulseController!.reverse();
    notifyListeners();

    timerController!
      ..reset()
      ..forward().whenComplete(() {
        pulseController!.reverse();
        notifyListeners();

        isPressed = false;
        notifyListeners();
      });

    notifyListeners();
  }

  void stopTimer() {
    isPressed = false;

    timerController?.stop();
    timerController?.reset();

    notifyListeners();
  }

  Future<void> expireSos({required String sosId}) async {
    setStateProvider(ProviderState.loading);

    final result = await useCase.execute(sosId: sosId);

    result.fold(
      (l) {
        _message = l.message;
        setStateProvider(ProviderState.error);
      },
      (r) {
        setStateProvider(ProviderState.loaded);
      },
    );
  }
}
