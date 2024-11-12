import 'package:flutter/material.dart';

import 'package:rakhsa/features/auth/domain/usecases/login.dart';

class LoginNotifier with ChangeNotifier {
  final LoginUseCase loginUseCase;

  LoginNotifier({
    required this.loginUseCase
  });

  Future<void> login({
    required String value, 
    required String password
  }) async {
    try {
        
    } catch(e) {
      debugPrint(e.toString());
    }
  }

}