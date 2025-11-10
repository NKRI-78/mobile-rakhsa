import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Flavor { stag, prod }

class BuildConfig {
  final Flavor flavor;
  final String appName;
  final String? apiBaseUrl;
  final String? socketBaseUrl;

  const BuildConfig(
    this.flavor,
    this.appName,
    this.apiBaseUrl,
    this.socketBaseUrl,
  );

  static BuildConfig? _instance;
  static BuildConfig get instance {
    if (_instance == null) {
      throw StateError(
        'BuildConfig not initialized. Call BuildConfig.init(...) in main().',
      );
    }
    return _instance!;
  }

  static void init({
    required Flavor flavor,
    required String appName,
    required String? apiBaseUrl,
    required String? socketBaseUrl,
  }) {
    _instance = BuildConfig(flavor, appName, apiBaseUrl, socketBaseUrl);
    if (kDebugMode) log(_instance.toString());
  }

  static bool get isProd => instance.flavor == Flavor.prod;
  static bool get isStag => instance.flavor == Flavor.stag;

  @override
  String toString() =>
      'BuildConfig(flavor: $flavor, appName: $appName) | APIConfig = ${{"api_base_url": dotenv.env['API_BASE_URL'] ?? "-", "socket_base_url": dotenv.env['SOCKET_BASE_URL'] ?? "-"}}';
}
