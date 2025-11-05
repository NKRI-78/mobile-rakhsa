import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/modules/chat/presentation/pages/chat.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/sos_rating_notifier.dart';
import 'package:rakhsa/routes/nav_key.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/socketio.dart';

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
    bool canPop = true,
    List<DialogActionButton> actions = const <DialogActionButton>[],
  }) {
    return show(
      c: c,
      canPop: canPop,
      content: DialogContent(
        assetIcon: assetIcon ?? AssetSource.iconAlert,
        title: title ?? "Terjadi Kesalahan",
        message: message,
        actions: actions,
      ),
    );
  }

  static Future<T?> showEndSosDialog<T extends Object?>({
    required String sosId,
    required String chatId,
    required String recipientId,
    bool fromHome = false,
  }) {
    return show(
      c: navigatorKey.currentContext!,
      content: DialogContent(
        assetIcon: "assets/images/ic-alert.png",
        title: "Akhiri Sesi Bantuan",
        message: "Apakah kasus Anda sebelumnya telah ditangani?",
        buildActions: (c) {
          return [
            DialogActionButton(
              label: "Belum",
              onTap: () {
                c.pop();
                if (fromHome) {
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.push(
                      navigatorKey.currentContext!,
                      MaterialPageRoute(
                        builder: (context) {
                          return ChatPage(
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
              onTap: () {
                c.read<SosRatingNotifier>().sosRating(sosId: sosId);
                c.read<SocketIoService>().userResolvedSos(sosId: sosId);
                c.pop();
                if (!fromHome) {
                  Navigator.pushNamed(c, RoutesNavigation.dashboard);
                }
              },
            ),
          ];
        },
      ),
    );
  }
}
