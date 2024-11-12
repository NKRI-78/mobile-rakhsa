import 'package:flutter/material.dart';

class PulseEffectWidget extends StatefulWidget {
  @override
  _PulseEffectWidgetState createState() => _PulseEffectWidgetState();
}

class _PulseEffectWidgetState extends State<PulseEffectWidget>
    with TickerProviderStateMixin {
  late AnimationController pulseAnimation;
  late AnimationController timerController;
  bool isPressed = false;
  int countdownTime = 10;

  @override
  void initState() {
    super.initState();

    pulseAnimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    pulseAnimation.addListener(() {
      if (pulseAnimation.value >= 1.6) {
        debugPrint("Pulse effect completed!");
      }
    });

    timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: countdownTime),
    );
  }

  void startTimer() {
    setState(() {
      isPressed = true;
    });
    timerController.reverse(from: 1.0);
  }

  @override
  void dispose() {
    pulseAnimation.dispose();
    timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (double scaleFactor in [0.8, 1.2, 1.6])
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (BuildContext context, Widget? child) {
                return Transform.scale(
                  scale: pulseAnimation.value * scaleFactor,
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFE1717).withOpacity(0.2 / scaleFactor),
                    ),
                  ),
                );
              },
            ),
          if (isPressed)
            SizedBox(
              width: 145,
              height: 145,
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1FFE17)),
                strokeWidth: 6,
                value: 1 - timerController.value,
                backgroundColor: Colors.transparent,
              ),
            ),
          GestureDetector(
            onLongPress: () {
              if (!isPressed) startTimer();
            },
            child: AnimatedBuilder(
              animation: timerController,
              builder: (BuildContext context, Widget? child) {
                return Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFE1717),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFE1717).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isPressed ? "$countdownTime" : "SOS",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
