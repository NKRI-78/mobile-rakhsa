import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/modules/chat/presentation/pages/chat_room_page.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/sos_rating_notifier.dart';
import 'package:rakhsa/notification_manager.dart';
import 'package:rakhsa/routes/nav_key.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/socketio.dart';

export 'package:fluttertoast/fluttertoast.dart'
    show Fluttertoast, ToastGravity, Toast;

import 'dialog.dart';
import 'overlay_loading.dart';

class AppDialog {
  AppDialog._();

  static OverlayEntry? _entry;
  static bool get isShowing => _entry != null;

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
    bool dismissible = true,
    bool canPop = true,
    List<DialogActionButton> Function(BuildContext c)? buildActions,
    List<DialogActionButton> actions = const <DialogActionButton>[],
  }) {
    return show(
      c: c,
      canPop: canPop,
      dismissible: dismissible,
      content: DialogContent(
        assetIcon: assetIcon ?? AssetSource.iconAlert,
        title: title ?? "Terjadi Kesalahan",
        message: message,
        actions: actions,
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

  static Future<T?> showEndSosDialog<T extends Object?>({
    required String sosId,
    required String chatId,
    required String recipientId,
    String? title,
    bool fromHome = false,
  }) {
    return show(
      c: navigatorKey.currentContext!,
      content: DialogContent(
        assetIcon: "assets/images/ic-alert.png",
        title: title ?? "Akhiri Sesi Bantuan",
        message: "Apakah kasus Anda sebelumnya telah ditangani?",
        buildActions: (c) {
          return [
            DialogActionButton(
              label: "Belum",
              onTap: () {
                c.pop();
                if (fromHome) {
                  Future.delayed(Duration(milliseconds: 300), () {
                    Navigator.push(
                      navigatorKey.currentContext!,
                      MaterialPageRoute(
                        builder: (context) {
                          return ChatRoomPage(
                            sosId: sosId,
                            chatId: chatId,
                            status: "NONE",
                            recipientId: recipientId,
                            autoGreetings: false,
                          );
                        },
                      ),
                    );
                  });
                }
              },
            ),
            DialogActionButton(
              label: "Sudah",
              primary: true,
              onTap: () async {
                c.read<SosRatingNotifier>().sosRating(sosId: sosId);
                c.read<SocketIoService>().userResolvedSos(sosId: sosId);
                c.pop();
                if (!fromHome) {
                  Navigator.pushNamed(c, RoutesNavigation.dashboard);
                }
                await NotificationManager().dismissAllNotification();
              },
            ),
          ];
        },
      ),
    );
  }
}
