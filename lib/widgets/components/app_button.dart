import 'package:flutter/material.dart';
import 'package:rakhsa/core/constants/colors.dart';

enum AppButtonType { filled, outlined, text }

enum AppButtonIconPosition { start, end }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style,
    this.type = .filled,
    this.iconPosition = .start,
    this.padding = const .all(8),
  });

  final String label;
  final IconData? icon;
  final AppButtonType type;
  final AppButtonStyle? style;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final AppButtonIconPosition iconPosition;

  @override
  Widget build(BuildContext context) {
    final borderRadius = style?.borderRadius ?? .circular(8);

    final children = [
      if (icon != null && iconPosition == .start) Icon(icon),
      Text(label),
      if (icon != null && iconPosition == .end) Icon(icon),
    ];

    final child = Row(
      spacing: 6,
      mainAxisSize: .min,
      mainAxisAlignment: .center,
      children: children,
    );

    return switch (type) {
      .filled => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: style?.backgroundColor ?? primaryColor,
          foregroundColor: style?.foregroundColor ?? Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: child,
      ),
      .outlined => OutlinedButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          foregroundColor: style?.foregroundColor ?? primaryColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: child,
      ),
      .text => TextButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          foregroundColor: style?.foregroundColor ?? primaryColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: child,
      ),
    };
  }
}

class AppButtonStyle {
  final Color? backgroundColor;
  final Color? foregroundColor;

  final BorderRadiusGeometry? borderRadius;

  AppButtonStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  });
}
