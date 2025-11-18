import 'dart:convert';

import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/misc/utils/logger.dart';

enum Flavor { stag, prod }

class BuildConfig {
  final Flavor flavor;
  final String? apiBaseUrl;
  final String? socketBaseUrl;

  const BuildConfig._(this.flavor, this.apiBaseUrl, this.socketBaseUrl);

  static BuildConfig? _instance;

  static BuildConfig get instance {
    if (_instance == null) {
      throw StateError(
        'BuildConfig not initialized. Call BuildConfig.initialize(...) in main().',
      );
    }
    return _instance!;
  }

  static Future<void> initialize({
    required Flavor flavor,
    String? apiBaseUrl,
    String? socketBaseUrl,
    bool persist = true,
  }) async {
    _instance = BuildConfig._(flavor, apiBaseUrl, socketBaseUrl);
    log(
      'BuildConfig initialized: ${_instance.toString()}',
      label: "BUILD_CONFIG",
    );

    if (persist) {
      try {
        await _persistConfig(_instance!);
      } catch (e, st) {
        log('Failed persisting BuildConfig: $e\n$st', label: "BUILD_CONFIG");
      }
    }
  }

  static bool get isProd => _instance?.flavor == Flavor.prod;
  static bool get isStag => _instance?.flavor == Flavor.stag;

  static const _cacheKey = 'config_cache_key';

  static Future<void> _persistConfig(BuildConfig newConfig) async {
    await StorageHelper.write(_cacheKey, newConfig.toJson());
  }

  static Future<void> deleteCacheConfig() async {
    await StorageHelper.delete(_cacheKey);
    _instance = null;
  }

  static BuildConfig? getCacheConfig() {
    final cache = StorageHelper.read(_cacheKey);
    if (cache == null) return null;
    try {
      return BuildConfig.fromJson(cache);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'flavor': flavor.name,
      'apiBaseUrl': apiBaseUrl,
      'socketBaseUrl': socketBaseUrl,
    };
  }

  factory BuildConfig.fromMap(Map<String, dynamic> map) {
    return BuildConfig._(
      Flavor.values.firstWhere(
        (e) => e.name == (map['flavor'] as String? ?? ''),
        orElse: () => Flavor.prod,
      ),
      map['apiBaseUrl'] as String?,
      map['socketBaseUrl'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory BuildConfig.fromJson(String source) =>
      BuildConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'BuildConfig(flavor: ${flavor.name}, apiBaseUrl: ${apiBaseUrl ?? "-"}, socketBaseUrl: ${socketBaseUrl ?? "-"})';
}
