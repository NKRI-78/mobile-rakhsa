import 'dart:io';

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  HapticService._internal();

  static final HapticService _instance = HapticService._internal();

  factory HapticService() => _instance;
  static HapticService get instance => _instance;

  bool? _hasVibration;
  bool get hasVibration => _hasVibration ?? false;

  Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    _hasVibration = await Vibration.hasVibrator();
  }

  Future<void> _ensureInitialized() async {
    if (!Platform.isAndroid) return;
    if (_hasVibration != null) return;
    _hasVibration = await Vibration.hasVibrator();
  }

  Future<void> _androidVibrate(int durationInMs) async {
    await _ensureInitialized();
    if (hasVibration) {
      await Vibration.vibrate(duration: durationInMs);
    }
  }

  Future<void> _trigger({
    required int durationInMs,
    Future<void> Function()? iosHaptic,
  }) async {
    if (Platform.isAndroid) {
      await _androidVibrate(durationInMs);
    } else if (Platform.isIOS && iosHaptic != null) {
      await iosHaptic();
    }
  }

  Future<void> selectionClick({int durationInMs = 20}) async {
    await _trigger(
      durationInMs: durationInMs,
      iosHaptic: HapticFeedback.selectionClick,
    );
  }

  Future<void> lightImpact({int durationInMs = 30}) async {
    await _trigger(
      durationInMs: durationInMs,
      iosHaptic: HapticFeedback.lightImpact,
    );
  }

  Future<void> mediumImpact({int durationInMs = 40}) async {
    await _trigger(
      durationInMs: durationInMs,
      iosHaptic: HapticFeedback.mediumImpact,
    );
  }

  Future<void> heavyImpact({int durationInMs = 50}) async {
    await _trigger(
      durationInMs: durationInMs,
      iosHaptic: HapticFeedback.heavyImpact,
    );
  }

  Future<void> vibrate({int durationInMs = 60}) async {
    await _trigger(
      durationInMs: durationInMs,
      iosHaptic: HapticFeedback.vibrate,
    );
  }
}
