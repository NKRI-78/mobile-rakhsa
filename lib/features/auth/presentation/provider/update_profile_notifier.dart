import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/auth/domain/usecases/update_profile.dart';

class UpdateProfileNotifier with ChangeNotifier {
  final UpdateProfileUseCase useCase;

  String _message = "";
  String get message => _message;

  ProviderState _state = ProviderState.loading; 
  ProviderState get state => _state;

  UpdateProfileNotifier({
    required this.useCase
  });

  void setStateProviderState(ProviderState param) {
    _state = param;

    notifyListeners();
  }

  Future<void> updateProfile({required String avatar}) async {
    setStateProviderState(ProviderState.loading);

    final profile = await useCase.execute(
      avatar: avatar,
    );
    
    profile.fold(
      (l) { 
        _message = l.message;
        setStateProviderState(ProviderState.error);
      }, (r) {
        setStateProviderState(ProviderState.loaded);
      }
    );

  }

}