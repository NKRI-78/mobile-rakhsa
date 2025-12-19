import 'package:flutter/widgets.dart';

import 'dialog.dart';

class DialogContent {
  final String? assetIcon;
  final String? title;
  final Future<String>? titleAsync;
  final String? message;
  final Widget? messageWidget;
  final Future<String>? messageAsync;
  final DialogStyle? style;
  final Axis? actionButtonDirection;
  final List<DialogActionButton> Function(BuildContext c)? buildActions;

  DialogContent({
    this.assetIcon,
    this.title,
    this.message,
    this.messageWidget,
    this.titleAsync,
    this.messageAsync,
    this.style,
    this.actionButtonDirection,
    this.buildActions,
  });
}

class DialogStyle {
  final double? assetIconSize;
  final bool enableExpandPrimaryActionButton;
  final Color? backgroundIconColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? contentPadding;

  DialogStyle({
    this.titleStyle,
    this.messageStyle,
    this.backgroundColor,
    this.borderRadius,
    this.assetIconSize,
    this.contentPadding,
    this.backgroundIconColor,
    this.enableExpandPrimaryActionButton = false,
  });
}

class DialogActionButtonStyle {
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  DialogActionButtonStyle({
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
  });
}
