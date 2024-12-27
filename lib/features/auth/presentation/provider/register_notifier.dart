import 'package:flutter/material.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/features/auth/data/models/auth.dart';

import 'package:rakhsa/features/auth/domain/usecases/register.dart';
import 'package:rakhsa/features/auth/presentation/pages/register_otp.dart';

import 'package:rakhsa/global.dart';
import 'package:rakhsa/websockets.dart';

class RegisterNotifier with ChangeNotifier {
  final WebSocketsService webSocketsService;
  final RegisterUseCase useCase;

  AuthModel _authModel = AuthModel();
  AuthModel get authModel => _authModel;

  String _message = "";
  String get message => _message;

  ProviderState _providerState = ProviderState.idle; 
  ProviderState get providerState => _providerState;

  RegisterNotifier({
    required this.webSocketsService,
    required this.useCase
  });

  void setStateProviderState(ProviderState param) {
    _providerState = param;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> register({
    required String fullname,
    required String email,
    required String phone,
    required String passport,
    required String emergencyContact,
    required String password
  }) async {
    setStateProviderState(ProviderState.loading);

    final register = await useCase.execute(
      fullname: fullname,
      email: email,
      phone: phone,
      passport: passport,
      emergencyContact: emergencyContact,
      password: password,
    );
    
    register.fold(
      (l) { 
        _message = l.message;
        setStateProviderState(ProviderState.error);
      }, (r) {

        _authModel = r;

        StorageHelper.saveUserId(userId: authModel.data?.user.id ?? "-");

        webSocketsService.join();

        ShowSnackbar.snackbarOk("Silahkan periksa alamat E-mail $email untuk mengisi kode otp yang telah dikirimkan");

        Navigator.pushAndRemoveUntil(navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) {
            return RegisterOtp(email: email);
          }),
          (route) => false,
        );

        setStateProviderState(ProviderState.loaded);
      }
    );
   
  }

}