import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rakhsa/misc/client/errors/exceptions.dart';
import 'package:rakhsa/repositories/auth/model/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static late SharedPreferences sharedPreferences;

  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> write(String key, String value) {
    return sharedPreferences.setString(key, value);
  }

  static bool containsKey(String key) {
    return sharedPreferences.containsKey(key);
  }

  static String? read(String key, String value) {
    return sharedPreferences.getString(key);
  }

  static Future<bool> delete(String key) {
    return sharedPreferences.remove(key);
  }

  static void clear() {
    sharedPreferences.clear();
  }

  static getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);
  static getIOSOptions() => const IOSOptions();

  static final FlutterSecureStorage storage = FlutterSecureStorage(
    aOptions: getAndroidOptions(),
    iOptions: getIOSOptions(),
  );

  static Future<void> saveToken({required String token}) async {
    await storage.write(key: "token", value: token);
  }

  static Future<void> saveUserSession(UserSession newSession) {
    return storage.write(
      key: "user_session",
      value: userSessionToJson(newSession),
    );
  }

  static Future<UserSession> getUserSession() async {
    final sessionCache = await storage.read(key: "user_session");
    if (sessionCache != null) {
      log("user session = $sessionCache");
      return userSessionFromJson(sessionCache);
    }
    throw ClientException.missing("Sesi pengguna tidak ditemukan.");
  }

  static Future<void> removeUserSession() {
    return storage.delete(key: "user_session");
  }

  static void setIsLocked({required bool val}) {
    sharedPreferences.setBool("is_locked", val);
  }

  static bool isLocked() {
    return sharedPreferences.getBool("is_locked") ?? false;
  }

  static int? getElapsedTime() {
    int? elapsedTime = sharedPreferences.getInt("elapsedtime") ?? 60;

    return elapsedTime;
  }

  static String? getUserNationality() {
    String? nationality = sharedPreferences.getString("nationality") ?? "-";

    return nationality;
  }

  static void setMiddlewareLogin({required bool val}) async {
    await sharedPreferences.setBool("middleware_login", val);
  }

  static void destroyMiddlewareLogin() async {
    await sharedPreferences.remove("middleware_login");
  }

  static bool middlewareLogin() {
    return sharedPreferences.getBool("middleware_login") ?? false;
  }

  static void saveRecordScreen({required bool isHome}) async {
    await sharedPreferences.setBool("is_home", isHome);
  }

  static void saveUserNationality({required String nationality}) async {
    await sharedPreferences.setString("nationality", nationality.toLowerCase());
  }

  static void saveUserId({required String userId}) async {
    await sharedPreferences.setString("user_id", userId);
  }

  static void saveUserPhone({required String phone}) async {
    await sharedPreferences.setString("user_phone", phone);
  }

  static void saveUserEmail({required String email}) async {
    await sharedPreferences.setString("user_email", email);
  }

  static void saveElapsedTime({required int elapsedtime}) async {
    await sharedPreferences.setInt("elapsedtime", elapsedtime);
  }

  static void clearElapsedTime() async {
    await sharedPreferences.remove("elapsedtime");
  }

  static void removeSosId() async {
    await sharedPreferences.remove("sos_id");
  }

  static Future<bool> isLoggedIn() async {
    final containSessionKey = await storage.containsKey(key: "user_session");
    final sessionCache = await storage.read(key: "user_session");
    return containSessionKey && (sessionCache != null);
  }

  static bool containsOnBoardingKey() {
    return sharedPreferences.containsKey('on-boarding-key');
  }

  static Future<void> setOnBoardingKey() async {
    await sharedPreferences.setBool('on-boarding-key', true);
  }
}
