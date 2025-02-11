import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {

  static late SharedPreferences sharedPreferences;

  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static void clear() {
    sharedPreferences.clear();
  }

  static getAndroidOptions() => const AndroidOptions(encryptedSharedPreferences: true);
  static getIOSOptions() => const IOSOptions();

  static final FlutterSecureStorage storage = FlutterSecureStorage(
    aOptions: getAndroidOptions(),
    iOptions: getIOSOptions()
  );

  static Future<void> saveToken({required String token}) async {
    await storage.write(
      key: "token", 
      value: token
    );
  }

  static void setIsLocked({required bool val}) {
    sharedPreferences.setBool("is_locked", val);
  }

  static bool isLocked() {
    return sharedPreferences.getBool("is_locked") ?? false;
  }

  static Future<String> getToken() async {
    String token = await storage.read(key: 'token') ?? "-";

    return token;
  } 

  static String? getUserId() {
    String? userId = sharedPreferences.getString("user_id");

    return userId;
  }

  static String? getUserEmail() {
    String? userEmail = sharedPreferences.getString("user_email");

    return userEmail;
  }

  static String? getUserPhone() {
    String? userPhone = sharedPreferences.getString("user_phone");

    return userPhone;
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

  static Future<void> removeToken() async {
    await storage.delete(key: "token");
  }

  static Future<bool?> isLoggedIn() async {
    var token = await storage.read(key: "token");

    return token != null 
    ? true 
    : false;
  }
  
}