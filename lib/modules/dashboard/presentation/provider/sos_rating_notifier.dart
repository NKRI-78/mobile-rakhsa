import 'package:flutter/material.dart';

import 'package:rakhsa/core/enums/provider_state.dart';

import 'package:rakhsa/modules/dashboard/domain/usecases/sos_rating.dart';

class SosRatingNotifier with ChangeNotifier {
  final SosRatingUseCase useCase;

  SosRatingNotifier({required this.useCase});

  late AnimationController? pulseController;
  late AnimationController? timerController;

  late Animation<double> pulseAnimation;

  late int countdownTime;

  bool isPressed = false;

  double _rating = 0.0;
  double get rating => _rating;

  ProviderState _state = .idle;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  void onChangeRating({required double selectedRating}) {
    _rating = selectedRating;

    notifyListeners();
  }

  Future<void> sosRating({required String sosId}) async {
    setStateProvider(.loading);

    final result = await useCase.execute(
      sosId: sosId,
      rating: rating.toString(),
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
