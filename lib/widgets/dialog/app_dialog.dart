import 'package:flutter/material.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';

import 'dialog.dart';

class AppDialog {
  static Future<T?> show<T extends Object?>({
    required BuildContext c,
    required DialogContent content,
    bool canPop = true,
    bool dismissible = true,
    bool withAnimation = true,
  }) {
    if (withAnimation) {
      return showGeneralDialog(
        context: c,
        barrierDismissible: dismissible,
        barrierLabel: dismissible ? "" : null,
        transitionBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        pageBuilder: (_, _, _) =>
            PopScope(canPop: canPop, child: DialogCard(content)),
      );
    }
    return showDialog(
      context: c,
      barrierDismissible: dismissible,
      builder: (_) => PopScope(canPop: canPop, child: DialogCard(content)),
    );
  }

  static Future<T?> error<T extends Object?>({
    required BuildContext c,
    required String message,
    String? assetIcon,
    String? title,
    List<DialogActionButton> actions = const [],
  }) {
    return show(
      c: c,
      content: DialogContent(
        assetIcon: assetIcon ?? AssetSource.iconAlert,
        title: title ?? "Terjadi Kesalahan",
        message: message,
        actions: actions.isEmpty
            ? [
                DialogActionButton(
                  label: "Coba Lagi",
                  primary: true,
                  onTap: () => c.pop(true),
                ),
              ]
            : actions,
      ),
    );
  }
}
