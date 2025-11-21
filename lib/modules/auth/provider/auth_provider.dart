import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';
import 'package:rakhsa/service/location/location_service.dart';
import 'package:rakhsa/service/notification/notification_manager.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/misc/client/errors/exceptions/exceptions.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/repositories/auth/auth_repository.dart';
import 'package:rakhsa/repositories/user/user_repository.dart';
import 'package:rakhsa/service/socket/socketio.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  // state
  RequestState _loginState = RequestState.idle;
  RequestState _registerState = RequestState.idle;
  RequestState _forgotPassState = RequestState.idle;

  // error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // getter
  RequestState get loginState => _loginState;
  RequestState get registerState => _registerState;
  RequestState get forgotPassState => _forgotPassState;
  bool get loginLoading => _loginState == RequestState.loading;
  bool get registerLoading => _registerState == RequestState.loading;
  bool get forgotPassLoading => _forgotPassState == RequestState.loading;

  // login
  Future<void> login({
    required String phone,
    required String password,
    VoidCallback? onSuccess,
    Function(String? message, String? errorCode)? onError,
  }) async {
    _loginState = RequestState.loading;
    notifyListeners();

    try {
      final newSession = await _repository.login(phone, password);

      await StorageHelper.saveUserSession(newSession);

      _loginState = RequestState.success;
      notifyListeners();
      onSuccess?.call();
    } on NetworkException catch (e) {
      _loginState = RequestState.error;
      _errorMessage = e.message;
      notifyListeners();
      onError?.call(e.message, e.errorCode);
    }
  }

  // register
  Future<void> register({
    required String fullname,
    required String phone,
    required String password,
    VoidCallback? onSuccess,
    Function(String? message, String? errorCode)? onError,
  }) async {
    _registerState = RequestState.loading;
    notifyListeners();

    try {
      final newSession = await _repository.register(fullname, phone, password);

      await StorageHelper.saveUserSession(newSession);

      _registerState = RequestState.success;
      notifyListeners();
      onSuccess?.call();
    } on NetworkException catch (e) {
      _registerState = RequestState.error;
      _errorMessage = e.message;
      notifyListeners();
      onError?.call(e.message, e.errorCode);
    }
  }

  // forgotPassword
  Future<void> forgotPassword({
    required String phone,
    required String newPassword,
    VoidCallback? onSuccess,
    Function(String? message, String? errorCode)? onError,
  }) async {
    _forgotPassState = RequestState.loading;
    notifyListeners();

    try {
      await _repository.forgotPassword(phone, newPassword);

      _forgotPassState = RequestState.success;
      notifyListeners();
      onSuccess?.call();
    } on NetworkException catch (e) {
      _forgotPassState = RequestState.error;
      _errorMessage = e.message;
      notifyListeners();
      onError?.call(e.message, e.errorCode);
    }
  }

  // logout
  Future<void> logout(BuildContext c) async {
    final socketService = c.read<SocketIoService>();
    final locationProvider = c.read<LocationProvider>();

    // pre-logout // leave socket > send latest location > clear time session
    final uid = StorageHelper.session?.user.id;
    if (uid != null) {
      socketService.socket?.emit("leave", {"user_id": uid});
      socketService.close();
      await _repository.logout(uid);
      await NotificationManager().dismissAllNotification();
      await sendLatestLocation(
        "User Logout",
        otherSource: locationProvider.location,
      );
    }

    // logout -> hapus session + user
    await StorageHelper.removeUserSession();
    await StorageHelper.delete(UserRepository.cacheKey);
  }
}
