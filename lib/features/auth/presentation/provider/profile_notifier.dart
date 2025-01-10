import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/auth/data/models/profile.dart';
import 'package:rakhsa/features/auth/domain/usecases/profile.dart';

class ProfileNotifier with ChangeNotifier {
  final ProfileUseCase useCase;

  ProfileModel _entity = ProfileModel();
  ProfileModel get entity => _entity;

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
    Future.delayed(Duration.zero,() => notifyListeners());
  }

  Future<void> getProfile() async {
    final profile = await useCase.execute();
    
    profile.fold(
      (l) { 
        _message = l.message;
        setStateProviderState(ProviderState.error);
      }, (r) {
        _entity = r;
        setStateProviderState(ProviderState.loaded);
      }
    );

  }

}