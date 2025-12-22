import 'package:flutter/material.dart';
import 'package:rakhsa/core/client/errors/exceptions/exceptions.dart';
import 'package:rakhsa/core/enums/request_state.dart';
import 'package:rakhsa/repositories/referral/model/referral.dart';
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

  var _getUserState = RequestState.idle;
  RequestState get getUserState => _getUserState;

  UserSession? get session => _session;

  Future<ReferralPackage?> getRoamingPackage() async {
    if (_user != null) {
      final packages = _user?.package ?? [];
      if (packages.isEmpty) return null;
      return packages.first;
    }

    try {
      final remoteUser = await getUser();
      if (remoteUser == null) return null;
      final packages = remoteUser.package;
      if (packages.isEmpty) return null;
      return packages.first;
    } catch (_) {
      return null;
    }
  }

  Future<User?> getUser({bool enableCache = false}) async {
    _getUserState = .loading;
    notifyListeners();

    final localUser = _repository.getLocalUser();
    if (enableCache && localUser != null) {
      _user = localUser;
      _getUserState = .success;
      notifyListeners();
      return localUser;
    } else {
      try {
        final uid = await StorageHelper.loadlocalSession().then((v) {
          return v?.user.id ?? "-";
        });
        final remoteUser = await _repository.getRemoteUser(uid);
        _user = remoteUser;
        _getUserState = .success;
        notifyListeners();
        return remoteUser;
      } on NetworkException catch (e) {
        _errMessage = e.message;
        _getUserState = .error;
        notifyListeners();
        return null;
      }
    }
  }
}

extension ReferralPackageExtension on ReferralPackage {
  int extractNumberFromKeyword() {
    final match = RegExp(
      r'(\d+)',
      caseSensitive: false,
    ).firstMatch(packageKeyword);
    if (match == null) return 0;
    return int.parse(match.group(1)!);
  }
}
