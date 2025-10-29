import 'package:vibration/vibration.dart';

class VibrationManager {
  bool _hasVibrator = false;
  bool get hasVibrator => _hasVibrator;

  Future<void> init() async {
    _hasVibrator = await Vibration.hasVibrator();
  }

  void vibrate({int duration = 150}) {
    if (_hasVibrator) Vibration.vibrate(duration: duration);
  }
}
