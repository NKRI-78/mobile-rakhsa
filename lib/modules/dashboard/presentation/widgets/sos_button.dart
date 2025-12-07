import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bounce/bounce.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/service/haptic/haptic_service.dart';
import 'package:rakhsa/service/sos/end_sos_dialog.dart';
import 'package:rakhsa/modules/sos/pages/sos_camera.dart';

import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/service/sos/sos_coordinator.dart';

import 'package:rakhsa/repositories/user/model/user.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SosButtonParam {
  final String location;
  final String country;
  final String lat;
  final String lng;
  final bool hasSocketConnection;
  final bool loadingGmaps;
  final User? profile;

  SosButtonParam({
    required this.location,
    required this.country,
    required this.lat,
    required this.lng,
    required this.hasSocketConnection,
    required this.loadingGmaps,
    this.profile,
  });
}

class SosButton extends StatefulWidget {
  final SosButtonParam param;

  const SosButton(this.param, {super.key});

  @override
  SosButtonState createState() => SosButtonState();
}

class SosButtonState extends State<SosButton>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static final Duration countdownDuration = Duration(seconds: 60);

  // animation controller
  AnimationController? _pulseController;
  AnimationController? _tickerController;
  Animation<double>? _pulseAnimation;

  // state
  // cd = countdown Duration inSeconds
  final _cdInSeconds = countdownDuration.inSeconds;
  int _remainingSeconds = countdownDuration.inSeconds;
  bool _isCountingDown = false;

  Timer? _holdPulseTimer;

  StreamSubscription<SosEvent>? _sosSub;

  late LocationProvider _locationProvider;

  // style
  final buttonSize = 180.0; //px
  final buttonColor = Color(0xFFFE1717);
  final disabledColor = Color(0xFF7A7A7A);
  final countdownColor = Color(0xFF1FFE17);

  SharedPreferences get _prefs => StorageHelper.sharedPreferences;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locationProvider = context.read<LocationProvider>();

    _initAnimationController();

    _sosSub = SosCoordinator().events.listen((e) {
      if (!mounted) return;

      switch (e.type) {
        case SosEventType.start:
          _resetAndStartCountdown();
          break;
        case SosEventType.stop:
          _stopCountdown();
          break;
      }
    });

    _restoreCountdownState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_isCountingDown) return;
    if (state == AppLifecycleState.resumed) {
      _resumeFromPresists();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _presistCountdownState();
    _sosSub?.cancel();
    _holdPulseTimer?.cancel();
    _pulseController?.dispose();
    _tickerController?.dispose();
    super.dispose();
  }

  void _initAnimationController() {
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _tickerController = AnimationController(
      vsync: this,
      duration: countdownDuration,
    );

    // init pulse animation
    if (_pulseController != null) {
      _pulseAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeOut),
      );
    }

    if (_tickerController != null) {
      _tickerController!.addListener(() {
        if (!mounted) return;
        final remaining =
            (_cdInSeconds - (_tickerController!.value * _cdInSeconds))
                .ceil()
                .clamp(0, _cdInSeconds);
        if (remaining != _remainingSeconds) {
          setState(() => _remainingSeconds = remaining);
          HapticService.instance.lightImpact();
        }
      });
      _tickerController!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (!mounted) return;
          setState(() {
            _remainingSeconds = 0;
            _isCountingDown = false;
          });
          _presistCountdownState();
        }
      });
    }
  }

  bool _checkUserIsLoggedIn() {
    final userLoggedIn = StorageHelper.session != null;
    if (!userLoggedIn && mounted) {
      AppDialog.show(
        c: context,
        dismissible: false,
        content: DialogContent(
          title: "Pengguna Tidak Ditemukan",
          message: """
Kami mendeteksi adanya kesalahan pada sesi Anda. Silakan login kembali untuk melanjutkan penggunaan aplikasi.
""",
          buildActions: (c) {
            return [
              DialogActionButton(
                label: "Keluar",
                primary: true,
                onTap: () {
                  c.pop();
                  Future.delayed(Duration(milliseconds: 200)).then((_) {
                    if (mounted) WelcomeRoute().go(context);
                  });
                },
              ),
            ];
          },
        ),
      );
    }
    return userLoggedIn;
  }

  bool _checkIfSessionIsRunning() {
    final isActive = widget.param.profile?.sos?.running ?? false;
    if (isActive) {
      EndSosDialog.launch(
        title: "Sesi Bantuan Sedang Berlangsung",
        sosId: widget.param.profile?.sos?.id ?? "-",
        chatId: widget.param.profile?.sos?.chatId ?? "-",
        recipientId: widget.param.profile?.sos?.recipientId ?? "-",
        fromHome: true,
      );
    }
    return isActive;
  }

  OverlayDialogController _showLoadingLocationDialog() {
    return showOverlayDialog(
      context,
      barrierDismissible: false,
      positioned: (dialog) {
        return Positioned(
          top: context.top + kToolbarHeight + 24,
          right: 38,
          left: 38,
          child: dialog,
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          "Tunggu Sebentar Sedang Memuat Lokasi",
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }

  Future<bool> _checkIfCurrentCountryIsAllowed() async {
    // kalau staging ga perlu cek lokasi
    if (BuildConfig.isStag) return true;

    final overlayController = _showLoadingLocationDialog();
    await _locationProvider.getCurrentLocation();
    overlayController.dismiss();

    final errorGetCurrentLocation = _locationProvider.isGetLocationState(
      RequestState.error,
    );
    if (errorGetCurrentLocation) {
      if (mounted) {
        await AppDialog.error(
          c: context,
          title: "Gagal Mendapatkan Lokasi",
          message: _locationProvider.errGetCurrentLocation ?? "-",
          buildActions: (dc) {
            return [
              DialogActionButton(
                label: "Coba Lagi",
                primary: true,
                onTap: dc.pop,
              ),
            ];
          },
        );
      }
    }

    // langsung stop proses selanjutnya karena error get lokasi
    if (errorGetCurrentLocation) return false;

    final allowedCountry = _locationProvider.isCountryAllowed;

    if (!allowedCountry) {
      if (mounted) {
        await AppDialog.error(
          c: context,
          title: "Keterbatasan Akses Marlinda",
          message:
              "Maaf, Anda saat ini berada di ${_locationProvider.location?.placemark?.country ?? "-"}. Marlinda hanya dapat digunakan di Singapura.",
          buildActions: (dc) {
            return [
              DialogActionButton(
                label: "Mengerti",
                primary: true,
                onTap: dc.pop,
              ),
            ];
          },
        );
      }
    }

    return allowedCountry;
  }

  Future<bool> _handleShouldLongPressStart() async {
    final userLoggedIn = _checkUserIsLoggedIn();

    // cek waiting countdown dulu ketika sos sebelumnya masih belum diterima admin
    final waitingConfirmSOS = _isCountingDown && _remainingSeconds > 0;
    if (waitingConfirmSOS) {
      await AppDialog.showToast(
        "Anda dapat mengirim SOS setelah $_cdInSeconds detik",
      );
      return false;
    }

    // kalau negara ga dizinkan langsung return false
    // biar dia ga menjalankan fungsi dibawahnya
    final allowedCountry = await _checkIfCurrentCountryIsAllowed();
    if (!allowedCountry) return false;

    final activeRunning = _checkIfSessionIsRunning();
    final hasSocketConnection = widget.param.hasSocketConnection;

    // handle toast
    if (!hasSocketConnection) {
      await AppDialog.showToast("Sedang menghubungkan koneksi ke server");
    }

    // jalankan longpress start ketika
    // 1. user isLoggedIn
    // 2. lagi ga aktif running sos (isRunning didapat dari fetch user)
    // 3. soket aktif
    // 4. lagi ga get current location
    // 5. ga lagi waiting sos
    return userLoggedIn &&
        !activeRunning &&
        hasSocketConnection &&
        // !isGettingLocation &&
        !waitingConfirmSOS &&
        allowedCountry;
  }

  Future<bool> _handleShouldLongPressEnd() async {
    final userLoggedIn = _checkUserIsLoggedIn();
    final hasSocketConnection = widget.param.hasSocketConnection;
    final isGettingLocation = widget.param.loadingGmaps;

    // jalankan longpress end ketika
    // 1. user isLoggedIn
    // 2. soket aktif
    // 3. lagi ga get current location
    return userLoggedIn && hasSocketConnection && !isGettingLocation;
  }

  Future<void> _onLongPressStart() async {
    HapticService.instance.mediumImpact();
    final shouldPress = await _handleShouldLongPressStart();
    if (shouldPress) {
      _pulseController?.forward();
      _holdPulseTimer = Timer(Duration(seconds: 2), () async {
        _runSOS();
      });
    }
  }

  Future<void> _onLongPressEnd() async {
    final shouldPress = await _handleShouldLongPressEnd();
    if (shouldPress) {
      if (_holdPulseTimer?.isActive ?? false) {
        _holdPulseTimer?.cancel();
        _pulseController?.reverse();
      }
    }
  }

  void _runSOS() {
    HapticService.instance.heavyImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CameraPage(
            location: widget.param.location,
            country: widget.param.country,
            lat: widget.param.lat,
            lng: widget.param.lng,
          );
        },
      ),
    ).then((onNavigateSOSCameraResult) {
      _pulseController?.reset();
      if (onNavigateSOSCameraResult != null) {
        SosCoordinator().start();
      } else {
        _pulseController?.reset();
      }
    });
  }

  Future<void> _presistCountdownState() async {
    await _prefs.setBool(SosCoordinator.kWaitingKey, _isCountingDown);
    await _prefs.setInt(SosCoordinator.kRemainKey, _remainingSeconds);
    await _prefs.setInt(
      SosCoordinator.kSavedAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _restoreCountdownState() async {
    final waiting = _prefs.getBool(SosCoordinator.kWaitingKey) ?? false;
    if (!waiting) {
      setState(() {
        _isCountingDown = false;
        _remainingSeconds = _cdInSeconds;
      });
      _tickerController?.value = 0;
      return;
    }
    _isCountingDown = true;
    await _resumeFromPresists();
  }

  Future<void> _resumeFromPresists() async {
    final lastRemaining = _prefs.getInt(SosCoordinator.kRemainKey);
    final lastSavedTime = _prefs.getInt(SosCoordinator.kSavedAtKey);

    int currentRemaining = _cdInSeconds;
    if (lastRemaining != null && lastSavedTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = ((now - lastSavedTime) / 1000).floor();
      currentRemaining = (lastRemaining - elapsed).clamp(0, _cdInSeconds);
    }
    if (!mounted) return;

    setState(() => _remainingSeconds = currentRemaining);

    if (currentRemaining <= 0) {
      setState(() => _isCountingDown = false);
      _tickerController?.value = 1;
      await _presistCountdownState();
      return;
    }

    final startValue = 1 - (currentRemaining / _cdInSeconds);
    _tickerController?.stop();
    _tickerController?.value = startValue;
    _tickerController?.forward(from: startValue);
  }

  Future<void> _resetAndStartCountdown() async {
    if (!mounted) return;

    setState(() {
      _isCountingDown = true;
      _remainingSeconds = _cdInSeconds;
    });

    _tickerController?.stop();
    _tickerController?.value = 0;
    _tickerController?.forward(from: 0);

    await _presistCountdownState();
  }

  Future<void> _stopCountdown() async {
    if (!mounted) return;
    _tickerController?.stop();
    setState(() {
      _isCountingDown = false;
      _remainingSeconds = 0;
    });
    _tickerController?.value = 1;
    await _presistCountdownState();
  }

  @override
  Widget build(BuildContext context) {
    final isWaitingConfirmSOS = _isCountingDown && _remainingSeconds > 0;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_pulseAnimation != null)
            for (var scaleFactor in [0.8, 1.2, 1.4])
              AnimatedBuilder(
                animation: _pulseAnimation!,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation!.value * scaleFactor,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: buttonColor.withValues(alpha: 0.2 / scaleFactor),
                      ),
                    ),
                  );
                },
              ),
          if (_tickerController != null && isWaitingConfirmSOS)
            AnimatedBuilder(
              animation: _tickerController!,
              builder: (context, _) {
                return SizedBox(
                  width: buttonSize + 4,
                  height: buttonSize + 4,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    value: 1 - _tickerController!.value,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(countdownColor),
                  ),
                );
              },
            ),

          Consumer<LocationProvider>(
            builder: (context, p, child) {
              final allowedCountry = p.isCountryAllowed;
              final locationError = p.isGetLocationState(RequestState.error);
              return GestureDetector(
                onLongPressStart: (_) async {
                  await _onLongPressStart();
                },
                onLongPressEnd: (_) async {
                  await _onLongPressEnd();
                },
                child: Bounce(
                  onTap: () {},
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          widget.param.hasSocketConnection ||
                              !locationError ||
                              !allowedCountry
                          ? buttonColor
                          : disabledColor,
                      boxShadow: [
                        BoxShadow(
                          color:
                              widget.param.hasSocketConnection ||
                                  !locationError ||
                                  !allowedCountry
                              ? buttonColor.withValues(alpha: 0.5)
                              : disabledColor.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isWaitingConfirmSOS ? "$_remainingSeconds" : "SOS",
                      style: robotoRegular.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
