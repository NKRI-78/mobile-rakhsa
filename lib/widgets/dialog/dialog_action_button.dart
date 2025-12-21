import 'package:flutter/material.dart';
import 'package:rakhsa/core/constants/colors.dart';

import 'dialog.dart';

class DialogActionButton extends StatelessWidget {
  const DialogActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.style,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;
  final DialogActionButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final dBorderRadius = 100.0;
    final dBackgroundColor = primaryColor;
    final dForegroundColor = Colors.white;

    final borderRadius = style?.borderRadius ?? dBorderRadius;
    final backgroundColor = style?.backgroundColor ?? dBackgroundColor;
    final foregroundColor = style?.foregroundColor ?? dForegroundColor;

    final labelText = Text(label, overflow: TextOverflow.ellipsis);

    if (primary) {
      return FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(borderRadius),
          ),
        ),
        child: labelText,
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: backgroundColor),
          borderRadius: BorderRadiusGeometry.circular(borderRadius),
        ),
      ),
      child: labelText,
    );
  }
}
