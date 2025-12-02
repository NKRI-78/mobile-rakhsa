import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
export 'package:flutter/services.dart';

class StatusBarStyle extends StatelessWidget {
  final Widget child;
  final SystemUiOverlayStyle? style;

  const StatusBarStyle({super.key, this.style, required this.child});

  factory StatusBarStyle.light({
    required Widget child,
    SystemUiOverlayStyle? style,
  }) {
    return StatusBarStyle(
      style:
          style ??
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
      child: child,
    );
  }

  factory StatusBarStyle.dark({
    required Widget child,
    SystemUiOverlayStyle? style,
  }) {
    return StatusBarStyle(
      style:
          style ??
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
          ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          style ??
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
          ),
      child: child,
    );
  }
}
