import 'package:flutter/material.dart';
import 'package:rakhsa/misc/client/errors/exceptions.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/misc/helpers/storage.dart';

import 'package:rakhsa/repositories/user/model/user.dart';
import 'package:rakhsa/repositories/user/user_repository.dart';

class UserProvider with ChangeNotifier {
  UserProvider({required UserRepository repository}) : _repository = repository;

  final UserRepository _repository;

  User? _user;
  User? get user => _user;

  String? _errMessage;
  String? get errMessage => _errMessage;

  RequestState _getUserState = RequestState.idle;
  RequestState get getUserState => _getUserState;

  Future<void> getUser() async {
    _getUserState = RequestState.loading;
    notifyListeners();

    final localUser = _repository.getLocalUser();
    if (localUser != null) {
      _user = localUser;
      _getUserState = RequestState.success;
      notifyListeners();
    } else {
      try {
        final uid = await StorageHelper.getUserSession().then(
          (v) => v?.user.id ?? "-",
        );
        final remoteUser = await _repository.getRemoteUser(uid);
        _user = remoteUser;
        _getUserState = RequestState.success;
        notifyListeners();
      } on ClientException catch (e) {
        _errMessage = e.message;
        _getUserState = RequestState.error;
        notifyListeners();
      }
    }
  }
}
