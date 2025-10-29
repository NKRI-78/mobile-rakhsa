import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/camera.dart';
import 'package:rakhsa/injection.dart';

import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/misc/helpers/vibration_manager.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';

import 'package:rakhsa/modules/auth/page/login_page.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/expire_sos_notifier.dart';
import 'package:rakhsa/repositories/user/model/user.dart';
import 'package:rakhsa/widgets/components/button/bounce.dart';
import 'package:rakhsa/widgets/components/modal/modal.dart';

class SosButtonParam {
  final String location;
  final String country;
  final String lat;
  final String lng;
  final bool isConnected;
  final bool loadingGmaps;
  final User? profile;

  SosButtonParam({
    required this.location,
    required this.country,
    required this.lat,
    required this.lng,
    required this.isConnected,
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

class SosButtonState extends State<SosButton> with TickerProviderStateMixin {
  late SosNotifier sosNotifier;

  Future<void> handleLongPressStart() async {
    log("local profile data = ${widget.param.profile}");
    if (widget.param.profile?.sos?.running ?? false) {
      GeneralModal.infoEndSos(
        sosId: widget.param.profile?.sos?.id ?? "-",
        chatId: widget.param.profile?.sos?.chatId ?? "-",
        recipientId: widget.param.profile?.sos?.recipientId ?? "-",
        msg: "Apakah kasus Anda sebelumnya telah ditangani ?",
        isHome: true,
      );
    } else {
      if (!await StorageHelper.isLoggedIn()) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const LoginPage();
              },
            ),
          );
        }
      } else {
        sosNotifier.pulseController?.forward();
        sosNotifier.holdTimer = Timer(const Duration(milliseconds: 2000), () {
          sosNotifier.pulseController!.reverse();
          startTimer();
        });
      }
    }
  }

  void handleLongPressEnd() async {
    if (!await StorageHelper.isLoggedIn()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const LoginPage();
            },
          ),
        );
      }
    } else {
      if (sosNotifier.holdTimer?.isActive ?? false) {
        sosNotifier.holdTimer?.cancel();
        sosNotifier.pulseController!.reverse();
      } else if (!sosNotifier.isPressed) {
        setState(() => sosNotifier.isPressed = false);
      }
    }
  }

  Future<void> startTimer() async {
    locator<VibrationManager>().vibrate();
    if (mounted) {
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
      ).then((value) {
        if (value != null) {
          sosNotifier.startTimer();
        } else {
          sosNotifier.resetAnimation();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    sosNotifier = context.read<SosNotifier>();

    sosNotifier.initializePulse(this);
    sosNotifier.initializeTimer(this);

    if (sosNotifier.isPressed) {
      sosNotifier.resumeTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SosNotifier>(
      builder: (BuildContext context, SosNotifier notifier, Widget? child) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (double scaleFactor in [0.8, 1.2, 1.4])
                AnimatedBuilder(
                  animation: notifier.pulseAnimation,
                  builder: (BuildContext context, Widget? child) {
                    return Transform.scale(
                      scale: notifier.pulseAnimation.value * scaleFactor,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFFFE1717,
                          ).withValues(alpha: 0.2 / scaleFactor),
                        ),
                      ),
                    );
                  },
                ),
              if (notifier.isPressed)
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF1FFE17),
                    ),
                    strokeWidth: 6,
                    value: 1 - notifier.timerController!.value,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              GestureDetector(
                onLongPressStart:
                    (LongPressStartDetails longPressStartDetails) async =>
                        widget.param.isConnected
                        ? notifier.isTimerRunning
                              ? () {}
                              : widget.param.loadingGmaps
                              ? () {}
                              : await handleLongPressStart()
                        : () {},
                onLongPressEnd: (_) => widget.param.isConnected
                    ? notifier.isTimerRunning
                          ? () {}
                          : widget.param.loadingGmaps
                          ? () {}
                          : handleLongPressEnd()
                    : () {},
                child: AnimatedBuilder(
                  animation: notifier.timerController!,
                  builder: (BuildContext context, Widget? child) {
                    return Bouncing(
                      onPress: () async => widget.param.isConnected
                          ? notifier.isTimerRunning
                                ? () {}
                                : widget.param.loadingGmaps
                                ? () {}
                                : () {}
                          : () {},
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.param.isConnected
                              ? const Color(0xFFFE1717)
                              : const Color(0xFF7A7A7A),
                          boxShadow: [
                            BoxShadow(
                              color: widget.param.isConnected
                                  ? const Color(
                                      0xFFFE1717,
                                    ).withValues(alpha: 0.5)
                                  : const Color(
                                      0xFF7A7A7A,
                                    ).withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          sosNotifier.isPressed
                              ? "${notifier.countdownTime}"
                              : "SOS",
                          style: robotoRegular.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
