import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/modules/chat/presentation/pages/chat_room_page.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/sos_rating_notifier.dart';
import 'package:rakhsa/routes/nav_key.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/service/notification/notification_manager.dart';
import 'package:rakhsa/service/socket/socketio.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';

class EndSosDialog extends StatelessWidget {
  const EndSosDialog._(
    this.fromHome,
    this.sosId,
    this.chatId,
    this.recipientId,
    this.title,
  );

  final bool fromHome;
  final String sosId;
  final String chatId;
  final String recipientId;
  final String title;

  static Future<bool?> launch({
    required String sosId,
    required String chatId,
    required String recipientId,
    String title = "Akhiri Sesi Bantuan",
    bool fromHome = false,
  }) async {
    return AppDialog.show<bool?>(
      c: navigatorKey.currentContext!,
      customDialogBuilder: (_) {
        return EndSosDialog._(fromHome, sosId, chatId, recipientId, title);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DialogCard(
      DialogContent(
        assetIcon: "assets/images/ic-alert.png",
        title: title,
        message: "Apakah kasus Anda sebelumnya telah ditangani?",
        buildActions: (c) {
          return [
            DialogActionButton(
              label: "Belum",
              onTap: () {
                c.pop(false);
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
                c.pop(true);
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
