import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:provider/provider.dart';

import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/chat/presentation/pages/chat.dart';
import 'package:rakhsa/features/chat/presentation/pages/detail.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_chats_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_inbox_notifier.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => ChatsPageState();
}

class ChatsPageState extends State<ChatsPage> {

  late GetChatsNotifier getListChatNotifier; 
  late GetInboxNotifier getInboxNotifier;
  
  Future<void> getData() async {
    if(!mounted) return;
      getListChatNotifier.getChats();

    if(!mounted) return; 
      getInboxNotifier.getInbox();
  }

  @override 
  void initState() {
    super.initState();

    getListChatNotifier = context.read<GetChatsNotifier>();
    getInboxNotifier = context.read<GetInboxNotifier>();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    super.dispose();
  }

  Color status(val) {
    Color color;
    switch (val) {
      case "PROCESS":
        color = Colors.blue;
      break;
      case "RESOLVED":
        color =Colors.grey;
      break;
      case "CLOSED":
        color = Colors.red;
      break;
      default:
        color = Colors.blue;
    }
    return color;
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
        child: CustomScrollView(
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

            if(context.watch<GetChatsNotifier>().state == ProviderState.loading && context.watch<GetInboxNotifier>().state == ProviderState.loading)
              const SliverFillRemaining(
                child: Center(
                  child: SpinKitChasingDots(
                    color: primaryColor,
                  )
                )
              ),
            
            if(context.watch<GetChatsNotifier>().state == ProviderState.empty && context.watch<GetInboxNotifier>().state == ProviderState.empty) 
              SliverFillRemaining(
                child: Center(
                  child: Text("Belum ada notifikasi",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  )
                )
              ),

            if(context.watch<GetChatsNotifier>().state == ProviderState.error && context.watch<GetInboxNotifier>().state == ProviderState.error)
              SliverFillRemaining(
                child: Center(
                  child: Text(context.read<GetChatsNotifier>().message,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault
                    ),
                  )
                ),
              ),

            // SliverToBoxAdapter(
            //   child:  Container(
            //     margin: const EdgeInsets.only(
            //       top: 20.0,
            //       left: 16.0,
            //       right: 16.0
            //     ),
            //     child: Text("Chats",
            //       style: robotoRegular.copyWith(
            //         fontSize: Dimensions.fontSizeLarge,
            //         fontWeight: FontWeight.bold,
            //         color: ColorResources.black
            //       ),
            //     )
            //   ),
            // ),

            SliverToBoxAdapter(
              child: context.watch<GetChatsNotifier>().state == ProviderState.empty 
              ? const SizedBox() 
              : Container(
                  margin: const EdgeInsets.only(
                    top: 20.0,
                    left: 16.0,
                    right: 16.0
                  ),
                  child: Text("Chats",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: ColorResources.black
                    ),
                  )
                ),
              ),

            SliverList.builder(
              itemCount: context.read<GetChatsNotifier>().chats.length * 2 - 1,
              itemBuilder: (BuildContext context, int i) {
                final chatData = context.read<GetChatsNotifier>().chats;

                if (i.isEven) {
                  final chat = chatData[i ~/ 2];
                  return Container(
                    margin: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8.0
                    ),
                    decoration: const BoxDecoration(
                      color:Colors.transparent
                    ),
                    child: ListTile(
                      onTap: () async {
                        StorageHelper.saveRecordScreen(isHome: false);

                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return ChatPage(
                            sosId: chat.sosId,
                            recipientId: chat.user.id,
                            chatId: chat.chat.id,
                            status: chat.status,
                            autoGreetings: false,
                          );
                        })).then((_) {
                          getData();
                        });
                      },
                      title: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(chat.user.name,
                            style: robotoRegular.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(width: 10.0),

                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0),
                              color: status(chat.status),
                            ),
                            child: Text(chat.status,
                              style: robotoRegular.copyWith(
                                color: ColorResources.white,
                                fontSize: Dimensions.fontSizeExtraSmall,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          )
                        ],
                      ),
                      subtitle: chat.messages.isEmpty 
                      ? const SizedBox() 
                      : Text(chat.messages.first.content,
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                          style: robotoRegular.copyWith(
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
                        placeholder: (BuildContext context, String url) {
                          return const CircleAvatar(
                            backgroundImage: AssetImage('assets/images/user.png'),
                          );
                        },
                        errorWidget: (BuildContext context, String url, dynamic error) {
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
                          ],
                        ),
                      ),
                  );
                } else {
                  return const Divider();
                }
              },
            ),

            SliverToBoxAdapter(
              child: context.watch<GetInboxNotifier>().state == ProviderState.empty 
              ? const SizedBox() 
              : Container(
                  margin: const EdgeInsets.only(
                    top: 20.0,
                    left: 16.0,
                    right: 16.0
                  ),
                  child: Text("Payment",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: ColorResources.black
                    ),
                  )
                ),
              ),

            SliverList.builder(
              itemCount: context.read<GetInboxNotifier>().inbox.length * 2 - 1,
              itemBuilder: (BuildContext context, int i) {
                final inboxData = context.read<GetInboxNotifier>().inbox;

                if (i.isEven) {
                  final inbox = inboxData[i ~/ 2];
                  return Container(
                    margin: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8.0
                    ),
                    decoration: const BoxDecoration(
                      color:Colors.transparent
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return InboxDetailPage(
                            id: inbox.id,
                          );
                        }));
                      },
                      title: Text(inbox.title,
                        maxLines: 2,
                        style: robotoRegular.copyWith(
                          fontWeight: inbox.isRead 
                          ? FontWeight.normal 
                          : FontWeight.bold,
                          fontSize: Dimensions.fontSizeSmall
                        ),
                      ),
                      trailing: Text(inbox.field2),
                      leading: const Icon(
                        Icons.payment,
                        color: ColorResources.black,
                      ),
                    ),
                  );
                } else {
                  return const Divider();
                }
              },
            ),
        
          ],
        )
      )
    );            
    
  }


}