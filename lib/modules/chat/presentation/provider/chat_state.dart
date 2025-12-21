// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'package:rakhsa/core/enums/request_state.dart';
import 'package:rakhsa/repositories/chat/model/chat.dart';

class ChatState extends Equatable {
  final GetChatInboxState getChatInbox;
  final GetChatMessagesState getChatMessages;

  const ChatState({
    this.getChatInbox = const GetChatInboxState(),
    this.getChatMessages = const GetChatMessagesState(),
  });

  @override
  List<Object?> get props => [getChatInbox, getChatMessages];

  ChatState copyWith({
    GetChatInboxState? getChatInbox,
    GetChatMessagesState? getChatMessages,
  }) {
    return ChatState(
      getChatInbox: getChatInbox ?? this.getChatInbox,
      getChatMessages: getChatMessages ?? this.getChatMessages,
    );
  }
}

class GetChatInboxState extends Equatable {
  final Chat? chatInbox;

  final RequestState state;
  final String? errorMessage;

  const GetChatInboxState({
    this.chatInbox,
    this.state = RequestState.idle,
    this.errorMessage,
  });

  bool get isLoading => state == RequestState.loading;
  bool get isError => state == RequestState.error;
  bool get isSuccess => state == RequestState.success;

  @override
  List<Object?> get props => [chatInbox, state, errorMessage];

  GetChatInboxState copyWith({
    Chat? chatInbox,
    RequestState? state,
    String? errorMessage,
  }) {
    return GetChatInboxState(
      chatInbox: chatInbox ?? this.chatInbox,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class GetChatMessagesState extends Equatable {
  final List<Message> messages;

  final RequestState state;
  final String? errorMessage;

  const GetChatMessagesState({
    this.messages = const <Message>[],
    this.state = RequestState.idle,
    this.errorMessage,
  });

  bool get isLoading => state == RequestState.loading;
  bool get isError => state == RequestState.error;
  bool get isSuccess => state == RequestState.success;

  @override
  List<Object?> get props => [messages, state, errorMessage];

  GetChatMessagesState copyWith({
    List<Message>? messages,
    RequestState? state,
    String? errorMessage,
  }) {
    return GetChatMessagesState(
      messages: messages ?? this.messages,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
