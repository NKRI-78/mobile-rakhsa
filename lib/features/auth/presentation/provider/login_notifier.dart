import 'package:flutter/material.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/features/auth/data/models/auth.dart';

import 'package:rakhsa/features/auth/domain/usecases/login.dart';
import 'package:rakhsa/features/auth/presentation/pages/register_otp.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';
import 'package:rakhsa/global.dart';
import 'package:rakhsa/websockets.dart';

class LoginNotifier with ChangeNotifier {
  final WebSocketsService webSocketsService;
  final LoginUseCase useCase;

  AuthModel _authModel = AuthModel();
  AuthModel get authModel => _authModel;

  String _message = "";
  String get message => _message;

  ProviderState _providerState = ProviderState.idle; 
  ProviderState get providerState => _providerState;

  LoginNotifier({
    required this.webSocketsService,
    required this.useCase
  });

  void setStateProviderState(ProviderState param) {
    _providerState = param;

    Future.delayed(Duration.zero, () => notifyListeners());
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

        StorageHelper.saveUserId(userId: authModel.data?.user.id ?? "-");
        StorageHelper.saveToken(token: authModel.data?.token ?? "-");

        webSocketsService.join();

        if(authModel.data!.user.enabled){  
          Navigator.pushAndRemoveUntil(navigatorKey.currentContext!,
            MaterialPageRoute(builder: (context) {
              return const DashboardScreen();
            }),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(navigatorKey.currentContext!,
            MaterialPageRoute(builder: (context) {
              return RegisterOtp(email: value,);
            }),
            (route) => false,
          );
        }

        setStateProviderState(ProviderState.loaded);
      }
    );
   
  }

}