import 'package:vibration/vibration.dart';

class VibrationManager {
  VibrationManager._();
  static final instance = VibrationManager._();

  bool _initialized = false;
  bool _hasVibrator = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _hasVibrator = await Vibration.hasVibrator();
  }

  Future<void> vibrate({int durationInMs = 150}) async {
    if (!_initialized) await init();
    if (!_hasVibrator) return;
    return Vibration.vibrate(duration: durationInMs);
  }
}
