import 'dart:developer';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rakhsa/repositories/auth/model/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static late SharedPreferences sharedPreferences;
  static late FlutterSecureStorage secureStorage;

  static UserSession? _session;
  static UserSession? get session {
    log("session dari getter session = ${_session?.user.name}");
    return _session;
  }

  static Future<void> init({bool fromBgService = false}) async {
    if (!fromBgService) {
      sharedPreferences = await SharedPreferences.getInstance();
    }
    secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
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

  static Future<void> saveUserSession(UserSession newSession) {
    return secureStorage.write(
      key: "user_session",
      value: userSessionToJson(newSession),
    );
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
    log("loadLocalSession dari loadLocalSession = ${_session?.user.name}");
    return loaded;
  }

  static Future<void> removeUserSession() {
    return secureStorage.delete(key: "user_session");
  }

  static String? getUserNationality() {
    String? nationality = sharedPreferences.getString("nationality") ?? "-";

    return nationality;
  }

  static void saveRecordScreen({required bool isHome}) async {
    await sharedPreferences.setBool("is_home", isHome);
  }

  static void saveUserNationality({required String nationality}) async {
    await sharedPreferences.setString("nationality", nationality.toLowerCase());
  }

  static Future<bool> isLoggedIn() async {
    final containSessionKey = await secureStorage.containsKey(
      key: "user_session",
    );
    final sessionCache = await secureStorage.read(key: "user_session");
    return containSessionKey && (sessionCache != null);
  }
}
