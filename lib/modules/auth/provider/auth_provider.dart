import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';
import 'package:rakhsa/service/location/location_service.dart';
import 'package:rakhsa/service/notification/notification_manager.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/core/client/errors/exceptions/exceptions.dart';
import 'package:rakhsa/core/enums/request_state.dart';
import 'package:rakhsa/repositories/auth/auth_repository.dart';
import 'package:rakhsa/repositories/user/user_repository.dart';
import 'package:rakhsa/service/socket/socketio.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  // state
  RequestState _loginState = .idle;
  RequestState _registerState = .idle;
  RequestState _forgotPassState = .idle;

  // error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // getter
  RequestState get loginState => _loginState;
  RequestState get registerState => _registerState;
  RequestState get forgotPassState => _forgotPassState;
  bool get loginLoading => _loginState == .loading;
  bool get registerLoading => _registerState == .loading;
  bool get forgotPassLoading => _forgotPassState == .loading;

  // login
  Future<void> login({
    required String phone,
    required String password,
    VoidCallback? onSuccess,
    Function(String? title, String? message, String? errorCode)? onError,
  }) async {
    _loginState = .loading;
    notifyListeners();

    try {
      final newSession = await _repository.login(phone, password);

      await StorageHelper.saveUserSession(newSession);

      _loginState = .success;
      notifyListeners();
      onSuccess?.call();
    } on NetworkException catch (e) {
      _loginState = .error;
      _errorMessage = e.message;
      notifyListeners();
      onError?.call(e.title, e.message, e.errorCode);
    }
  }

  // register
  Future<void> register({
    required String fullname,
    required String phone,
    required String password,
    Function(String uid)? onSuccess,
    Function(String? message, String? errorCode)? onError,
  }) async {
    _registerState = .loading;
    notifyListeners();

    try {
      final newSession = await _repository.register(fullname, phone, password);

      await StorageHelper.saveUserSession(newSession);

      _registerState = .success;
      notifyListeners();
      onSuccess?.call(newSession.user.id);
    } on NetworkException catch (e) {
      _registerState = .error;
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
    _forgotPassState = .loading;
    notifyListeners();

    try {
      await _repository.forgotPassword(phone, newPassword);

      _forgotPassState = .success;
      notifyListeners();
      onSuccess?.call();
    } on NetworkException catch (e) {
      _forgotPassState = .error;
      _errorMessage = e.message;
      notifyListeners();
      onError?.call(e.message, e.errorCode);
    }
  }

  bool userIsLoggedIn() => StorageHelper.isLoggedIn();

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
      await NotificationManager().dismissChatsNotification();
      await sendLatestLocation(
        "User Logout",
        otherSource: locationProvider.location,
      );
    }

    // logout -> hapus session + user
    await StorageHelper.removeUserSession();
    await StorageHelper.delete(UserRepository.cacheKey);
  }

  Future<void> completeOnBoarding() {
    return StorageHelper.prefs.setBool("on_boarding_cache_key", true);
  }

  bool showOnBoarding() {
    final containKeyOnBoarding =
        StorageHelper.prefs.getBool("on_boarding_cache_key") ?? false;
    return !containKeyOnBoarding;
  }
}
