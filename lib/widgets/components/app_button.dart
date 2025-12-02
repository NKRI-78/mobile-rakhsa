import 'package:flutter/material.dart';
import 'package:rakhsa/misc/constants/theme.dart';

enum AppButtonType { filled, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.padding,
    this.type = AppButtonType.filled,
    this.borderRadius = BorderRadius.zero,
  });

  final String label;
  final AppButtonType type;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      AppButtonType.filled => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: Text(label),
      ),
      AppButtonType.outlined => OutlinedButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          foregroundColor: primaryColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: Text(label),
      ),
      AppButtonType.text => TextButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          foregroundColor: primaryColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: Text(label),
      ),
    };
  }
}
