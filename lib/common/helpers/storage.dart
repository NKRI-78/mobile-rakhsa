import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {

  static late SharedPreferences sharedPreferences;

  static Future init() async {
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

  static Future<String?> getToken() async {
    String? token = await storage.read(key: 'token');

    return token;
  } 

  static void removeToken() async {
    await storage.delete(key: 'token');
  }

  static Future<bool?> isLoggedIn() async {
    var token = await storage.read(key: 'token');

    return token != null 
    ? true 
    : false;
  }
  
}