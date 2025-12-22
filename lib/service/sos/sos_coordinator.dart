import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SosEventType { start, stop }

class SosEvent {
  final SosEventType type;
  final String? reason;
  const SosEvent(this.type, {this.reason});
}

class SosCoordinator {
  SosCoordinator._internal();
  static final SosCoordinator _instance = SosCoordinator._internal();
  factory SosCoordinator() => _instance;

  static SharedPreferences get _prefs => StorageHelper.prefs;

  final ValueNotifier<bool> isCountingDown = ValueNotifier<bool>(false);
  final _bus = StreamController<SosEvent>.broadcast();
  Stream<SosEvent> get events => _bus.stream;

  // Persist keys
  static const kRemainKey = 'remaining_seconds';
  static const kSavedAtKey = 'saved_timestamp';
  static const kWaitingKey = 'waiting_confirm_sos';
  static const _kPendingStopKey = 'pending_stop_flag';

  Future<void> initAndRestore() async {
    final waiting = _prefs.getBool(kWaitingKey) ?? false;
    isCountingDown.value = waiting;

    final pendingStop = _prefs.getBool(_kPendingStopKey) ?? false;
    if (pendingStop == true) {
      await _clearPendingStop(_prefs);
      stop(reason: 'pending-stop');
    }
  }

  Future<void> start() async {
    isCountingDown.value = true;
    await _prefs.setBool(kWaitingKey, true);
    await _prefs.setInt(kRemainKey, 60);
    await _prefs.setInt(kSavedAtKey, DateTime.now().millisecondsSinceEpoch);

    _bus.add(const SosEvent(.start));
  }

  Future<void> stop({String? reason}) async {
    isCountingDown.value = false;
    await _prefs.setBool(kWaitingKey, false);
    await _prefs.setInt(kRemainKey, 0);
    await _prefs.setInt(kSavedAtKey, DateTime.now().millisecondsSinceEpoch);
    await _clearPendingStop(_prefs);

    _bus.add(SosEvent(.stop, reason: reason));
  }

  static Future<void> markPendingStopFromBackground() async {
    await _prefs.setBool(_kPendingStopKey, true);
    await _prefs.setBool(kWaitingKey, false);
    await _prefs.setInt(kRemainKey, 0);
    await _prefs.setInt(kSavedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _clearPendingStop(SharedPreferences prefs) async {
    await prefs.remove(_kPendingStopKey);
  }

  bool getWaitingFlag() {
    return _prefs.getBool(kWaitingKey) ?? false;
  }
}
