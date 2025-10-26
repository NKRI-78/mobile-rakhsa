class InboxModel {
  int status;
  bool error;
  String message;
  List<InboxData> data;

  InboxModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory InboxModel.fromJson(Map<String, dynamic> json) => InboxModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: List<InboxData>.from(json["data"].map((x) => InboxData.fromJson(x))),
  );
}

class InboxData {
  int id;
  String title;
  String description;
  String field2;
  String field3;
  String link;
  bool isRead;

  InboxData({
    required this.id,
    required this.title,
    required this.description,
    required this.field2,
    required this.field3,
    required this.link,
    required this.isRead,
  });

  factory InboxData.fromJson(Map<String, dynamic> json) => InboxData(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    field2: json["field2"],
    field3: json["field3"],
    link: json["link"],
    isRead: json["is_read"]
  );
}