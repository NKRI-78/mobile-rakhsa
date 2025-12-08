import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:rakhsa/injection.dart';
import 'package:rakhsa/misc/client/dio_client.dart';
import 'package:rakhsa/misc/utils/logger.dart';
import 'package:rakhsa/repositories/referral/referral_repository.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _FilterSource { playstore, appstore }

class UniversalLink {
  UniversalLink._();
  static final _instance = UniversalLink._();
  factory UniversalLink() => _instance;

  StreamSubscription<Uri>? _linkSubs;

  final _fetchPlaystoreCacheKey = "fetch_playstore_referrer_cache_key";
  final _fetchAppstoreCacheKey = "fetch_from_appstore_cache_key";

  SharedPreferences get _prefs => StorageHelper.sharedPreferences;

  DioClient get _client => locator<DioClient>();

  Dio get _uniLinkClient => _client.createNewInstance(
    baseUrl: "https://marlinda.app-links.langitdigital78.com",
  );

  Future<void> initializeUriHandlers() async {
    if (Platform.isAndroid) await _handleLinkFromPlaystore();
    if (Platform.isIOS) await _handleLinkFromAppstore();
    _handleLinkFromApplink();
  }

  void _handleLinkFromApplink() {
    _linkSubs?.cancel();
    _linkSubs = AppLinks().uriLinkStream.listen((uri) async {
      final code = uri.queryParameters['telkom_trx'];
      log(
        '_handleLinkFromApplink(): ${{"uri": uri.toString(), "referral_code": code}}',
        label: "UNIVERSAL_LINK",
      );
      await _saveReferralCode(code);
    });
  }

  // ini yang argumen link referral bisa tembus
  // saat user download dari playstore
  Future<void> _handleLinkFromPlaystore() async {
    final hasFetchBefore = _prefs.getBool(_fetchPlaystoreCacheKey) ?? false;
    log(
      '_handleLinkFromPlaystore() hasFetchBefore? $hasFetchBefore',
      label: "UNIVERSAL_LINK",
    );
    if (hasFetchBefore) return;

    try {
      final referrerDetail = await PlayInstallReferrer.installReferrer;
      final referrer = referrerDetail.installReferrer;
      log(
        '_handleLinkFromPlaystore(): ${{"install_referrer": referrer}}',
        label: "UNIVERSAL_LINK",
      );

      final code = _filterReferralCode(referrer, _FilterSource.playstore);
      await _saveReferralCode(code);

      await _prefs.setBool(_fetchPlaystoreCacheKey, true);
    } catch (e) {
      log(
        '_handleLinkFromPlaystore() gagal: ${e.toString()}',
        label: "UNIVERSAL_LINK",
      );
    }
  }

  // ini yang argumen link referral bisa tembus
  // saat user download dari appstore
  Future<void> _handleLinkFromAppstore() async {
    final hasFetchBefore = _prefs.getBool(_fetchAppstoreCacheKey) ?? false;
    log(
      '_handleLinkFromAppstore() hasFetchBefore? $hasFetchBefore',
      label: "UNIVERSAL_LINK",
    );
    if (hasFetchBefore) return;

    try {
      if (await _client.hasInternet) {
        final deviceInfo = await DeviceInfoPlugin().iosInfo;
        final res = await _uniLinkClient.post(
          "/deeplink/claim",
          data: {"model": deviceInfo.model},
        );
        log("_handleLinkFromAppstore() res: ${res.data}");

        if (res.data['status'] == "ok") {
          if (res.data['deep_link_params'] != null) {
            final code = res.data['deep_link_params']['telkom_trx'];
            await _saveReferralCode(code);
          }
        }
      } else {
        log(
          '_handleLinkFromAppstore() gagal: tidak ada koneksi internet',
          label: "UNIVERSAL_LINK",
        );
      }

      await _prefs.setBool(_fetchAppstoreCacheKey, true);
    } on DioException catch (e) {
      log(
        '_handleLinkFromAppstore() gagal DioException: ${{"error": e.error.toString(), "message": e.message, "dio_exception_type": e.type, "res": e.response.toString()}}',
        label: "UNIVERSAL_LINK",
      );
    } catch (e) {
      log(
        '_handleLinkFromAppstore() gagal UnhandledException: ${e.toString()}',
        label: "UNIVERSAL_LINK",
      );
    }
  }

  String? _filterReferralCode(String? raw, _FilterSource from) {
    if (raw == null) return null;

    if (from == _FilterSource.playstore) {
      // dibaca ya sayy 😙, ini bukan tulisan AI njir 😠
      // kalau user download marlinda selain dari applink maka begini output referrernya:
      // 1. dari pencarian playstore: utm_source=google-play&utm_medium=organic
      // 2. dari link yang dibagian via website: utm_source=(not%20set)&utm_medium=(not%20set)
      // makanya pengecekan dengan cara apakah referrer mengandung kata "utm_source" atau "utm_medium"
      // jika iya maka anggep user tidak mendapatkan kode referral karena download marlinda tidak melalui applink
      final isFromOrganicOrWebsite =
          raw.contains("utm_source") || raw.contains("utm_medium");
      if (isFromOrganicOrWebsite) return null;

      // nah kalau via applink output referrernya tuh kaya gini:
      // "0425249e-f650-44b1-9 dst...."
      // dia langsung berupa referral code
      // makanya kembalikan aja langsung referral code tanpa harus mem-filter lagi
      return raw;
    }

    if (from == _FilterSource.appstore) {}

    return null;
  }

  Future<void> _saveReferralCode(String? code) async {
    log(
      'mencoba _saveReferralCode, apakah referral code null? ${code == null}',
      label: "UNIVERSAL_LINK",
    );
    if (code == null) return;
    await locator<ReferralRepository>().saveReferralCode(code);
    log('berhasil _saveReferralCode', label: "UNIVERSAL_LINK");
  }

  void dispose() {
    _linkSubs?.cancel();
    _linkSubs = null;
  }
}
