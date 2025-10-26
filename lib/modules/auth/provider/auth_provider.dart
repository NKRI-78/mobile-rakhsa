import 'package:flutter/material.dart';
import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/misc/client/errors/exceptions.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/repositories/auth/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  // state
  RequestState _loginState = RequestState.idle;
  RequestState _registerState = RequestState.idle;

  // error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // getter
  RequestState get loginState => _loginState;
  RequestState get registerState => _registerState;
  bool get loginLoading => _loginState == RequestState.loading;
  bool get registerLoading => _registerState == RequestState.loading;

  // login
  Future<void> login({
    required String phone,
    required String password,
    VoidCallback? onSuccess,
    Function(int code, String message)? onError,
  }) async {
    _loginState = RequestState.loading;
    notifyListeners();

    try {
      final newSession = await _repository.login(phone, password);

      await StorageHelper.saveUserSession(newSession);

      _loginState = RequestState.success;
      notifyListeners();
      onSuccess?.call();
    } on ClientException catch (e) {
      _loginState = RequestState.error;
      _errorMessage = e.message;
      notifyListeners();
      onError?.call(e.code, e.message);
    }
  }

  // register
  Future<void> register({
    required String fullname,
    required String phone,
    required String password,
    VoidCallback? onSuccess,
    Function(int code, String message)? onError,
  }) async {
    _registerState = RequestState.loading;
    notifyListeners();

    try {
      final newSession = await _repository.register(fullname, phone, password);

      await StorageHelper.saveUserSession(newSession);

      _registerState = RequestState.success;
      notifyListeners();
      onSuccess?.call();
    } on ClientException catch (e) {
      _registerState = RequestState.error;
      _errorMessage = e.message;
      notifyListeners();
      onError?.call(e.code, e.message);
    }
  }

  // logout
  Future<void> logout() => _repository.logout();
}
