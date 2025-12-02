import 'package:flutter/material.dart';
import 'package:rakhsa/misc/client/errors/exceptions/exceptions.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/repositories/chat/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;

  ChatProvider(this._repository);

  // state

  var _getChatInboxState = RequestState.idle;
  bool isGetChatInbox(List<RequestState> compareStates) =>
      compareStates.contains(_getChatInboxState);

  var _getMessagesState = RequestState.idle;
  bool isGetMessages(List<RequestState> compareStates) =>
      compareStates.contains(_getMessagesState);

  // data

  Chat? _chatInbox;
  Chat? get chatInbox => _chatInbox;

  var _messages = <Message>[];
  List<Message> get messages => _messages;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // function

  Future<void> getChatInbox() async {
    _getChatInboxState = RequestState.loading;
    notifyListeners();

    try {
      final remoteChatInbox = await _repository.getChatInbox();

      _chatInbox = remoteChatInbox;
      _getChatInboxState = RequestState.success;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _getChatInboxState = RequestState.error;
      notifyListeners();
    }
  }

  Future<void> getmessages({
    required String chatId,
    required String status,
  }) async {
    _getMessagesState = RequestState.loading;
    notifyListeners();

    try {
      final remoteMessages = await _repository.getMessages(chatId, status);

      _messages = remoteMessages;
      _getMessagesState = RequestState.success;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _getMessagesState = RequestState.error;
      notifyListeners();
    }
  }
}
