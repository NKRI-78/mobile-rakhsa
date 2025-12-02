import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:provider/provider.dart';

import 'package:camera/camera.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/modules/sos/provider/sos_provider.dart';
import 'package:rakhsa/service/device/vibration_manager.dart';

import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/service/socket/socketio.dart';
import 'package:rakhsa/widgets/dialog/app_dialog.dart';
import 'package:rakhsa/widgets/dialog/dialog_action_button.dart';

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

      setState(() {
        isRecording = true;
        recordTimeLeft = 10;
      });

      _timer?.cancel();
      _timer = null;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (recordTimeLeft == 0) {
          stopVideoRecording();
          timer.cancel();
          _timer?.cancel();
        } else {
          if (mounted) {
            setState(() {
              recordTimeLeft--;
            });
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> stopVideoRecording() async {
    _timer?.cancel();

    VibrationManager.instance.vibrate(durationInMs: 50);
    if (controller == null || !isRecording) return;

    try {
      final video = await controller!.stopVideoRecording();
      final mp4Video = await convertTempToMp4(video);

      setState(() {
        stop = true;
        loading = true;
        isRecording = false;
      });

      // Start upload in a separate future, with timeout
      await sosProvider.sendSos(
        mp4Video,
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
    return Scaffold(
      backgroundColor: blackColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarColor: blackColor,
          systemNavigationBarColor: blackColor,
        ),
      ),
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
                      _RecordingButton(
                        stop: stop,
                        recordTimeLeft,
                        durationInSeconds,
                        isRecording ? stopVideoRecording : startVideoRecording,
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
                            final percent = uploadPercent.toStringAsFixed(0);
                            final processingData = uploadPercent.toInt() > 98;
                            return Column(
                              spacing: 12,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                42.spaceY,
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 32),
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
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Memproses data",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
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
              ],
            ),
    );
  }
}

class _RecordingButton extends StatefulWidget {
  final bool stop;
  final int recordTimeLeft;
  final int durationInSeconds;
  final VoidCallback onTap;

  const _RecordingButton(
    this.recordTimeLeft,
    this.durationInSeconds,
    this.onTap, {
    this.stop = false,
  });

  @override
  State<_RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<_RecordingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationInSeconds),
    )..forward(from: 0.0);

    if (!widget.stop) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant _RecordingButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.durationInSeconds != widget.durationInSeconds) {
      _controller.duration = Duration(seconds: widget.durationInSeconds);
      _controller.forward(from: 0.0);
    }

    if (oldWidget.stop != widget.stop) {
      if (widget.stop) {
        _controller.stop();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _progress => 1.0 - _controller.value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: AnimatedBuilder(
            animation: _controller,
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
