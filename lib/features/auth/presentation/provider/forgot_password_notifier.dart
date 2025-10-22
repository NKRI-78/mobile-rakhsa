import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';

import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/domain/usecases/forgot_password.dart';
import 'package:rakhsa/modules/auth/page/login_page.dart';

class ForgotPasswordNotifier with ChangeNotifier {
  final ForgotPasswordUseCase useCase;

  final AuthModel _authModel = AuthModel();
  AuthModel get authModel => _authModel;

  String _message = "";
  String get message => _message;

  ProviderState _providerState = ProviderState.idle;
  ProviderState get providerState => _providerState;

  ForgotPasswordNotifier({required this.useCase});

  void setStateProviderState(ProviderState param) {
    _providerState = param;

    notifyListeners();
  }

  Future<void> forgotPassword({
    required BuildContext context,
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    setStateProviderState(ProviderState.loading);

    final forgotPassword = await useCase.execute(
      email: email,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    forgotPassword.fold(
      (l) {
        debugPrint(l.message);
        _message = l.message;
        ShowSnackbar.snackbarErr(message);
        setStateProviderState(ProviderState.error);
      },
      (r) {
        ShowSnackbar.snackbarOk("Kata sandi telah berhasil diubah");
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        });
        setStateProviderState(ProviderState.loaded);
      },
    );
  }
}
