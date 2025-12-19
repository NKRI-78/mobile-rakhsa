import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/widgets/avatar.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar(this.chatId, {super.key});

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      backgroundColor: primaryColor,
      leading: CupertinoNavigationBarBackButton(
        color: Colors.white,
        onPressed: context.pop,
      ),
      title: Consumer<GetMessagesNotifier>(
        builder: (context, notifier, child) {
          final agentIsTyping = notifier.isTyping(chatId);

          final recipients = notifier.recipients;
          final isSingleAdmin = recipients.length == 1;
          final usernames = recipients.isEmpty
              ? '-'
              : isSingleAdmin
              ? (recipients[0].name ?? '-')
              : '${recipients[0].name ?? "-"} & ${recipients[1].name ?? "-"}';

          return GestureDetector(
            onTap: () => _showRecipientOverview(context, usernames),
            child: Row(
              spacing: isSingleAdmin ? 10 : 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (notifier.recipients.isNotEmpty)
                  Avatar(
                    src: notifier.recipients[0].avatar,
                    initial: notifier.recipients[0].name,
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usernames,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: isSingleAdmin ? 18 : 16,
                        ),
                      ),

                      if (agentIsTyping)
                        Text(
                          "Sedang mengetik...",
                          style: robotoRegular.copyWith(
                            fontSize: 10.0,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  void _showRecipientOverview(BuildContext context, String usernames) {
    AppDialog.show(
      c: context,
      content: DialogContent(
        message: "Anda sekarang terhubung dengan $usernames",
        buildActions: (c) {
          return [
            DialogActionButton(label: "Mengerti", primary: true, onTap: c.pop),
          ];
        },
      ),
    );
  }
}
