import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart' show AppLifecycleListener;
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:rakhsa/injection.dart';
import 'package:rakhsa/misc/utils/logger.dart' show log;
import 'package:rakhsa/repositories/referral/referral_repository.dart';

class UniversalLink {
  UniversalLink._();
  static final _instance = UniversalLink._();
  factory UniversalLink() => _instance;

  StreamSubscription<Uri>? _linkSubs;
  AppLifecycleListener? _lifecycleListener;

  Future<void> initializeUriHandlers() async {
    _initializeAppLifecycleListener();
    await _handleLinkFromPlaystore();
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
    final referrerDetail = await PlayInstallReferrer.installReferrer;
    final referrer = referrerDetail.installReferrer;
    log(
      '_handleLinkFromPlaystore(): ${{"install_referrer": referrer, "referral_code": referrer}}',
      label: "UNIVERSAL_LINK",
    );
  }

  Future<void> _saveReferralCode(String? code) async {
    if (code == null) return;
    await locator<ReferralRepository>().saveReferralCode(code);
  }

  void _initializeAppLifecycleListener() {
    _lifecycleListener?.dispose();
    _lifecycleListener = AppLifecycleListener(
      onResume: () async {
        log('_lifecycleListener onResume', label: "UNIVERSAL_LINK");
        await _handleLinkFromPlaystore();
      },
    );
  }

  void dispose() {
    _linkSubs?.cancel();
    _lifecycleListener?.dispose();
    _linkSubs = null;
    _lifecycleListener = null;
  }
}
