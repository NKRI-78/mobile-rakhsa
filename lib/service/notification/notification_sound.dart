import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:rakhsa/misc/utils/logger.dart';
import 'package:rakhsa/service/haptic/haptic_service.dart';

enum SoundType { general, chat }

class FCMSoundService {
  FCMSoundService._();
  static final FCMSoundService instance = FCMSoundService._();

  final SoLoud _soloud = SoLoud.instance;

  bool _inited = false;
  bool get isInitialized => _inited;

  AudioSource? _generalSource;
  AudioSource? _chatSource;

  final Map<SoundType, SoundHandle?> _lastHandleByType = {
    SoundType.general: null,
    SoundType.chat: null,
  };

  Future<void> initialize() async {
    if (_inited) return;

    try {
      await _soloud.init();
      _generalSource = await _soloud.loadAsset(
        'assets/sound/notification-general.mp3',
      );
      _chatSource = await _soloud.loadAsset(
        'assets/sound/notification-chat.mp3',
      );
      await HapticService.instance.initialize();

      _inited = true;
      log(
        "FCMSoundService berhasil di-initialize",
        label: "NOTIFICATION_SOUND",
      );
    } catch (e) {
      log(
        "FCMSoundService gagal di-initialize = ${e.toString()}",
        label: "NOTIFICATION_SOUND",
      );
    }
  }

  AudioSource _getSource(SoundType type) {
    if (!_inited) {
      throw StateError('FCMSoundService belum initialize().');
    }

    final src = switch (type) {
      SoundType.general => _generalSource,
      SoundType.chat => _chatSource,
    };

    if (src == null) {
      throw StateError('AudioSource untuk $type belum diload / sudah dispose.');
    }

    return src;
  }

  Future<SoundHandle> play({
    SoundType type = SoundType.general,
    double volume = 1.0,
    bool stopPreviousSameType = true,
    bool enableVibrate = true,
  }) async {
    final src = _getSource(type);

    if (stopPreviousSameType) {
      final prev = _lastHandleByType[type];
      if (prev != null) {
        await _soloud.stop(prev);
        _lastHandleByType[type] = null;
      }
    }

    final handle = await _soloud.play(src, volume: volume);
    _lastHandleByType[type] = handle;

    if (enableVibrate) await HapticService.instance.heavyImpact();
    return handle;
  }

  Future<void> stop({SoundType? type}) async {
    if (type == null) {
      for (final t in SoundType.values) {
        final h = _lastHandleByType[t];
        if (h != null) {
          await _soloud.stop(h);
          _lastHandleByType[t] = null;
        }
      }
      return;
    }

    final h = _lastHandleByType[type];
    if (h != null) {
      await _soloud.stop(h);
      _lastHandleByType[type] = null;
    }
  }

  Future<void> dispose() async {
    await stop();

    if (_generalSource != null) {
      await _soloud.disposeSource(_generalSource!);
      _generalSource = null;
    }
    if (_chatSource != null) {
      await _soloud.disposeSource(_chatSource!);
      _chatSource = null;
    }

    _inited = false;
  }
}
