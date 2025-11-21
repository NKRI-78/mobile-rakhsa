import 'package:flutter/material.dart';
import 'package:rakhsa/misc/client/errors/exceptions/exceptions.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/repositories/auth/model/user_session.dart';

import 'package:rakhsa/repositories/user/model/user.dart';
import 'package:rakhsa/repositories/user/user_repository.dart';

class UserProvider with ChangeNotifier {
  UserProvider({required UserRepository repository}) : _repository = repository;

  final UserRepository _repository;

  User? _user;
  User? get user => _user;

  UserSession? _session;

  String? _errMessage;
  String? get errMessage => _errMessage;

  RequestState _getUserState = RequestState.idle;
  RequestState get getUserState => _getUserState;

  UserSession? get session => _session;

  Future<User?> getUser({bool enableCache = false}) async {
    _getUserState = RequestState.loading;
    notifyListeners();

    final localUser = _repository.getLocalUser();
    if (enableCache && localUser != null) {
      _user = localUser;
      _getUserState = RequestState.success;
      notifyListeners();
      return localUser;
    } else {
      try {
        final uid = await StorageHelper.loadlocalSession().then((v) {
          return v?.user.id ?? "-";
        });
        final remoteUser = await _repository.getRemoteUser(uid);
        _user = remoteUser;
        _getUserState = RequestState.success;
        notifyListeners();
        return remoteUser;
      } on NetworkException catch (e) {
        _errMessage = e.message;
        _getUserState = RequestState.error;
        notifyListeners();
        return null;
      }
    }
  }
}
