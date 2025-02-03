import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/camera.dart';

import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';

import 'package:rakhsa/features/auth/presentation/pages/login.dart';
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';
import 'package:rakhsa/shared/basewidgets/button/bounce.dart';
import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

class SosButton extends StatefulWidget {
  final String location;
  final String country;
  final String lat;
  final String lng;
  final bool isConnected;
  final bool loadingGmaps;

  const SosButton({
    required this.location,
    required this.country,
    required this.lat, 
    required this.lng,
    required this.isConnected,
    required this.loadingGmaps,
    super.key
  });

  @override
  SosButtonState createState() => SosButtonState();
}

class SosButtonState extends State<SosButton> with TickerProviderStateMixin {

  late SosNotifier sosNotifier;
  late ProfileNotifier profileNotifier;

  void handleLongPressStart() {
    if(profileNotifier.entity.data!.sos.running) {
      GeneralModal.infoEndSos(
        sosId: profileNotifier.entity.data!.sos.id,
        chatId: profileNotifier.entity.data!.sos.chatId,
        recipientId: profileNotifier.entity.data!.sos.recipientId,
        msg: "Apakah kasus Anda sebelumnya telah ditangani ?",
      );
    } else {
      if(StorageHelper.getUserId() == null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const LoginPage();
        }));
      } else {
        sosNotifier.pulseController?.forward();
        sosNotifier.holdTimer = Timer(const Duration(milliseconds: 2000), () {
          sosNotifier.pulseController!.reverse();
          startTimer();
        });
      }
    }
  }

   void handleLongPressEnd() {
    if(StorageHelper.getUserId() == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const LoginPage();
      }));
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
    if(mounted) {
      Navigator.push(context, 
        MaterialPageRoute(builder: (context) {
          return CameraPage(
            location: widget.location, 
            country: widget.country, 
            lat: widget.lat, 
            lng: widget.lng, 
          ); 
        })
      ).then((value) {
        if(value != null) {
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
    profileNotifier = context.read<ProfileNotifier>();
    
    sosNotifier.initializePulse(this);
    sosNotifier.initializeTimer(this);

    if (sosNotifier.isPressed) {
      sosNotifier.resumeTimer();
    }
  }

  @override
  void dispose() {
    sosNotifier.holdTimer?.cancel();

    super.dispose();
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
                          color:const Color(0xFFFE1717).withOpacity(0.2 / scaleFactor)  ,
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
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1FFE17)),
                    strokeWidth: 6,
                    value: 1 - notifier.timerController!.value,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              GestureDetector(
                onLongPressStart: (LongPressStartDetails longPressStartDetails) async => widget.isConnected 
                ? notifier.isTimerRunning 
                ? () {} 
                : widget.loadingGmaps 
                ? () {} 
                : handleLongPressStart() 
                : () {},
                onLongPressEnd: (_) => widget.isConnected 
                ? notifier.isTimerRunning 
                ? () {} 
                : widget.loadingGmaps 
                ? () {} 
                : handleLongPressEnd() 
                : () {},
                child: AnimatedBuilder(
                  animation: notifier.timerController!,
                  builder: (BuildContext context, Widget? child) {
                    return Bouncing(
                      onPress: () async => widget.isConnected 
                      ? notifier.isTimerRunning 
                      ? () {} 
                      : widget.loadingGmaps 
                      ? () {} 
                      : () {} 
                      : () {},
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isConnected
                            ? const Color(0xFFFE1717)
                            : const Color(0xFF7A7A7A),
                          boxShadow: [
                            BoxShadow(
                              color: widget.isConnected 
                              ? const Color(0xFFFE1717).withOpacity(0.5) 
                              : const Color(0xFF7A7A7A).withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          sosNotifier.isPressed ? "${notifier.countdownTime}" : "SOS",
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