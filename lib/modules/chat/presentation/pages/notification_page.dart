import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:provider/provider.dart';

import 'package:rakhsa/core/constants/colors.dart';
import 'package:rakhsa/core/enums/provider_state.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/modules/chat/data/models/chats.dart';
import 'package:rakhsa/modules/chat/presentation/pages/chat_room_page.dart';

import 'package:rakhsa/modules/chat/presentation/provider/get_chats_notifier.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/widgets/avatar.dart';
import 'package:shimmer/shimmer.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchChats();
    });
  }

  Future<void> fetchChats() async {
    await context.read<GetChatsNotifier>().getChats();
  }

  void _navigateToChatRoom(ChatsData c) {
    ChatRoomRoute(
      ChatRoomParams(
        chatId: c.chat.id,
        sosId: c.sosId,
        recipientId: c.user.id,
        autoGreetings: false,
        status: c.status,
        newSession: false,
      ),
    ).push(context);
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(color: Colors.white);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: Consumer<GetChatsNotifier>(
          builder: (context, n, child) {
            if (n.state == ProviderState.loading) {
              return Row(
                spacing: 12,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Memuat Notifikasi",
                    style: titleStyle.copyWith(fontSize: 16),
                  ),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 1.5,
                    ),
                  ),
                ],
              );
            }
            return Text("Notifikasi", style: titleStyle);
          },
        ),
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: context.pop,
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: fetchChats,
        color: primaryColor,
        child: Consumer<GetChatsNotifier>(
          builder: (context, n, child) {
            if (n.state != ProviderState.loaded) {
              return _buildIdleOrErrorState(n);
            }
            return _buildChatList(n.chats);
          },
        ),
      ),
    );
  }

  Widget _buildIdleOrErrorState(GetChatsNotifier n) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        if (n.state == ProviderState.loading) ...[
          Shimmer.fromColors(
            highlightColor: Colors.grey.shade100,
            baseColor: Colors.grey.shade300,
            child: Container(
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(IconsaxPlusLinear.danger, size: 32),
                6.spaceY,

                Text(
                  "Gagal Memuat Chat",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                14.spaceY,

                Text(n.message, textAlign: TextAlign.center),
                7.spaceY,

                Row(
                  spacing: 6,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Seret kebawah untuk memuat ulang",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    Icon(
                      IconsaxPlusLinear.arrow_down_1,
                      size: 20,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChatList(List<ChatsData> chats) {
    if (chats.isEmpty) {
      return ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(IconsaxPlusLinear.message, size: 32),
                6.spaceY,

                Text(
                  "Belum Ada Sesi Chat",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                14.spaceY,

                Text(
                  "Chat akan muncul di sini setelah Anda mengirim SOS atau saat sesi bantuan dimulai.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      itemCount: chats.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, i) {
        final c = chats[i];
        return ListTile(
          leading: Avatar(src: c.user.avatar, initial: c.user.name),
          title: Text(
            c.user.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: c.messages.isNotEmpty
              ? Text(
                  c.messages.first.content,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  style: TextStyle(fontSize: 10.0),
                )
              : null,
          onTap: () => _navigateToChatRoom(c),
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: switch (c.status) {
                "PROCESS" => Colors.blue,
                "RESOLVED" => Colors.grey,
                "CLOSED" => Colors.red,
                _ => Colors.blue,
              },
            ),
            child: Text(
              c.status,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
        );
      },
    );
  }
}
