import 'package:rakhsa/misc/utils/logger.dart';
import 'package:rakhsa/repositories/auth/model/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static late SharedPreferences sharedPreferences;

  static UserSession? _session;
  static UserSession? get session {
    log(
      "UserSession dari getter, username = ${_session?.user.name}",
      label: "STORAGE_HELPER",
    );
    return _session;
  }

  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
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
    final parsedSession = userSessionToJson(newSession);
    await write("user_session_cache_key", parsedSession);

    // dibaca beb.. 😘😘
    // revalidate cache _session biar ga bikin bug
    // kalau ini ga dilakuin aplikasi masih menyimpan data cache _session sebelumnya
    // walupun sudah login diakun yang berbeda
    _session = newSession;
  }

  static Future<UserSession?> getUserSession() async {
    final sessionCache = read("user_session_cache_key");
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
    await delete("user_session_cache_key");
  }

  static String? getUserNationality() {
    final result = sharedPreferences.getString("nationality");
    return result;
  }

  static void saveUserNationality({required String nationality}) async {
    await sharedPreferences.setString("nationality", nationality.toLowerCase());
  }

  static bool isLoggedIn() {
    return _session != null;
  }
}
