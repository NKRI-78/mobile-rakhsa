import 'package:flutter/widgets.dart';

import 'dialog.dart';

class DialogContent {
  final String? assetIcon;
  final String? title;
  final Future<String>? titleAsync;
  final String? message;
  final Future<String>? messageAsync;
  final DialogStyle? style;
  final List<DialogActionButton> actions;

  DialogContent({
    this.assetIcon,
    this.title,
    this.message,
    this.titleAsync,
    this.messageAsync,
    this.style,
    this.actions = const <DialogActionButton>[],
  });
}

class DialogStyle {
  final double? assetIconSize;
  final bool enableBackgroundIcon;
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
    this.enableBackgroundIcon = false,
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
