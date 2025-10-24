import 'package:flutter/material.dart';

import 'package:rakhsa/misc/helpers/enum.dart';

import 'package:rakhsa/features/auth/data/models/auth.dart';

import 'package:rakhsa/features/auth/domain/usecases/update_is_loggedin.dart';

class UpdateIsLoggedinNotifier with ChangeNotifier {
  final UpdateIsLoggedinUseCase useCase;

  final AuthModel _authModel = AuthModel();
  AuthModel get authModel => _authModel;

  String _message = "";
  String get message => _message;

  ProviderState _providerState = ProviderState.idle;
  ProviderState get providerState => _providerState;

  UpdateIsLoggedinNotifier({required this.useCase});

  void setStateProviderState(ProviderState param) {
    _providerState = param;

    notifyListeners();
  }

  Future<void> updateIsLoggedIn({
    required String userId,
    required String type,
  }) async {
    setStateProviderState(ProviderState.loading);

    final resendOtp = await useCase.execute(userId: userId, type: type);

    resendOtp.fold(
      (l) {
        _message = l.message;
        setStateProviderState(ProviderState.error);
      },
      (r) {
        _message = "";
        setStateProviderState(ProviderState.loaded);
      },
    );
  }
}
