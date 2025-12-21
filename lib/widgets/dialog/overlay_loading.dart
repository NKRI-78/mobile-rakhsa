import 'package:flutter/material.dart';
import 'package:rakhsa/core/constants/colors.dart';

class OverlayLoading extends StatelessWidget {
  final String? message;
  final bool dismissible;
  final VoidCallback onDismissRequested;
  final Color barrierColor;

  const OverlayLoading({
    super.key,
    this.message,
    required this.dismissible,
    required this.onDismissRequested,
    required this.barrierColor,
  });

  @override
  Widget build(BuildContext context) {
    final boxSize = (message != null ? 120 : 90).toDouble();

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // barrier
          Positioned.fill(
            child: dismissible
                ? GestureDetector(
                    onTap: onDismissRequested,
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: barrierColor),
                  )
                : AbsorbPointer(child: Container(color: barrierColor)),
          ),

          Center(
            child: Semantics(
              container: true,
              label: message ?? 'Loading',
              child: Container(
                width: boxSize,
                height: boxSize,
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: primaryColor,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        message!,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
