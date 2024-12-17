import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:grouped_list/grouped_list.dart';

import 'package:rakhsa/common/constants/theme.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/chat/data/models/messages.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';

import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

import 'package:rakhsa/websockets.dart';

class ChatPage extends StatefulWidget {
  final String sosId;
  final String chatId;
  final String status;
  final String recipientId;
  final bool autoGreetings;
  
  const ChatPage({
    required this.sosId,
    required this.chatId,
    required this.status,
    required this.recipientId,
    required this.autoGreetings,
    super.key
  });

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> with WidgetsBindingObserver {

  Timer? debounce;

  bool showAutoGreetings = false;

  late TextEditingController messageC;

  late GetMessagesNotifier messageNotifier; 

  late WebSocketsService webSocketService;
  
  Future<void> getData() async {
    if(!mounted) return;
      messageNotifier.getMessages(chatId: widget.chatId);
  }

  @override 
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    showAutoGreetings = widget.autoGreetings;

    messageNotifier = context.read<GetMessagesNotifier>();
    webSocketService = context.read<WebSocketsService>();

    messageNotifier.startTimer();

    messageC = TextEditingController();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    messageC.dispose();

    debounce?.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("resumed chat page");
    }
    if(state == AppLifecycleState.paused) {
      debugPrint("paused chat page");
    }
    if(state == AppLifecycleState.inactive) {
      debugPrint("inactive chat page");
    }
    if(state == AppLifecycleState.detached) {
      debugPrint("detached chat page");
    }
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        messageNotifier.clearActiveChatId();
        Navigator.pop(context, "refetch");
      },
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            top: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEAEAEA),
              boxShadow: kElevationToShadow[2]
            ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                context.watch<GetMessagesNotifier>().isBtnSessionEnd 
                ? widget.status != "CLOSED" 
                ? CustomButton(
                    onTap: () async {
                      GeneralModal.ratingSos(
                        sosId: widget.sosId
                      );
                    },
                    btnColor: const Color(0xFFC82927),
                    isLoading: context.watch<SosNotifier>().state == ProviderState.loading 
                    ? true 
                    : false,
                    isBorder: false,
                    isBoxShadow: false,
                    isBorderRadius: true,
                    btnTxt: "Apa keluhan sudah ditangani ?",
                  ) 
                : const SizedBox() 
                : const SizedBox(), 

                context.watch<GetMessagesNotifier>().isBtnSessionEnd 
                ? const SizedBox(height: 10.0)
                : const SizedBox(),

                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
              
                    Expanded(
                      flex: 5,
                      child: TextField(
                        maxLines: null,
                        controller: messageC,
                        style: robotoRegular.copyWith(
                          fontSize: 12.0
                        ),
                        readOnly: widget.status == "CLOSED"
                        ? true 
                        : false,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: ColorResources.white,
                          hintText: "ketik pesan singkat dan jelas",
                          hintStyle: robotoRegular.copyWith(
                            fontSize: 12.0,
                            color: Colors.grey
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none
                          ),
                        ),
                      ),
                    ),
          
                    const SizedBox(width: 15.0),
              
                    Flexible(
                      child: IconButton(
                        onPressed: widget.status == "CLOSED" 
                        ? () {} 
                        : () async {
                          if (messageC.text.isEmpty) {
                            return;
                          }

                          webSocketService.sendMessage(
                            chatId: widget.chatId,
                            recipientId: widget.recipientId, 
                            message: messageC.text,
                          );
                      
                          setState(() {
                            messageC.clear();
                            showAutoGreetings = false;
                          });
                        }, 
                        icon: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(50.0))
                          ),
                          child: const Icon(
                            Icons.send,
                            size: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
          
                  ],
                ),
                
              ],
            ) 
          
          ),
        ),
        body: SafeArea(
          child: Consumer<GetMessagesNotifier>(
            builder: (__, notifier, _) {
              return RefreshIndicator(
                onRefresh: () {
                  return Future.sync(() {
                    getData();
                  });
                },
                child: CustomScrollView(
                  controller: notifier.sC,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()
                  ),
                  slivers: [
                          
                    if(notifier.state == ProviderState.loading)
                      const SliverFillRemaining(
                        child: SizedBox()
                      ),
                    
                    if(notifier.state == ProviderState.error)
                      const SliverFillRemaining(
                        child: SizedBox()
                      ),
                
                    if(notifier.state == ProviderState.loaded)
                      SliverAppBar(
                        pinned: true,
                        backgroundColor: const Color(0xFFC82927),
                        automaticallyImplyLeading: false,
                        forceElevated: true,
                        elevation: 1.0,
                        title: Container(
                          margin: const EdgeInsets.only(
                            top: 20.0,
                            bottom: 20.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                      
                                  CupertinoButton(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      messageNotifier.clearActiveChatId();
                                      Navigator.pop(context, "refetch");
                                    },
                                    child: const Icon(Icons.chevron_left,
                                      color: Colors.white,
                                    ),
                                  ),
                
                                  CachedNetworkImage(
                                    imageUrl: notifier.recipient.avatar?.toString() ?? '-',
                                    imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                      return CircleAvatar(
                                        backgroundImage: imageProvider,
                                        radius: 16.0,
                                      );
                                    },
                                    placeholder: (BuildContext context, String url) {
                                      return const CircleAvatar(
                                        backgroundImage: AssetImage('assets/images/default.jpeg'),
                                        radius: 16.0,
                                      );
                                    },
                                    errorWidget: (BuildContext context, String url, Object error) {
                                      return const CircleAvatar(
                                        backgroundImage: AssetImage('assets/images/default.jpeg'),
                                        radius: 16.0,
                                      );
                                    },
                                  ),
                                  
                                  const SizedBox(width: 12.0),
                                  
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      
                                      Text(
                                        notifier.recipient.name?.toString() ?? 'User',
                                        style: robotoRegular.copyWith(
                                          fontSize: 16.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              
                                    ],
                                  ),
                      
                                ],
                              ),

                              Consumer<GetMessagesNotifier>(
                                builder: (BuildContext context, GetMessagesNotifier notifier, Widget? child) {
                                  return Text(notifier.time.toString(),
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      fontWeight: FontWeight.bold,
                                      color: ColorResources.white,
                                    ),
                                  );
                                },
                              )
                              
                            ],
                          ),
                        ),
                      ),
                      
                      if(notifier.state == ProviderState.loaded)
                        SliverToBoxAdapter(
                          child: showAutoGreetings 
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 30.0,
                                    horizontal: 12.0,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0),
                                      bottomLeft: Radius.circular(12.0),
                                      bottomRight: Radius.circular(12.0),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(10.0),
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: ColorResources.white,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "Terima kasih telah menghubungi kami di ",
                                        ),
                                        TextSpan(
                                          text: "Raksha",
                                          style: robotoRegular.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: ColorResources.white,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: ". Apakah yang bisa kami bantu atas keluhan anda?",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ) 
                          : notifier.note.isNotEmpty 
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 30.0,
                                    horizontal: 12.0,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0),
                                      bottomLeft: Radius.circular(12.0),
                                      bottomRight: Radius.circular(12.0),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text("Information : ${notifier.note}",
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: ColorResources.white,
                                    ),
                                  )
                                ),
                            ],
                          ) : const SizedBox(),
                        ),
                          
                     if(notifier.state == ProviderState.loaded)
                       SliverToBoxAdapter(
                         child: GroupedListView<MessageData, DateTime>(
                          shrinkWrap: true,
                          elements: notifier.messages,
                          groupBy: (MessageData item) => DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day),
                          groupComparator: (DateTime value1, DateTime value2) => value2.compareTo(value1),
                          order: GroupedListOrder.DESC,
                          useStickyGroupSeparators: true,
                          groupSeparatorBuilder: (DateTime groupByValue) => Center(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.only(
                                top: 10.0,
                                bottom: 10.0
                              ),
                              child: Center(
                                child: Text(DateFormat("MMMM dd, yyyy").format(groupByValue),
                                  style: robotoRegular.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),
                          ),
                          itemBuilder: (BuildContext context, MessageData item) => ListTile(
                            title: ChatBubble(
                              text: item.text, 
                              time: item.sentTime,
                              isMe: item.user.isMe!,
                              isRead: item.isRead
                            )
                          ),
                        ),
                      )
                  ],
                ),
              );
            },
          ),
        )
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final bool isRead;

  const ChatBubble({
    super.key, 
    required this.text, 
    required this.time,
    required this.isMe,
    required this.isRead
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe 
      ? Alignment.centerRight 
      : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
         
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: isMe ? primaryColor : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMe ? 12.0 : 0.0),
                topRight: Radius.circular(isMe ? 0.0 : 12.0),
                bottomLeft: const Radius.circular(12.0),
                bottomRight: const Radius.circular(12.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(text,
                  style: robotoRegular.copyWith(
                    color: isMe 
                    ? Colors.white 
                    : Colors.black,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),

                const SizedBox(height: 5.0),

              ],
            ) 
          ),

          isMe 
          ? Text(time,
            style: robotoRegular.copyWith(
              color: ColorResources.black,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ) 
          : Text(time,
            style: robotoRegular.copyWith(
              color: ColorResources.black,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ) 

        ],
      ) 
    );
  }
}