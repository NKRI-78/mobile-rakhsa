import 'package:vibration/vibration.dart';

class VibrationManager {
  bool _hasVibrator = false;
  bool get hasVibrator => _hasVibrator;

  Future<void> init() async {
    _hasVibrator = await Vibration.hasVibrator();
  }

  void vibrate({int durationInMs = 150}) {
    if (_hasVibrator) Vibration.vibrate(duration: durationInMs);
  }
}
