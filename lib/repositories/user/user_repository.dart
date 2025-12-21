import 'dart:convert';

import 'package:rakhsa/core/client/dio_client.dart';
import 'package:rakhsa/core/client/errors/errors.dart';
import 'package:rakhsa/service/storage/storage.dart';
import './model/user.dart';

class UserRepository {
  UserRepository({required DioClient client}) : _client = client;

  final DioClient _client;

  static String cacheKey = "user_data_cache_key";

  Future<User> getRemoteUser(String uid, {bool persists = true}) async {
    try {
      final res = await _client.post(
        endpoint: "/profile",
        data: {"user_id": uid},
      );
      if (persists) {
        final stringUser = jsonEncode(res.data);
        await StorageHelper.write(cacheKey, stringUser);
      }
      return User.fromJson(res.data);
    } on DataParsingException catch (e) {
      throw NetworkException(message: e.message, errorCode: e.errorCode);
    }
  }

  User? getLocalUser() {
    final userCache = StorageHelper.read(cacheKey);
    if (userCache == null) return null;
    return userFromJson(userCache);
  }
}
