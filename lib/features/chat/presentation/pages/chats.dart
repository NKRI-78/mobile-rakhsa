import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/common/constants/theme.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/chat/presentation/pages/chat.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_chats_notifier.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => ChatsPageState();
}

class ChatsPageState extends State<ChatsPage> {

  late GetChatsNotifier getListChatNotifier; 
  
  Future<void> getData() async {
    if(!mounted) return;
      getListChatNotifier.getChats();
  }

  @override 
  void initState() {
    super.initState();

    getListChatNotifier = context.read<GetChatsNotifier>();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:  RefreshIndicator.adaptive(
        onRefresh: () {
          return Future.sync(() {
            getData();
          });
        },
        child: Consumer<GetChatsNotifier>(
          builder: (__, notifier, _) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()
              ),
              slivers: [
            
                SliverAppBar(
                  backgroundColor: primaryColor,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  title: Text("Notification",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      fontWeight: FontWeight.bold,
                      color: ColorResources.white
                    ),
                  ),
                  leading: CupertinoNavigationBarBackButton(
                    color: ColorResources.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                if(notifier.state == ProviderState.loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator()
                    )
                  ),
                
                if(notifier.chats.isEmpty) 
                  SliverFillRemaining(
                    child: Center(
                      child: Text("Belum ada notifikasi",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      )
                    )
                  ),

                if(notifier.state == ProviderState.error)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(notifier.message,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault
                        ),
                      )
                    ),
                  ),

                SliverList.builder(
                  itemCount: notifier.chats.length * 2 - 1,
                  itemBuilder: (BuildContext context, int i) {
                    final chatData = notifier.chats;

                    if (i.isEven) {
                      final chat = chatData[i ~/ 2];
                      return ListTile(
                        onTap: () async {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return ChatPage(
                              recipientId: chat.user.id,
                              chatId: chat.chat.id,
                            );
                          }));
                        },
                        title: Text(chat.user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: chat.messages.isEmpty 
                        ? const SizedBox() 
                        : Text(chat.messages.first.content,
                            maxLines: 2,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                              fontSize: 10.0
                            ),
                          ),
                        leading: CachedNetworkImage(
                          imageUrl: chat.user.avatar,
                          imageBuilder: (context, imageProvider) {
                            return CircleAvatar(
                              backgroundImage: imageProvider,
                            );
                          },
                          placeholder: (context, url) {
                            return const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/user.png'),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/user.png'),
                            );
                          },
                        ),
                        trailing: chat.messages.isEmpty 
                        ? const SizedBox() 
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              Text(chat.messages.first.time),

                              chat.messages.first.isMe 
                              ? const SizedBox(height: 8.0)   
                              : const SizedBox(),
 
                              chat.messages.first.isMe 
                              ? Icon(Icons.mark_email_read,
                                  size: 18.0,
                                  color: chat.messages.first.isRead 
                                  ? Colors.blue[800]
                                  : Colors.black,
                                )  
                              : chat.countUnread == 0 
                              ? const SizedBox() 
                              : Badge(
                                  alignment: Alignment.topRight,
                                  offset: const Offset(4, -8),
                                  label: Text(chat.countUnread.toString()),
                                )
                            ],
                          ),
                        );
                    } else {
                      return const Divider();
                    }
                  },
                ),
            
              ],
            );

          },
        )
      )
    );            
    
  }


}