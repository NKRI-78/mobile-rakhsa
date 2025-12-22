import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rakhsa/core/enums/provider_state.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/modules/chat/presentation/pages/chat_room_page.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/router/router.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/core/debug/logger.dart';
import 'package:rakhsa/service/notification/notification_manager.dart';

import 'package:rakhsa/modules/chat/data/models/messages.dart';
import 'package:rakhsa/modules/chat/domain/usecases/get_messages.dart';

class GetMessagesNotifier with ChangeNotifier {
  final GetMessagesUseCase useCase;

  GetMessagesNotifier({required this.useCase});

  final sessionCacheKey = "end_session";
  final endSessionDuration = Duration(minutes: 5);

  var _recipients = <RecipientUser>[];
  List<RecipientUser> get recipients => _recipients;

  String _activeChatId = "";
  String get activeChatId => _activeChatId;

  String _note = "";
  String get note => _note;

  bool _isBtnSessionEnd = false;
  bool get isBtnSessionEnd => _isBtnSessionEnd;

  bool _showAutoGreetings = false;
  bool get showAutoGreetings => _showAutoGreetings;

  List<MessageData> _messages = [];
  List<MessageData> get messages => [..._messages];

  ProviderState _state = .loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  Map<String, bool> onlineStatus = {};
  Map<String, bool> typingStatus = {};

  void initTimeSession() async {
    await StorageHelper.write(sessionCacheKey, DateTime.now().toString());
  }

  bool hasCacheTimeSession() {
    return StorageHelper.containsKey(sessionCacheKey);
  }

  void initTimeSessionWhenIsNull() async {
    if (StorageHelper.containsKey(sessionCacheKey)) return;
    await StorageHelper.write(sessionCacheKey, DateTime.now().toString());
  }

  Duration getChatSessionRemainingDuration() {
    final cSession = StorageHelper.read(sessionCacheKey);
    if (cSession == null) return .zero;

    try {
      final savedTime = DateTime.parse(cSession);
      final elapsed = DateTime.now().difference(savedTime);
      final remaining = endSessionDuration - elapsed;

      if (remaining.isNegative) return .zero;

      return remaining;
    } catch (e) {
      return .zero;
    }
  }

  void checkTimeSession() {
    final cSession = StorageHelper.read(sessionCacheKey);
    if (cSession != null) {
      final savedSession = DateTime.parse(cSession);
      final diffInMinutes = DateTime.now().difference(savedSession).inMinutes;

      // dibaca cuy 🙏😋
      // jika selisih waktu sudah/lebih dari 5 menit maka _isBtnSessionEnd = true
      if (diffInMinutes >= endSessionDuration.inMinutes) {
        _isBtnSessionEnd = true;
        notifyListeners();
      } else {
        _isBtnSessionEnd = false;
        notifyListeners();
      }
    } else {
      _isBtnSessionEnd = false;
      notifyListeners();
    }
  }

  void removeAthanFromRecipients() {
    _recipients.removeWhere(
      (r) => r.name == "Athan" || r.name == "Marlinda Singapore",
    );
  }

  void addRecipients(RecipientUser newR, {bool shouldNotify = true}) {
    if (_recipients.any((r) => r.id == newR.id)) return;
    if (newR.id == StorageHelper.session?.user.id) return;
    _recipients = [..._recipients, newR];
    if (shouldNotify) notifyListeners();
  }

  void setStateNote({required String val}) {
    _note = val;

    notifyListeners();
  }

  bool isTyping(String chatId) {
    return typingStatus[chatId] ?? false;
  }

  void updateUserTyping({required Map<String, dynamic> data}) {
    String chatId = data["chat_id"];
    bool isTyping = data["is_typing"];

    if (isTyping) {
      typingStatus[chatId] = true;
    } else {
      typingStatus.remove(chatId);
    }

    notifyListeners();
  }

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  void initShowAutoGreetings(bool show) {
    _showAutoGreetings = show;
    notifyListeners();
  }

  Future<void> getMessages({
    required String chatId,
    required String status,
  }) async {
    setStateProvider(.loading);

    final result = await useCase.execute(chatId: chatId, status: status);

    result.fold(
      (l) {
        _message = l.message;
        setStateProvider(.error);
      },
      (r) {
        _note = r.data.note;

        _activeChatId = r.data.chatId;

        _state = .loaded;

        _messages = [];

        _messages.addAll(r.data.messages);

        addRecipients(r.data.recipient, shouldNotify: false);

        notifyListeners();

        log(
          'semua chat dari getMessageNotifier.getMessages = ${_messages.map((e) => {"time": e.sentTime, "message": e.text}).toList()}',
          label: "GET_MESSAGE_NOTIFIER",
        );
      },
    );
  }

  void navigateToChat({
    required String chatId,
    required String status,
    required String recipientId,
    required String sosId,
    bool newSession = false,
  }) {
    ChatRoomRoute(
      ChatRoomParams(
        chatId: chatId,
        recipientId: recipientId,
        status: status,
        sosId: sosId,
        autoGreetings: true,
        newSession: newSession,
      ),
    ).go(navigatorKey.currentContext!);
  }

  void appendMessage({required Map<String, dynamic> data}) async {
    _showAutoGreetings = false;
    notifyListeners();

    // flag closed by agent untuk create data dummy catatan penutup chat jadi bubble chat
    // diakhir sesi chat sos
    bool closedByAgent = data['closed_by_agent'] ?? false;

    if (closedByAgent) {
      if (_messages.any((m) => m.id == "closed_by_agent")) return;

      _messages.insert(
        0,
        MessageData(
          id: "closed_by_agent",
          chatId: activeChatId,
          user: MessageUser(
            id: null,
            isMe: false,
            avatar: null,
            name: "Command Center",
          ),
          isRead: true,
          sentTime: DateTime.now().format("HH.mm"),
          text: _note,
          createdAt: DateTime.now(),
        ),
      );

      await NotificationManager().dismissChatsNotification();
    } else {
      String incomingChatId = data["chat_id"];
      String incomingMessageId = data["id"];
      bool isRead = data["is_read"];

      log(
        "messageData dari appendMessage = ${{
          "msg_id": incomingMessageId,
          "chat_id": incomingChatId,
          "is_read": isRead,
          "user": {"id": data['user']['id'], "isMe": data['user']['is_me'], "avatar": data["user"]["avatar"], "name": data["user"]["name"]},
          "sentTime": data["sent_time"],
          "text": data["text"],
        }}",
        label: "GET_MESSAGE_NOTIFIER",
      );

      final containIncomingMsgId = _messages.any(
        (msg) => msg.id == incomingMessageId,
      );
      log(
        "apakah _messages memuat id yang sama dengan incomingMessageId? $containIncomingMsgId",
        label: "GET_MESSAGE_NOTIFIER",
      );
      if (containIncomingMsgId) return;

      addRecipients(
        RecipientUser(
          id: data["user"]["id"],
          avatar: data["user"]["avatar"],
          name: data["user"]["name"],
        ),
      );

      log("incomingRecipients $_recipients", label: "GET_MESSAGE_NOTIFIER");

      _messages.insert(
        0,
        MessageData(
          id: incomingMessageId,
          chatId: incomingChatId,
          user: MessageUser(
            id: data["user"]["id"],
            isMe: data["user"]["is_me"],
            avatar: data["user"]["avatar"],
            name: data["user"]["name"],
          ),
          isRead: isRead,
          sentTime: data["sent_time"],
          text: data["text"],
          createdAt: DateTime.now(),
        ),
      );
      notifyListeners();
      log(
        "_messages dari appendMessage setelah di notifyListeners() = ${_messages.map((e) => {"time": e.sentTime, "message": e.text}).toList()}",
        label: "GET_MESSAGE_NOTIFIER",
      );
    }
  }
}
