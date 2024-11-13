import 'package:flutter/material.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/features/auth/data/models/auth.dart';

import 'package:rakhsa/features/auth/domain/usecases/login.dart';

class LoginNotifier with ChangeNotifier {
  final LoginUseCase useCase;

  AuthModel _authModel = AuthModel();
  AuthModel get authModel => _authModel;

  String _message = "";
  String get message => _message;

  ProviderState _providerState = ProviderState.idle; 
  ProviderState get providerState => _providerState;

  LoginNotifier({
    required this.useCase
  });

  void setStateProviderState(ProviderState param) {
    _providerState = param;

    notifyListeners();
  }

  Future<void> login({
    required String value, 
    required String password
  }) async {
    setStateProviderState(ProviderState.loading);

    final login = await useCase.execute(
      value: value, 
      password: password
    );
    
    login.fold(
      (l) { 
        _message = l.message;
        setStateProviderState(ProviderState.error);
      }, (r) {
        _authModel = r;
        setStateProviderState(ProviderState.loaded);
      }
    );
   
  }

}