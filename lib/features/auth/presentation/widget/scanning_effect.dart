import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/features/auth/presentation/provider/register_notifier.dart';

class ScanningEffect extends StatefulWidget {
  final Widget child;
  final Color lineColor;
  final double lineThickness;
  final Duration duration;
  final bool endScan;

  const ScanningEffect({
    super.key,
    required this.child,
    this.lineColor = Colors.red,
    this.lineThickness = 5.0,
    this.duration = const Duration(seconds: 2),
    this.endScan = false,
  });

  @override
  State<ScanningEffect> createState() => _ScanningEffectState();
}

class _ScanningEffectState extends State<ScanningEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.endScan) {
      _animationController.stop();
    }
  }

  @override
  void didUpdateWidget(covariant ScanningEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.endScan && !_animationController.isAnimating) {
      _animationController.stop();
    } else if (!widget.endScan && !_animationController.isAnimating) {
      _animationController.repeat(reverse: false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<RegisterNotifier>(
          builder: (context, notifier, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                widget.child,
                if (!widget.endScan && notifier.scanningText.isNotEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        notifier.scanningText,
                        textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(
                          color: whiteColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                if (!widget.endScan)
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final position = _animation.value * constraints.maxHeight;
                      return Positioned(
                        top: position - (widget.lineThickness / 2),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: widget.lineThickness,
                          color: widget.lineColor.withOpacity(0.7),
                        ),
                      );
                    },
                  ),
              ],
            );
          }
        );
      },
    );
  }
}
