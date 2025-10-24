import 'package:flutter/material.dart';

import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/misc/helpers/storage.dart';

import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/domain/usecases/verify_otp.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';

import 'package:rakhsa/global.dart';

class VerifyOtpNotifier with ChangeNotifier {
  final VerifyOtpUseCase useCase;

  final AuthModel _authModel = AuthModel();
  AuthModel get authModel => _authModel;

  String _message = "";
  String get message => _message;

  bool _onCompletedOtp = false;
  bool get onCompletedOtp => _onCompletedOtp;

  String valueOtp = "";

  ProviderState _providerState = ProviderState.idle;
  ProviderState get providerState => _providerState;

  VerifyOtpNotifier({required this.useCase});

  void setStateProviderState(ProviderState param) {
    _providerState = param;

    notifyListeners();
  }

  void onStartTimerOtp() {
    _onCompletedOtp = false;

    notifyListeners();
  }

  void onCompletedTimerOtp() {
    _onCompletedOtp = true;

    notifyListeners();
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    setStateProviderState(ProviderState.loading);

    final verifyOtp = await useCase.execute(email: email, otp: otp);

    verifyOtp.fold(
      (l) {
        _message = l.message;
        setStateProviderState(ProviderState.error);
      },
      (r) {
        StorageHelper.saveToken(token: authModel.data?.token ?? "-");

        Navigator.pushAndRemoveUntil(
          navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (context) {
              return const DashboardScreen();
            },
          ),
          (route) => false,
        );

        setStateProviderState(ProviderState.loaded);
      },
    );
  }
}
