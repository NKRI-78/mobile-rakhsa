import 'dart:async';

import 'package:uuid/uuid.dart' as uuid;

import 'package:intl/intl.dart';
import 'package:rakhsa/socketio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/chat/presentation/provider/insert_message_notifier.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/expire_sos_notifier.dart';

import 'package:rakhsa/widgets/components/button/custom.dart';
import 'package:rakhsa/widgets/components/modal/modal.dart';

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
    super.key,
  });

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  Timer? debounce;

  bool showAutoGreetings = false;

  List<Map<String, dynamic>> unsentMessages = [];

  ScrollController sC = ScrollController();

  late TextEditingController messageC;

  late InsertMessageNotifier insertMessageNotifier;
  late GetMessagesNotifier messageNotifier;
  late SocketIoService socketIoService;

  Future<void> getData() async {
    if (!mounted) return;
    messageNotifier.getMessages(chatId: widget.chatId, status: widget.status);

    Future.delayed(const Duration(seconds: 1), () {
      if (sC.hasClients) {
        sC.animateTo(
          sC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        setState(() {});
      }
    });

    socketIoService.socket?.on("message", (message) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (sC.hasClients) {
          sC.animateTo(
            sC.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          setState(() {});
        }
      });
    });
  }

  Future<void> sendMessage() async {
    final session = await StorageHelper.getUserSession();
    if (messageC.text.trim().isEmpty) {
      return;
    }

    String createdAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    socketIoService.sendMessage(
      chatId: widget.chatId,
      recipientId: widget.recipientId,
      message: messageC.text,
      createdAt: createdAt,
    );

    String sentTime =
        "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";

    Map<String, dynamic> message = {
      "id": const uuid.Uuid().v4(),
      "chat_id": widget.chatId,
      "user": {
        "id": session?.user.id,
        "is_me": true,
        "avatar": "-",
        "name": "-",
      },
      "is_read": false,
      "sent_time": sentTime,
      "created_at": createdAt,
      "text": messageC.text,
    };

    messageNotifier.appendMessage(data: message);

    setState(() {
      messageC.clear();
      showAutoGreetings = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (sC.hasClients) {
        sC.animateTo(
          sC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        setState(() {});
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        // Future.microtask(() => getData());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void handleTyping() {
    if (messageC.text.isNotEmpty) {
      socketIoService.typing(
        chatId: widget.chatId,
        recipientId: widget.recipientId,
        isTyping: true,
      );

      if (debounce != null) {
        debounce!.cancel();
      }

      debounce = Timer(const Duration(seconds: 1), () {
        socketIoService.typing(
          chatId: widget.chatId,
          recipientId: widget.recipientId,
          isTyping: false,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    sC = ScrollController();

    showAutoGreetings = widget.autoGreetings;

    messageNotifier = context.read<GetMessagesNotifier>();
    insertMessageNotifier = context.read<InsertMessageNotifier>();
    socketIoService = context.read<SocketIoService>();

    socketIoService.subscribeChat(widget.chatId);

    messageNotifier.startTimer();

    messageC = TextEditingController();
    messageC.addListener(handleTyping);

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    socketIoService.unsubscribeChat(widget.chatId);

    sC.dispose();

    messageC.removeListener(handleTyping);
    messageC.dispose();

    debounce?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        StorageHelper.saveRecordScreen(isHome: false);
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
          child:
              widget.status == "CLOSED" ||
                  context.watch<GetMessagesNotifier>().note.isNotEmpty
              ? Consumer<GetMessagesNotifier>(
                  builder:
                      (
                        BuildContext context,
                        GetMessagesNotifier notifier,
                        Widget? child,
                      ) {
                        if (notifier.state == ProviderState.loading) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAEAEA),
                            ),
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "...",
                                  textAlign: TextAlign.center,
                                  style: robotoRegular.copyWith(
                                    color: ColorResources.black,
                                    fontSize: Dimensions.fontSizeDefault,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAEAEA),
                          ),
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                notifier.note,
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  color: ColorResources.black,
                                  fontSize: Dimensions.fontSizeDefault,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                )
              : Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEAEA),
                    boxShadow: kElevationToShadow[2],
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      context.watch<GetMessagesNotifier>().isBtnSessionEnd
                          ? CustomButton(
                              onTap: () async {
                                GeneralModal.infoEndSos(
                                  sosId: widget.sosId,
                                  chatId: "-",
                                  recipientId: "-",
                                  msg:
                                      "Apakah kasus Anda sebelumnya telah ditangani ?",
                                  isHome: false,
                                );
                              },
                              btnColor: const Color(0xFFC82927),
                              isLoading:
                                  context.watch<SosNotifier>().state ==
                                      ProviderState.loading
                                  ? true
                                  : false,
                              isBorder: false,
                              isBoxShadow: false,
                              isBorderRadius: true,
                              btnTxt: "Apa keluhan sudah ditangani ?",
                            )
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
                              style: robotoRegular.copyWith(fontSize: 12.0),
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: ColorResources.white,
                                hintText: "ketik pesan singkat dan jelas",
                                hintStyle: robotoRegular.copyWith(
                                  fontSize: 12.0,
                                  color: Colors.grey,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 15.0),

                          Flexible(
                            child: IconButton(
                              onPressed: sendMessage,
                              icon: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50.0),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.send,
                                  size: 20.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
        body: SafeArea(
          child: Consumer<GetMessagesNotifier>(
            builder:
                (
                  BuildContext context,
                  GetMessagesNotifier notifier,
                  Widget? child,
                ) {
                  return CustomScrollView(
                    controller: sC,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
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
                                    child: const Icon(
                                      Icons.chevron_left,
                                      color: Colors.white,
                                    ),
                                  ),

                                  CachedNetworkImage(
                                    imageUrl:
                                        notifier.recipient.avatar?.toString() ??
                                        '-',
                                    imageBuilder:
                                        (
                                          BuildContext context,
                                          ImageProvider<Object> imageProvider,
                                        ) {
                                          return CircleAvatar(
                                            backgroundImage: imageProvider,
                                            radius: 16.0,
                                          );
                                        },
                                    placeholder:
                                        (BuildContext context, String url) {
                                          return const CircleAvatar(
                                            backgroundImage: AssetImage(
                                              'assets/images/default.jpeg',
                                            ),
                                            radius: 16.0,
                                          );
                                        },
                                    errorWidget:
                                        (
                                          BuildContext context,
                                          String url,
                                          Object error,
                                        ) {
                                          return const CircleAvatar(
                                            backgroundImage: AssetImage(
                                              'assets/images/default.jpeg',
                                            ),
                                            radius: 16.0,
                                          );
                                        },
                                  ),

                                  const SizedBox(width: 12.0),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        notifier.recipient.name?.toString() ??
                                            'User',
                                        style: robotoRegular.copyWith(
                                          fontSize: 16.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 4.0),

                                      notifier.isTyping(widget.chatId)
                                          ? Text(
                                              "Sedang mengetik...",
                                              style: robotoRegular.copyWith(
                                                fontSize: 10.0,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

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
                                            text:
                                                "Terima kasih telah menghubungi kami di ",
                                          ),
                                          TextSpan(
                                            text: "Marlinda",
                                            style: robotoRegular.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: ColorResources.white,
                                            ),
                                          ),
                                          const TextSpan(
                                            text:
                                                ". Apakah yang bisa kami bantu atas keluhan anda?",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ),

                      if (notifier.state == ProviderState.loading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: SizedBox()),
                        ),

                      if (notifier.state == ProviderState.loaded)
                        SliverToBoxAdapter(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              top: 20.0,
                              left: 16.0,
                              right: 16.0,
                              bottom: 20.0,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            reverse: true,
                            itemBuilder: (BuildContext context, int i) {
                              final item = notifier.messages[i];

                              return ChatBubble(
                                text: item.text,
                                time: item.sentTime,
                                isMe: item.user.isMe!,
                                isRead: item.isRead,
                              );
                            },
                            itemCount: notifier.messages.length,
                          ),
                        ),
                    ],
                  );
                },
          ),
        ),
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
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 14.0,
            ),
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
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
                Text(
                  text,
                  style: robotoRegular.copyWith(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),

                const SizedBox(height: 5.0),
              ],
            ),
          ),

          isMe
              ? Text(
                  time,
                  style: robotoRegular.copyWith(
                    color: ColorResources.black,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                )
              : Text(
                  time,
                  style: robotoRegular.copyWith(
                    color: ColorResources.black,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
        ],
      ),
    );
  }
}
