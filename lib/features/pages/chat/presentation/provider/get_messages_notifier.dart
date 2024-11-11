import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/pages/chat/data/models/messages.dart';
import 'package:rakhsa/features/pages/chat/domain/usecases/get_messages.dart';

class GetMessagesNotifier with ChangeNotifier {
  final GetMessagesUseCase getMessagesUseCase;

  GetMessagesNotifier({
    required this.getMessagesUseCase
  });  

  ScrollController sC = ScrollController();

  RecipientUser _recipient = RecipientUser();
  RecipientUser get recipient => _recipient;

  List<MessageData> _messages = [];
  List<MessageData> get messages => [..._messages];

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  Map<String, bool> onlineStatus = {};
  Map<String, String?> typingStatus = {};

  void updateUserStatus({required Map<String, dynamic> data}) {
    onlineStatus[data["recipient"]] = data["type"] == "online" ? true : false;
  
    notifyListeners();
  }

  bool isOnline(String userId) {
    return onlineStatus[userId] ?? false;
  }

  void updateUserTyping({required Map<String, dynamic> data}) {
    if (data["is_typing"]) {
      typingStatus[data["chat_id"]] = data["sender"];
    } else {
      typingStatus.remove(data["chat_id"]);
    }
    
    notifyListeners();
  }

  bool isTyping(String chatId) {
    return typingStatus.containsKey(chatId);
  }

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  Future<void> getMessages({required String chatId}) async {
    final result = await getMessagesUseCase.execute(chatId: chatId);
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (sC.hasClients) {
        sC.animateTo(
          sC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut, 
        );
      }
    });

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {

      _recipient = r.data.recipient;

      _messages = [];
      _messages.addAll(r.data.messages);

      setStateProvider(ProviderState.loaded);
    });
  }

  void appendMessage({required Map<String, dynamic> data}) {
    // bool isMe = data["data"]["user"]["is_me"];
    bool isRead = data["data"]["is_read"];

    _messages.insert(0, MessageData(
      id: data["data"]["id"],
      chatId: data["data"]["chat_id"],
      user: MessageUser(
        id: data["data"]["user"]["id"],
        isMe: data["data"]["user"]["is_me"],
        avatar: data["data"]["user"]["avatar"],
        name: data["data"]["user"]["name"]
      ), 
      isRead: isRead, 
      sentTime: data["data"]["sent_time"], 
      text: data["data"]["text"], 
      createdAt: DateTime.now()
    ));

    // if(isMe == false) {

    //   if(!isRead) {
    //     AwesomeNotifications().createNotification(
    //       content: NotificationContent(
    //         id: Random().nextInt(100),
    //         channelKey: 'notification',
    //         title: data["data"]["user"]["name"],
    //         body:  data["data"]["text"],
    //         largeIcon: data["data"]["user"]["avatar"],
    //         payload: {
    //           "type": "message",
    //           "chat_id": data["data"]["chat_id"],
    //           "sender": data["data"]["user"]["id"],
    //           "recipient": data["data"]["sender"]["id"],
    //         }
    //       ),
    //       actionButtons: [
    //         NotificationActionButton(
    //           key: 'REPLY',
    //           label: 'Reply',
    //           requireInputText: true,
    //           actionType: ActionType.SilentAction,
    //         ),
    //         NotificationActionButton(
    //           key: 'DISMISS',
    //           label: 'Dismiss',
    //           actionType: ActionType.DismissAction,
    //           isDangerousOption: true
    //         )
    //       ]
    //     );
    //   }

    // }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (sC.hasClients) {
        sC.animateTo(
          sC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut, 
        );
      }
    });

    notifyListeners();
  } 

  void ackRead({required Map<String, dynamic> data}) {
    bool recipientView = data["recipient_view"];

    if(!recipientView) {
      for (MessageData message in messages) {
        message.isRead = true;
      }
    }

    notifyListeners();
  }


}