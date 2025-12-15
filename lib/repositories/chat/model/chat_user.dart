import 'package:equatable/equatable.dart';
import 'package:rakhsa/misc/client/errors/errors.dart';

class ChatUser extends Equatable {
  final String? id;
  final String? avatar;
  final String? name;

  // properti dari api yang endpointya /chat/messages
  // untuk object "recipient"
  final bool? isTyping;
  final bool? isOnline;
  final String? lastActive;

  // properti dari api yang endpointya /chat/messages
  // untuk object ['message']['user']
  final bool? isMe;

  const ChatUser({
    this.id,
    this.avatar,
    this.name,
    this.isTyping,
    this.isMe,
    this.isOnline,
    this.lastActive,
  });

  @override
  List<Object?> get props => [
    id,
    avatar,
    name,
    isTyping,
    isOnline,
    isMe,
    lastActive,
  ];

  ChatUser copyWith({
    String? id,
    String? avatar,
    String? name,
    bool? isTyping,
    bool? isMe,
    bool? isOnline,
    String? lastActive,
  }) {
    return ChatUser(
      id: id ?? this.id,
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      isTyping: isTyping ?? this.isTyping,
      isMe: isMe ?? this.isMe,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'avatar': avatar,
      'name': name,
      'is_typing': isTyping,
      'last_active': lastActive,
      'is_online': isOnline,
      'is_me': isMe,
    };
  }

  factory ChatUser.fromJson(Map<String, dynamic> map) {
    try {
      return ChatUser(
        id: map['id'] as String,
        avatar: map['avatar'] as String,
        name: map['name'] as String,

        // properti dari api yang endpointya /chat/messages
        // untuk object "recipient"
        isTyping: map['is_typing'],
        isOnline: map['is_online'],
        lastActive: map['last_active'],

        // properti dari api yang endpointya /chat/messages
        // untuk object ['message']['user']
        isMe: map['is_me'],
      );
    } catch (e) {
      throw DataParsingException(error: e);
    }
  }
}
