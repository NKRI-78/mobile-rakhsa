import 'package:flutter/material.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/domain/usecases/resend_otp.dart';


class ResendOtpNotifier with ChangeNotifier {
  final ResendOtpUseCase useCase;

  final AuthModel _authModel = AuthModel();
  AuthModel get authModel => _authModel;

  String _message = "";
  String get message => _message;

  ProviderState _providerState = ProviderState.idle; 
  ProviderState get providerState => _providerState;

  ResendOtpNotifier({
    required this.useCase
  });

  void setStateProviderState(ProviderState param) {
    _providerState = param;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> resendOtp({
    required String email,
  }) async {
    setStateProviderState(ProviderState.loading);

    final resendOtp = await useCase.execute(
      email: email,
    );

    resendOtp.fold(
      (l) { 
        _message = l.message;
        setStateProviderState(ProviderState.error);
      }, (r) {
        ShowSnackbar.snackbarOk("Kode OTP telah dikirim ulang kepada E-mail $email");
        setStateProviderState(ProviderState.loaded);
      }
    );
  }

}