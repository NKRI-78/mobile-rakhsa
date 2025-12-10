import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rakhsa/misc/utils/logger.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService instance = RemoteConfigService._();

  final _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );

      await _remoteConfig.setDefaults({
        'required_app_version': '2.2.1+20',
        'under_review': false,
      });

      log(
        "RemoteConfigService initialize berhasil",
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

  Future<bool> checkIsUnderReview() async {
    await fetchAndActivate();

    final pi = await PackageInfo.fromPlatform();

    final remoteAppVersion = _remoteConfig.getString('required_app_version');
    final currentAppVersion = "${pi.version}+${pi.buildNumber}";
    final isMatchAppVersion = currentAppVersion == remoteAppVersion;

    final isUnderReview = _remoteConfig.getBool('under_review');

    final result = isMatchAppVersion && isUnderReview;

    log(
      "checkIsUnderReview = ${{"remoteAppVersion": remoteAppVersion, "currentAppVersion": currentAppVersion, "isMatchAppVersion": isMatchAppVersion, "isUnderReview": isUnderReview, "result": result}}",
      label: "REMOTE_CONFIG_SERVICE",
    );

    return result;
  }
}
