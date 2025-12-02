import 'package:equatable/equatable.dart';
import 'package:rakhsa/misc/client/errors/errors.dart';

import 'chat_user.dart';

class Message extends Equatable {
  final String id;
  final bool isRead;

  // properti dari api yang endpointya /chat/list
  final String? content;
  final bool? isTyping;
  final bool? isMe;
  final String? type;
  final String? time;

  // properti dari api yang endpointya /chat/messages
  final String? chatId;
  final ChatUser? user;
  final String? createdAt;
  final String? sendTime;
  final String? text;

  const Message({
    required this.id,
    required this.isRead,
    this.content,
    this.isTyping,
    this.isMe,
    this.type,
    this.time,
    this.chatId,
    this.user,
    this.createdAt,
    this.sendTime,
    this.text,
  });

  @override
  List<Object?> get props {
    return [
      id,
      isRead,
      content,
      isTyping,
      isMe,
      type,
      time,
      chatId,
      user,
      createdAt,
      sendTime,
      text,
    ];
  }

  Message copyWith({
    String? id,
    bool? isRead,
    String? content,
    bool? isTyping,
    bool? isMe,
    String? type,
    String? time,
    String? chatId,
    ChatUser? user,
    String? createdAt,
    String? sendTime,
    String? text,
  }) {
    return Message(
      id: id ?? this.id,
      isRead: isRead ?? this.isRead,
      content: content ?? this.content,
      isTyping: isTyping ?? this.isTyping,
      isMe: isMe ?? this.isMe,
      type: type ?? this.type,
      time: time ?? this.time,
      chatId: chatId ?? this.chatId,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      sendTime: sendTime ?? this.sendTime,
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'is_read': isRead,
      'content': content,
      'is_typing': isTyping,
      'is_me': isMe,
      'type': type,
      'time': time,
      'chat_id': chatId,
      'user': user?.toJson(),
      'created_at': createdAt,
      'send_time': sendTime,
      'text': text,
    };
  }

  factory Message.fromJson(Map<String, dynamic> map) {
    try {
      return Message(
        id: map['id'] as String,
        isRead: map['isRead'] as bool,

        // properti dari api yang endpointya /chat/list
        content: map['content'],
        isTyping: map['is_typing'],
        isMe: map['is_me'],
        type: map['type'],
        time: map['time'],

        // properti dari api yang endpointya /chat/messages
        chatId: map['chat_id'],
        user: map['user'] != null ? ChatUser.fromJson(map['user']) : null,
        createdAt: map['created_at'],
        sendTime: map['send_time'],
        text: map['text'],
      );
    } catch (e) {
      throw DataParsingException(error: e);
    }
  }
}
