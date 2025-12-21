import 'package:equatable/equatable.dart';
import 'package:rakhsa/core/client/errors/errors.dart';

import 'chat_id.dart';
import 'chat_user.dart';
import 'message.dart';

export 'chat_id.dart';
export 'chat_user.dart';
export 'message.dart';

class Chat extends Equatable {
  final String id;
  final String sosId;
  final String status;
  final String note;
  final List<Message> messages;

  // kalau endpointya /chat/list, propertinya object "chat"
  // kalau endpointya /chat/messages, propertinya string "chat_id"
  final ChatId? chatId;

  // properti dari api yang endpointya /chat/list
  final String? createdAt;
  final ChatUser? user;
  final int? unreadCount;

  // properti dari api yang endpointya /chat/messages
  final ChatUser? recipient;
  final String? handleBy;

  const Chat({
    required this.id,
    required this.sosId,
    required this.status,
    required this.note,
    required this.messages,
    this.chatId,
    this.createdAt,
    this.user,
    this.unreadCount,
    this.recipient,
    this.handleBy,
  });

  @override
  List<Object?> get props {
    return [
      id,
      sosId,
      status,
      note,
      messages,
      chatId,
      createdAt,
      user,
      unreadCount,
      recipient,
      handleBy,
    ];
  }

  Chat copyWith({
    String? id,
    String? sosId,
    String? status,
    String? note,
    List<Message>? messages,
    ChatId? chatId,
    String? createdAt,
    ChatUser? user,
    int? unreadCount,
    ChatUser? recipient,
    String? handleBy,
  }) {
    return Chat(
      id: id ?? this.id,
      sosId: sosId ?? this.sosId,
      status: status ?? this.status,
      note: note ?? this.note,
      messages: messages ?? this.messages,
      chatId: chatId ?? this.chatId,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      unreadCount: unreadCount ?? this.unreadCount,
      recipient: recipient ?? this.recipient,
      handleBy: handleBy ?? this.handleBy,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sos_id': sosId,
      'status': status,
      'note': note,
      'messages': messages.map((m) => m.toJson()).toList(),
      'chat_id': chatId?.toJson(),
      'created_at': createdAt,
      'user': user?.toJson(),
      'count_unread': unreadCount,
      'recipient': recipient?.toJson(),
      'handleby': handleBy,
    };
  }

  factory Chat.fromJson(Map<String, dynamic> map) {
    try {
      return Chat(
        id: map['id'] as String,
        sosId: map['sosId'] as String,
        status: map['status'] as String,
        note: map['note'] as String,
        messages: (map['messages'] as List<dynamic>)
            .map((data) => Message.fromJson(data))
            .toList(),

        // kalau endpointya /chat/list, propertinya object "chat"
        // kalau endpointya /chat/messages, propertinya string "chat_id"
        chatId: map['chat'] != null
            ? ChatId.fromJson(map['chat'])
            : map['chat_id'] != null
            ? ChatId.fromSingleValue(map['chat_id'])
            : null,

        // properti dari api yang endpointya /chat/list
        createdAt: map['createdAt'],
        user: map['user'] != null ? ChatUser.fromJson(map['user']) : null,
        unreadCount: map['count_unread'],

        // properti dari api yang endpointya /chat/messages
        handleBy: map['handleby'],
        recipient: map['recipient'] != null
            ? ChatUser.fromJson(map['recipient'])
            : null,
      );
    } catch (e) {
      throw DataParsingException(error: e);
    }
  }
}
