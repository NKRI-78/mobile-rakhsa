// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class MessageModel {
  int status;
  bool error;
  String message;
  MessageParentData data;

  MessageModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: MessageParentData.fromJson(json["data"]),
  );
}

class MessageParentData {
  String chatId;
  RecipientUser recipient;
  String note;
  List<MessageData> messages;

  MessageParentData({
    required this.chatId,
    required this.recipient,
    required this.note,
    required this.messages,
  });

  factory MessageParentData.fromJson(Map<String, dynamic> json) =>
      MessageParentData(
        chatId: json["chat_id"],
        recipient: RecipientUser.fromJson(json["recipient"]),
        note: json["note"],
        messages: List<MessageData>.from(
          json["messages"].map((x) => MessageData.fromJson(x)),
        ),
      );
}

class MessageData {
  String id;
  String chatId;
  MessageUser user;
  bool isRead;
  String sentTime;
  String text;
  DateTime createdAt;

  MessageData({
    required this.id,
    required this.chatId,
    required this.user,
    required this.isRead,
    required this.sentTime,
    required this.text,
    required this.createdAt,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) => MessageData(
    id: json["id"],
    chatId: json["chat_id"],
    user: MessageUser.fromJson(json["user"]),
    isRead: json["is_read"],
    sentTime: json["sent_time"],
    text: json["text"],
    createdAt: DateTime.parse(json["created_at"]),
  );
}

class RecipientUser extends Equatable {
  final String? id;
  final String? avatar;
  final String? name;
  final bool? isMe;
  final bool? isOnline;
  final DateTime? lastActive;

  const RecipientUser({
    this.id,
    this.avatar,
    this.name,
    this.isMe,
    this.isOnline,
    this.lastActive,
  });

  factory RecipientUser.fromJson(Map<String, dynamic> json) => RecipientUser(
    id: json["id"],
    avatar: json["avatar"],
    name: json["name"],
    isMe: json["is_me"],
    isOnline: json["is_online"],
    lastActive: DateTime.parse(json["last_active"]),
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'avatar': avatar,
      'name': name,
      'is_me': isMe,
      'is_online': isOnline,
      'last_active': lastActive?.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props {
    return [id, avatar, name, isMe, isOnline, lastActive];
  }

  RecipientUser copyWith({
    String? id,
    String? avatar,
    String? name,
    bool? isMe,
    bool? isOnline,
    DateTime? lastActive,
  }) {
    return RecipientUser(
      id: id ?? this.id,
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      isMe: isMe ?? this.isMe,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

class MessageUser {
  String? id;
  String? avatar;
  String? name;
  bool? isMe;

  MessageUser({this.id, this.avatar, this.name, this.isMe});

  factory MessageUser.fromJson(Map<String, dynamic> json) => MessageUser(
    id: json["id"],
    avatar: json["avatar"],
    name: json["name"],
    isMe: json["is_me"],
  );
}
