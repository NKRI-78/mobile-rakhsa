import 'package:flutter/material.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';

export 'package:fluttertoast/fluttertoast.dart'
    show Fluttertoast, ToastGravity, Toast;

import 'dialog.dart';
import 'overlay_loading.dart';

class AppDialog {
  AppDialog._();

  static OverlayEntry? _entry;
  static bool get isShowing => _entry != null;

  static Duration get animDuration => Duration(milliseconds: 250);

  static Future<T?> show<T extends Object?>({
    required BuildContext c,
    DialogContent? content,
    bool canPop = true,
    bool dismissible = true,
    bool withAnimation = true,
    Widget Function(BuildContext dc)? customDialogBuilder,
  }) {
    if (withAnimation) {
      return showGeneralDialog(
        context: c,
        barrierDismissible: dismissible,
        transitionDuration: animDuration,
        barrierLabel: dismissible ? "" : null,
        transitionBuilder: (ctx, anim, _, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutBack,
          );
          final scale = Tween<double>(begin: 0.5, end: 1.0).evaluate(curved);
          final opacity = Tween<double>(begin: 0.0, end: 1.0).evaluate(curved);
          return FadeTransition(
            opacity: AlwaysStoppedAnimation(opacity),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: child,
            ),
          );
        },
        pageBuilder: (context, _, _) {
          return PopScope(
            canPop: canPop,
            child: customDialogBuilder?.call(context) ?? DialogCard(content),
          );
        },
      );
    }
    return showDialog(
      context: c,
      barrierDismissible: dismissible,
      builder: (context) {
        return PopScope(
          canPop: canPop,
          child: customDialogBuilder?.call(context) ?? DialogCard(content),
        );
      },
    );
  }

  static Future<T?> error<T extends Object?>({
    required BuildContext c,
    required String message,
    String? assetIcon,
    String? title,
    bool dismissible = true,
    bool canPop = true,
    List<DialogActionButton> Function(BuildContext c)? buildActions,
  }) {
    return show(
      c: c,
      canPop: canPop,
      dismissible: dismissible,
      content: DialogContent(
        assetIcon: assetIcon ?? AssetSource.iconAlert,
        title: title ?? "Terjadi Kesalahan",
        message: message,
        buildActions: buildActions,
      ),
    );
  }

  static Future<bool?> showToast(
    String message, {
    ToastGravity? gravity = ToastGravity.BOTTOM,
    Toast? length = Toast.LENGTH_SHORT,
    bool enableCancel = true,
  }) async {
    if (enableCancel) await cancelToast();
    return Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      gravity: gravity,
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }

  static Future<bool?> cancelToast() => Fluttertoast.cancel();

  static void showLoading(
    BuildContext context, {
    String? message,
    bool dismissible = false,
    Color barrierColor = Colors.black54,
  }) {
    if (_entry != null) return;

    final overlayState = Overlay.of(context, rootOverlay: true);

    _entry = OverlayEntry(
      builder: (context) => OverlayLoading(
        message: message,
        dismissible: dismissible,
        barrierColor: barrierColor,
        onDismissRequested: () => dismissLoading(),
      ),
    );

    overlayState.insert(_entry!);
  }

  static void dismissLoading() {
    try {
      _entry?.remove();
    } catch (_) {}
    _entry = null;
  }
}
