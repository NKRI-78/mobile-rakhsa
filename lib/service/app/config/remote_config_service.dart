import 'dart:convert';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/misc/utils/logger.dart';

import 'remote_config_data.dart';
export 'remote_config_data.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService instance = RemoteConfigService._();

  final _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: (BuildConfig.isProd && kReleaseMode)
              ? const Duration(hours: 1)
              : Duration.zero,
        ),
      );

      final defaultConfig = RemoteConfigData(
        underReview: false,
        sosSupportedCountries: ['SG'],
        appVersion: RemoteConfigAppVersion(
          ios: "2.2.1+20",
          android: "2.2.1+20",
        ),
      );

      await _remoteConfig.setDefaults({
        "data": jsonEncode(defaultConfig.toJson()),
      });

      log(
        "RemoteConfigService initialize berhasil, defaultConfig = ${defaultConfig.toJson()}",
        label: "REMOTE_CONFIG_SERVICE",
      );
    } catch (e) {
      log(
        "RemoteConfigService initialize gagal = ${e.toString()}}",
        label: "REMOTE_CONFIG_SERVICE",
      );
    }
  }

  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      log(
        "fetchAndActivate gagal = ${e.toString()}}",
        label: "REMOTE_CONFIG_SERVICE",
      );
    }
  }

  Future<RemoteConfigData> getData() async {
    await fetchAndActivate();

    final raw = _remoteConfig.getString('data');
    final data = jsonDecode(raw);

    final d = _remoteConfig.lastFetchTime.format("dd MMM yyyy");
    final h = _remoteConfig.lastFetchTime.format("HH:mm");
    final fetchInterval = _remoteConfig.pluginConstants['minimumFetchInterval'];

    log(
      "getData() ${{"last_fetched": "$d jam $h", "fetch_interval": "$fetchInterval detik", "data": data}}",
      label: "REMOTE_CONFIG_SERVICE",
    );

    return RemoteConfigData.fromJson(data);
  }

  Future<bool> checkIsUnderReview() async {
    final data = await getData();
    final pi = await PackageInfo.fromPlatform();

    final remoteAppVersion = Platform.isIOS
        ? data.appVersion.ios
        : data.appVersion.android;
    final currentAppVersion = "${pi.version}+${pi.buildNumber}";
    final isMatchAppVersion = currentAppVersion == remoteAppVersion;

    final isUnderReview = data.underReview;

    log(
      "checkIsUnderReview = ${{"remoteAppVersion": remoteAppVersion, "currentAppVersion": currentAppVersion, "isMatchAppVersion": isMatchAppVersion, "isUnderReview": isUnderReview, "result": (isMatchAppVersion && isUnderReview)}}",
      label: "REMOTE_CONFIG_SERVICE",
    );

    return isMatchAppVersion && isUnderReview;
  }
}
