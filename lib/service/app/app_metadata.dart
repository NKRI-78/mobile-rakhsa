import 'package:rakhsa/service/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppMetadata {
  static final AppMetadata _instance = AppMetadata._internal();
  factory AppMetadata() => _instance;

  AppMetadata._internal();

  static const _keyInstallDate = 'app_install_date';

  SharedPreferences get _prefs => StorageHelper.sharedPreferences;

  bool get hasInitializeBefore => _prefs.containsKey(_keyInstallDate);

  Future<void> initialize() async {
    if (hasInitializeBefore) return;
    await _prefs.setString(
      _keyInstallDate,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<DateTime?> getInstallDate({bool utc = true}) async {
    await initialize();
    final raw = _prefs.getString(_keyInstallDate);
    if (raw == null) return null;

    final parsed = DateTime.parse(raw);

    return utc ? parsed.toUtc() : parsed.toLocal();
  }

  Future<Duration?> getAppAge() async {
    final installDate = await getInstallDate();
    if (installDate == null) return null;
    return DateTime.now().toUtc().difference(installDate);
  }

  Future<void> reset() async {
    await initialize();
    await _prefs.remove(_keyInstallDate);
  }
}
