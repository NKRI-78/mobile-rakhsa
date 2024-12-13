class ChatsModel {
  int status;
  bool error;
  String message;
  List<ChatsData> data;

  ChatsModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory ChatsModel.fromJson(Map<String, dynamic> json) => ChatsModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: List<ChatsData>.from(json["data"].map((x) => ChatsData.fromJson(x))),
  );
}

class ChatsData {
  Chat chat;
  bool isConfirm;
  bool isFinish;
  bool isResolved; 
  bool isClosed;
  User user;
  String createdAt;
  int countUnread;
  bool isTyping;
  List<Message> messages;

  ChatsData({
    required this.chat,
    required this.isConfirm,
    required this.isFinish,
    required this.isResolved,
    required this.isClosed,
    required this.user,
    required this.createdAt,
    required this.countUnread,
    required this.isTyping,
    required this.messages,
  });

  factory ChatsData.fromJson(Map<String, dynamic> json) => ChatsData(
    chat: Chat.fromJson(json["chat"]),
    isConfirm: json["is_confirm"],
    isResolved: json["is_resolved"],
    isClosed: json["is_closed"],
    isFinish: json["is_finish"],
    user: User.fromJson(json["user"]),
    createdAt: json["created_at"],
    countUnread: json["count_unread"],
    isTyping: false,
    messages: List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
  );
}

class Chat {
  String id;

  Chat({
    required this.id,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json["id"],
  );
}

class Message {
  String id;
  String content;
  bool isRead;
  bool isMe;
  String type;
  String time;

  Message({
    required this.id,
    required this.content,
    required this.isRead,
    required this.isMe,
    required this.type,
    required this.time,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    content: json["content"],
    isRead: json["is_read"],
    isMe: json["is_me"],
    type: json["type"],
    time: json["time"],
  );
}

class User {
  String id;
  String avatar;
  String name;

  User({
    required this.id,
    required this.avatar,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    avatar: json["avatar"],
    name: json["name"],
  );
}