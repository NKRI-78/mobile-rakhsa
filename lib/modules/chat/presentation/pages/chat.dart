import 'dart:async';

import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/widgets/avatar.dart';
import 'package:uuid/uuid.dart' as uuid;

import 'package:intl/intl.dart';
import 'package:rakhsa/socketio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/expire_sos_notifier.dart';

import 'package:rakhsa/widgets/components/button/custom.dart';
import 'package:rakhsa/widgets/components/modal/modal.dart';

import 'chat_bubble.dart';

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

class ChatPageState extends State<ChatPage> {
  Timer? debounce;

  final sC = ScrollController();

  late TextEditingController messageC;

  late GetMessagesNotifier messageNotifier;
  late SocketIoService socketIoService;

  @override
  void initState() {
    super.initState();

    messageNotifier = context.read<GetMessagesNotifier>();
    socketIoService = context.read<SocketIoService>();

    socketIoService.subscribeChat(widget.chatId);

    messageNotifier.startTimer();

    messageC = TextEditingController();
    messageC.addListener(handleTyping);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      messageNotifier.initShowAutoGreetings(widget.autoGreetings);
    });

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    socketIoService.unsubscribeChat(widget.chatId);

    sC.dispose();

    messageC.removeListener(handleTyping);
    messageC.dispose();

    debounce?.cancel();

    super.dispose();
  }

  Future<void> getData() async {
    if (!mounted) return;
    messageNotifier.getMessages(chatId: widget.chatId, status: widget.status);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (sC.hasClients) {
        sC.animateTo(
          sC.position.minScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    if (messageC.text.trim().isEmpty) return;

    final session = await StorageHelper.getUserSession();
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

    messageC.clear();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (sC.hasClients) {
        sC.animateTo(
          sC.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            backgroundColor: primaryColor,
            leading: CupertinoNavigationBarBackButton(
              color: whiteColor,
              onPressed: () {
                messageNotifier.clearActiveChatId();
                Navigator.pop(context, "refetch");
              },
            ),
            title: Consumer<GetMessagesNotifier>(
              builder: (context, notifier, child) {
                final username = notifier.recipient.name ?? "-";
                final agentIsTyping = notifier.isTyping(widget.chatId);
                return Row(
                  spacing: 10,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Avatar(src: notifier.recipient.avatar, initial: username),
                    Column(
                      spacing: 3,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: robotoRegular.copyWith(
                            fontSize: 16.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                  ],
                );
              },
            ),
          ),
        ),
        body: Consumer<GetMessagesNotifier>(
          builder: (context, notifier, child) {
            final closedSession =
                widget.status == "CLOSED" || notifier.note.isNotEmpty;
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: notifier.showAutoGreetings
                        ? _buildAutoGreetings()
                        : ListView.builder(
                            controller: sC,
                            reverse: true,
                            itemCount: notifier.messages.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final item = notifier.messages[index];

                              return ChatBubble(
                                text: item.text,
                                time: item.sentTime,
                                isMe: item.user.isMe!,
                                isRead: item.isRead,
                              );
                            },
                          ),
                  ),

                  // send message
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Color(0xFFEAEAEA)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (closedSession) ...[
                          Text(
                            "Sesi Chat Berakhir",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          16.spaceY,
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: whiteColor,
                                padding: EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    12,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                context.pushNamedAndRemoveUntil(
                                  RoutesNavigation.dashboard,
                                  (route) => false,
                                );
                              },
                              child: Text("Kembali ke Beranda"),
                            ),
                          ),
                        ] else ...[
                          if (notifier.isBtnSessionEnd)
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: CustomButton(
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
                              ),
                            ),
                          Row(
                            spacing: 14,
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
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAutoGreetings() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: ColorResources.white,
              ),
              children: [
                const TextSpan(text: "Terima kasih telah menghubungi kami di "),
                TextSpan(
                  text: "Marlinda",
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
    );
  }
}
