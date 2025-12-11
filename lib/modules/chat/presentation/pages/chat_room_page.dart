import 'dart:async';
import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/modules/chat/presentation/widget/chat_app_bar.dart';
import 'package:rakhsa/modules/chat/presentation/widget/chat_bubble.dart';
import 'package:rakhsa/service/sos/end_sos_dialog.dart';
import 'package:rakhsa/widgets/lottie/lottie_animation.dart';
import 'package:uuid/uuid.dart' as uuid;

import 'package:rakhsa/service/socket/socketio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/widgets/components/button/custom.dart';

class ChatRoomParams {
  final String sosId;
  final String chatId;
  final String status;
  final String recipientId;
  final bool autoGreetings;
  final bool newSession;

  ChatRoomParams({
    required this.sosId,
    required this.chatId,
    required this.status,
    required this.recipientId,
    required this.autoGreetings,
    this.newSession = false,
  });
}

class ChatRoomPage extends StatefulWidget {
  final ChatRoomParams param;

  const ChatRoomPage(this.param, {super.key});

  @override
  State<ChatRoomPage> createState() => ChatRoomPageState();
}

class ChatRoomPageState extends State<ChatRoomPage> {
  Timer? debounce;

  final sC = ScrollController();

  late TextEditingController messageC;

  late GetMessagesNotifier messageNotifier;
  late SocketIoService socketIoService;

  Timer? _chatSessionTimer;
  late int _chatTickerValue = 0;
  bool get showEndChatSugesstion => _chatTickerValue == 0;

  @override
  void initState() {
    super.initState();

    messageNotifier = context.read<GetMessagesNotifier>();
    socketIoService = context.read<SocketIoService>();

    socketIoService.subscribeChat(widget.param.chatId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.param.newSession) {
        messageNotifier.initTimeSession();
      }

      // dibaca cuy 😘😘
      // ini handle kalau time session ga kesimpen didalam shared prefs
      // momenya ketika sesi chat masih ada tapi app sudah diunistall itu bikin bug button end session ga bakal muncul
      // time session ga ada didalam shared prefs terus juga ga ke init karena bukan kondisi widget.param.newSession
      messageNotifier.initTimeSessionWhenIsNull();

      if (messageNotifier.hasCacheTimeSession()) {
        _initTimerChatSession();
      }

      messageNotifier.initShowAutoGreetings(widget.param.autoGreetings);
      messageNotifier.checkTimeSession();
    });

    messageC = TextEditingController();
    messageC.addListener(handleTyping);

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    socketIoService.unsubscribeChat(widget.param.chatId);

    sC.dispose();

    _disposeTimerChatSession();

    messageC.removeListener(handleTyping);
    messageC.dispose();

    debounce?.cancel();

    super.dispose();
  }

  Future<void> getData() async {
    await messageNotifier.getMessages(
      chatId: widget.param.chatId,
      status: widget.param.status,
    );

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

  void _initTimerChatSession() {
    _chatTickerValue = messageNotifier
        .getChatSessionRemainingDuration()
        .inSeconds;

    _chatSessionTimer?.cancel();
    _chatSessionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_chatTickerValue > 0) {
        if (mounted) {
          setState(() => _chatTickerValue--);
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _disposeTimerChatSession() {
    _chatSessionTimer?.cancel();
    _chatSessionTimer = null;
  }

  Future<void> sendMessage() async {
    if (messageC.text.trim().isEmpty) {
      messageC.clear();
      return;
    }

    final createdAt = DateTime.now().format("yyyy-MM-dd HH:mm:ss");

    final msg = messageC.text.trimLeft().trimRight();

    socketIoService.sendMessage(
      chatId: widget.param.chatId,
      recipientId: widget.param.recipientId,
      message: msg,
      createdAt: createdAt,
    );

    String sentTime =
        "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";

    Map<String, dynamic> message = {
      "id": const uuid.Uuid().v4(),
      "chat_id": widget.param.chatId,
      "user": {
        "id": StorageHelper.session?.user.id,
        "is_me": true,
        "avatar": "-",
        "name": "-",
      },
      "is_read": false,
      "sent_time": sentTime,
      "created_at": createdAt,
      "text": msg,
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
        chatId: widget.param.chatId,
        recipientId: widget.param.recipientId,
        isTyping: true,
      );

      if (debounce != null) debounce!.cancel();

      debounce = Timer(const Duration(seconds: 1), () {
        socketIoService.typing(
          chatId: widget.param.chatId,
          recipientId: widget.param.recipientId,
          isTyping: false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.unfocus(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            messageNotifier.removeAthanFromRecipients();
            context.pop("refetch");
          }
        },
        child: Scaffold(
          appBar: ChatAppBar(widget.param.chatId),
          body: Consumer<GetMessagesNotifier>(
            builder: (context, notifier, child) {
              final closedSession =
                  widget.param.status == "CLOSED" || notifier.note.isNotEmpty;
              return SafeArea(
                bottom: Platform.isAndroid,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child:
                          notifier.showAutoGreetings ||
                              notifier.messages.isEmpty
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
                                  isSingleAdmin:
                                      notifier.recipients.length == 1,
                                  username: item.user.name ?? "-",
                                );
                              },
                            ),
                    ),

                    // send message
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        Platform.isIOS ? (context.bottom + 8) : 16,
                      ),
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
                                  messageNotifier.removeAthanFromRecipients();
                                  DashboardRoute().go(context);
                                },
                                child: Text("Kembali ke Beranda"),
                              ),
                            ),
                          ] else ...[
                            if (notifier.isBtnSessionEnd ||
                                showEndChatSugesstion)
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: CustomButton(
                                  onTap: () async {
                                    await EndSosDialog.launch(
                                      sosId: widget.param.sosId,
                                      chatId: "-",
                                      recipientId: "-",
                                    );
                                  },
                                  btnColor: const Color(0xFFC82927),
                                  isLoading: false,
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
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      textSelectionTheme:
                                          TextSelectionThemeData(
                                            cursorColor: primaryColor,
                                            selectionColor: primaryColor
                                                .withValues(alpha: 0.1),
                                            selectionHandleColor: primaryColor,
                                          ),
                                    ),
                                    child: TextField(
                                      controller: messageC,
                                      style: robotoRegular.copyWith(
                                        fontSize: 12.0,
                                      ),
                                      maxLines: 4,
                                      minLines: 1,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor: ColorResources.white,
                                        hintText:
                                            "ketik pesan singkat dan jelas",
                                        hintStyle: robotoRegular.copyWith(
                                          fontSize: 12.0,
                                          color: Colors.grey,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            30.0,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            30.0,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            30.0,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
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
      ),
    );
  }

  Widget _buildAutoGreetings() {
    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        Container(
          width: double.infinity,
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

        170.spaceY,

        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: 0.7,
              child: LottieAnimation(
                "assets/animations/chats.lottie",
                width: 170,
                height: 170,
              ),
            ),
            Text(
              "Sesi sedang aktif. Ketik pesan pertama Anda agar kami dapat membantu.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }
}
