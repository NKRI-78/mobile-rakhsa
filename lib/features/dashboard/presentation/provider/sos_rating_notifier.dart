import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/dashboard/domain/usecases/sos_rating.dart';

class SosRatingNotifier with ChangeNotifier {
  final SosRatingUseCase useCase;

  SosRatingNotifier({
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

  Future<void> sosRating({
    required String sosId,
    required String rating,
    required String userId
  }) async {
    setStateProvider(ProviderState.loading);

    final result = await useCase.execute(
      sosId: sosId,
      rating: rating,
      userId: userId,
    );

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {
      setStateProvider(ProviderState.loaded);
    });
  }
  
}