import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:provider/provider.dart';

import 'package:camera/camera.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/modules/sos/provider/sos_provider.dart';

import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';
import 'package:rakhsa/service/haptic/haptic_service.dart';

import 'package:rakhsa/service/socket/socketio.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';
import 'package:rakhsa/widgets/overlays/status_bar_style.dart';

class CameraPage extends StatefulWidget {
  final String location;
  final String country;
  final String lat;
  final String lng;

  const CameraPage({
    required this.location,
    required this.country,
    required this.lat,
    required this.lng,
    super.key,
  });

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  final _recordingController = RecordingButtonController();

  Timer? _timer;

  late SocketIoService socketIoService;
  late SosProvider sosProvider;

  bool loading = false;

  bool stop = false;

  bool isRecording = false;
  bool isVideoMode = false;

  static final int durationInSeconds = 10;
  int recordTimeLeft = durationInSeconds;

  Future<void> initializeCamera() async {
    cameras = await availableCameras();

    if (cameras != null && cameras!.isNotEmpty) {
      controller = CameraController(cameras![0], ResolutionPreset.high);
      await controller!.initialize();

      startVideoRecording();
      setState(() {});
    }
  }

  Future<void> startVideoRecording() async {
    if (controller == null || isRecording) return;

    try {
      await controller!.startVideoRecording();
      _recordingController.start();

      setState(() {
        isRecording = true;
        recordTimeLeft = 10;
      });

      _startTimer();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = null;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (recordTimeLeft == 0) {
        stopVideoRecording();
        timer.cancel();
        _timer?.cancel();
      } else {
        if (mounted) {
          setState(() => recordTimeLeft--);
        }
      }
    });
  }

  void _pauseTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
  }

  void _resumeTimer() {
    if (!(_timer?.isActive ?? false)) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (recordTimeLeft == 0) {
          stopVideoRecording();
          timer.cancel();
          _timer?.cancel();
        } else {
          if (mounted) {
            setState(() => recordTimeLeft--);
          }
        }
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> stopVideoRecording() async {
    _timer?.cancel();
    if (controller == null || !isRecording) return;

    try {
      await HapticService.instance.heavyImpact();
      final temp = await controller!.stopVideoRecording();
      _recordingController.stop();

      File videoFile;
      if (Platform.isAndroid) {
        videoFile = await convertTempToMp4(temp);
      } else {
        videoFile = File(temp.path);
      }

      setState(() {
        stop = true;
        loading = true;
        isRecording = false;
      });

      // Start upload in a separate future, with timeout
      await sosProvider.sendSos(
        videoFile,
        onTimeout: () {
          setState(() => loading = false);
          Future.delayed(Duration(milliseconds: 200)).then((_) {
            if (mounted) {
              AppDialog.error(
                canPop: false,
                c: context,
                title: "Koneksi Internet Lemah",
                message:
                    "Request Timeout, Periksa kembali koneksi internet Anda, lalu coba lagi.",
                buildActions: (dc) => [
                  DialogActionButton(label: "Mengerti", onTap: dc.pop),
                ],
              );
            }
          });
        },
      );

      if (mounted) setState(() => loading = false);
      if (sosProvider.sosVideo != null) {
        final media = sosProvider.sosVideo!.path;
        final ext = media.split('/').last.split('.').last;

        socketIoService.sos(
          location: widget.location,
          country: widget.country,
          media: media,
          ext: ext,
          lat: widget.lat,
          lng: widget.lng,
        );

        if (mounted) Navigator.pop(context, "start");
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<File> convertTempToMp4(XFile xfile) async {
    final tempFile = File(xfile.path);

    final newFile = await tempFile.copy(
      '${tempFile.dirname}/${tempFile.filenameWithoutExtension}.mp4',
    );

    await tempFile.delete();

    return newFile;
  }

  void _handlePauseVideoRecord() async {
    if (isRecording) {
      await controller?.pauseVideoRecording();
      _recordingController.pause();
      _pauseTimer();
      if (!mounted) return;
      AppDialog.error(
        c: context,
        title: "Batalkan Perekaman SOS?",
        message:
            "Apakah Anda yakin ingin membatalkan perekaman video SOS? Proses belum selesai dan data tidak akan terkirim.",
        canPop: false,
        actionButtonDirection: Axis.vertical,
        buildActions: (c) {
          return [
            DialogActionButton(
              label: "Batalkan Sos",
              onTap: () async {
                await controller?.stopVideoRecording();
                _recordingController.stop();
                _stopTimer();
                if (mounted) {
                  if (c.mounted) c.pop(); // tutup dialog
                  context.pop(); // keluar halaman
                  await Future.delayed(Duration(milliseconds: 500));
                  AppDialog.showToast("SOS Dibatalkan");
                }
              },
            ),
            DialogActionButton(
              label: "Lanjutkan Sos",
              primary: true,
              onTap: () async {
                await controller?.resumeVideoRecording();
                _recordingController.resume();
                _resumeTimer();
                if (c.mounted) c.pop();
              },
            ),
          ];
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();

    socketIoService = context.read<SocketIoService>();
    sosProvider = context.read<SosProvider>();

    initializeCamera();
  }

  @override
  void dispose() {
    super.dispose();

    controller?.dispose();
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return StatusBarStyle.light(
      child: PopScope(
        canPop: !isRecording && !loading,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (isRecording) {
            _handlePauseVideoRecord();
          }
        },
        child: Scaffold(
          backgroundColor: blackColor,
          body: controller == null || !controller!.value.isInitialized
              ? Center(child: CircularProgressIndicator(color: whiteColor))
              : Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CameraPreview(controller!),

                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Column(
                        spacing: 4,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RecordingButton(
                            durationInSeconds: durationInSeconds,
                            onTap: isRecording
                                ? stopVideoRecording
                                : startVideoRecording,
                            controller: _recordingController,
                          ),

                          if (isRecording)
                            Text(
                              '$recordTimeLeft s',
                              style: robotoRegular.copyWith(
                                color: ColorResources.white,
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (loading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black87,
                          child: Center(
                            child: Consumer<SosProvider>(
                              builder: (context, notifier, child) {
                                final uploadPercent = notifier.uploadPercent;
                                final percent = uploadPercent.toStringAsFixed(
                                  0,
                                );
                                final processingData =
                                    uploadPercent.toInt() > 98;
                                return Column(
                                  spacing: 12,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    42.spaceY,
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 32,
                                      ),
                                      child: Row(
                                        spacing: 12,
                                        children: [
                                          Icon(
                                            IconsaxPlusLinear.user,
                                            color: whiteColor,
                                            size: 32,
                                          ),
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: notifier.uploadProgress,
                                              color: Colors.white,
                                              backgroundColor: Colors.white
                                                  .withValues(alpha: 0.3),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                          ),
                                          Icon(
                                            IconsaxPlusLinear.security_user,
                                            color: whiteColor,
                                            size: 32,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (processingData) ...[
                                      Row(
                                        spacing: 10,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Memproses data",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 0.9,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      Text(
                                        "Mengirim SOS $percent%",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                    if (Platform.isIOS && isRecording)
                      Positioned(
                        top: context.top,
                        left: 16,
                        child: IconButton(
                          icon: Icon(
                            IconsaxPlusBold.close_circle,
                            color: Colors.white60,
                            size: 34,
                          ),
                          onPressed: _handlePauseVideoRecord,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class RecordingButtonController {
  VoidCallback? _onStart;
  VoidCallback? _onPause;
  VoidCallback? _onResume;
  VoidCallback? _onStop;

  void _attach({
    required VoidCallback onStart,
    required VoidCallback onPause,
    required VoidCallback onResume,
    required VoidCallback onStop,
  }) {
    _onStart = onStart;
    _onPause = onPause;
    _onResume = onResume;
    _onStop = onStop;
  }

  void _detach() {
    _onStart = null;
    _onPause = null;
    _onResume = null;
    _onStop = null;
  }

  bool get isAttached => _onStart != null;

  void start() => _onStart?.call();
  void pause() => _onPause?.call();
  void resume() => _onResume?.call();
  void stop() => _onStop?.call();
}

class RecordingButton extends StatefulWidget {
  final int durationInSeconds;
  final VoidCallback onTap;
  final RecordingButtonController controller;

  /// Optional: mulai animasi langsung ketika dibikin
  final bool autoStart;

  const RecordingButton({
    super.key,
    required this.durationInSeconds,
    required this.onTap,
    required this.controller,
    this.autoStart = false,
  });

  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationInSeconds),
    );

    // Hubungkan controller eksternal ke fungsi di dalam widget ini
    widget.controller._attach(
      onStart: _handleStart,
      onPause: _handlePause,
      onResume: _handleResume,
      onStop: _handleStop,
    );

    if (widget.autoStart) {
      _handleStart();
    }
  }

  @override
  void didUpdateWidget(covariant RecordingButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.durationInSeconds != widget.durationInSeconds) {
      _anim.duration = Duration(seconds: widget.durationInSeconds);
    }

    if (oldWidget.controller != widget.controller) {
      // Lepas dari controller lama, attach ke controller baru
      oldWidget.controller._detach();
      widget.controller._attach(
        onStart: _handleStart,
        onPause: _handlePause,
        onResume: _handleResume,
        onStop: _handleStop,
      );
    }
  }

  @override
  void dispose() {
    widget.controller._detach();
    _anim.dispose();
    super.dispose();
  }

  double get _progress => 1.0 - _anim.value;

  // ====== FUNGSI YANG DIKONTROL DARI LUAR ======
  void _handleStart() {
    _anim
      ..reset()
      ..forward();
  }

  void _handlePause() {
    _anim.stop();
  }

  void _handleResume() {
    if (_anim.isCompleted) return;
    _anim.forward();
  }

  void _handleStop() {
    _anim.stop();
    _anim.value = 1.0; // atau 0.0 kalau mau balik ke awal
  }

  // ====== UI ======
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return CircularProgressIndicator(
                value: _progress,
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              );
            },
          ),
        ),
        Material(
          color: Colors.red,
          borderRadius: BorderRadius.circular(100),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: widget.onTap,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.stop_circle, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }
}
