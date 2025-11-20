import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rakhsa/misc/utils/logger.dart';
import 'package:rakhsa/repositories/auth/model/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static late SharedPreferences sharedPreferences;
  static late FlutterSecureStorage secureStorage;

  static UserSession? _session;
  static UserSession? get session {
    log(
      "UserSession dari getter, username = ${_session?.user.name}",
      label: "STORAGE_HELPER",
    );
    return _session;
  }

  // udah sesuai best practice dari dokumentasi flutter_secure_storage
  // jika encryptedSharedPreferences = true
  static AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);

  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();

    secureStorage = FlutterSecureStorage(
      aOptions: _getAndroidOptions(),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked),
    );

    if (Platform.isIOS) {
      _removeiOSKeychainOnFirstRun();
    }
  }

  static Future _removeiOSKeychainOnFirstRun() async {
    final hasRun = sharedPreferences.getBool('has_run_before') ?? false;
    if (!hasRun) {
      await secureStorage.deleteAll();
      await sharedPreferences.setBool('has_run_before', true);
    }
  }

  static Future<bool> write(String key, String value) {
    return sharedPreferences.setString(key, value);
  }

  static String? read(String key) {
    return sharedPreferences.getString(key);
  }

  static Future<bool> delete(String key) {
    return sharedPreferences.remove(key);
  }

  static bool containsKey(String key) {
    return sharedPreferences.containsKey(key);
  }

  static Future<bool> clear() => sharedPreferences.clear();

  static Future<void> saveUserSession(UserSession newSession) async {
    await secureStorage.write(
      key: "user_session",
      value: userSessionToJson(newSession),
    );

    // dibaca beb.. 😘😘
    // revalidate cache _session biar ga bikin bug
    // kalau ini ga dilakuin aplikasi masih menyimpan data cache _session sebelumnya
    // walupun sudah login diakun yang berbeda
    final newCacheSession = await getUserSession();
    if (newCacheSession != null) {
      _session = newCacheSession;
    }
  }

  static Future<UserSession?> getUserSession() async {
    final sessionCache = await secureStorage.read(key: "user_session");
    if (sessionCache == null) return null;
    return userSessionFromJson(sessionCache);
  }

  static Future<UserSession?> loadlocalSession() async {
    if (_session != null) return _session;
    final loaded = await getUserSession();
    if (loaded != null) _session = loaded;
    log(
      "session dari loadLocalSession, username ${_session?.user.name}",
      label: "STORAGE_HELPER",
    );
    return loaded;
  }

  static Future<void> removeUserSession() async {
    _session = null;
    await secureStorage.delete(key: "user_session");
  }

  static String? getUserNationality() {
    String? nationality = sharedPreferences.getString("nationality") ?? "-";

    return nationality;
  }

  static void saveUserNationality({required String nationality}) async {
    await sharedPreferences.setString("nationality", nationality.toLowerCase());
  }

  static bool isLoggedIn() {
    return _session != null;
  }
}
