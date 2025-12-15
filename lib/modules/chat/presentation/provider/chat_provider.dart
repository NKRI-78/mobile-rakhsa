import 'package:flutter/material.dart';
import 'package:rakhsa/misc/client/errors/exceptions/exceptions.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/repositories/chat/chat_repository.dart';
import 'package:rakhsa/service/notification/notification_manager.dart';

import 'chat_state.dart';
export 'chat_state.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;

  ChatProvider(this._repository);

  var _state = ChatState();
  ChatState get state => _state;

  GetChatInboxState get _chatInbox => _state.getChatInbox;
  GetChatMessagesState get _chatMessages => _state.getChatMessages;

  void _setState(ChatState newState, {bool shouldNotify = true}) {
    _state = newState;
    if (shouldNotify) notifyListeners();
  }

  Future<void> getChatInbox() async {
    _setState(
      _state.copyWith(
        getChatInbox: _chatInbox.copyWith(state: RequestState.loading),
      ),
    );

    try {
      final remoteChatInbox = await _repository.getChatInbox();

      _setState(
        _state.copyWith(
          getChatInbox: _chatInbox.copyWith(
            chatInbox: remoteChatInbox,
            state: RequestState.success,
          ),
        ),
      );
    } on NetworkException catch (e) {
      _setState(
        _state.copyWith(
          getChatInbox: _chatInbox.copyWith(
            errorMessage: e.message,
            state: RequestState.error,
          ),
        ),
      );
    }
  }

  Future<void> getMessages({
    required String chatId,
    required String status,
  }) async {
    _setState(
      _state.copyWith(
        getChatMessages: _chatMessages.copyWith(state: RequestState.loading),
      ),
    );

    try {
      final remoteMessages = await _repository.getMessages(chatId, status);

      _setState(
        _state.copyWith(
          getChatMessages: _chatMessages.copyWith(
            messages: remoteMessages,
            state: RequestState.success,
          ),
        ),
      );
    } on NetworkException catch (e) {
      _setState(
        _state.copyWith(
          getChatMessages: _chatMessages.copyWith(
            errorMessage: e.message,
            state: RequestState.error,
          ),
        ),
      );
    }
  }

  Future<void> insertMessage(dynamic data) async {
    if (data == null) return;
    if (data is! Map<String, dynamic>) return;

    final String incomingMessageId = data['id'] ?? "";
    final bool closedByAgent = data['closed_by_agent'] ?? false;

    final currentMessages = _chatMessages.messages;

    // if contain same id
    if (currentMessages.any(
      (m) => m.id == "closed_by_agent" || m.id == incomingMessageId,
    )) {
      return;
    }

    if (closedByAgent) {
      final newMessage = Message(
        id: "closed_by_agent",
        isRead: true,
        // chatId: activeChatId,
        user: ChatUser(name: "Command Center"),
        sendTime: DateTime.now().format("HH.mm"),
        text: data['note'] ?? "-",
        createdAt: DateTime.now().toIso8601String(),
      );

      _setState(
        _state.copyWith(
          getChatMessages: _chatMessages.copyWith(
            messages: [...currentMessages, newMessage],
          ),
        ),
      );

      await NotificationManager().dismissChatsNotification();
    } else {
      final newMessage = Message(
        id: incomingMessageId,
        isRead: data['is_read'] ?? false,
        chatId: data['chat_id'],
        user: ChatUser(
          id: data['user']['id'],
          isMe: data['user']['is_me'],
          avatar: data['user']['avatar'],
          name: data['user']['name'],
        ),
        sendTime: data['sent_time'],
        text: data['text'],
        createdAt: DateTime.now().toIso8601String(),
      );

      _setState(
        _state.copyWith(
          getChatMessages: _chatMessages.copyWith(
            messages: [newMessage, ...currentMessages],
          ),
        ),
      );
    }
  }
}
