import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/auth/data/models/profile.dart';
import 'package:rakhsa/features/auth/domain/usecases/profile.dart';

class ProfileNotifier with ChangeNotifier {
  final ProfileUseCase useCase;

  ProfileModel _profileModel = ProfileModel();
  ProfileModel get profileModel => _profileModel;

  String _message = "";
  String get message => _message;

  ProviderState _state = ProviderState.loading; 
  ProviderState get state => _state;

  ProfileNotifier({
    required this.useCase
  });

  void setStateProviderState(ProviderState param) {
    _state = param;

    notifyListeners();
  }

  Future<void> getProfile() async {
    setStateProviderState(ProviderState.loading);

    final profile = await useCase.execute();
    
    profile.fold(
      (l) { 
        _message = l.message;
        setStateProviderState(ProviderState.error);
      }, (r) {
        _profileModel = r;
      }
    );

    setStateProviderState(ProviderState.loaded);
  }

}