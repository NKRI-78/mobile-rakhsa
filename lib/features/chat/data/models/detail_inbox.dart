class InboxDetailModel {
  int status;
  bool error;
  String message;
  InboxDetailData data;

  InboxDetailModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory InboxDetailModel.fromJson(Map<String, dynamic> json) => InboxDetailModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: InboxDetailData.fromJson(json["data"]),
  );
}

class InboxDetailData {
  int? id;
  String? title;
  String? description;
  String? field2;
  String? field3;
  String? field4;
  String? link;
  bool? isRead;

  InboxDetailData({
    this.id,
    this.title,
    this.description,
    this.field2,
    this.field3,
    this.field4,
    this.link,
    this.isRead,
  });

  factory InboxDetailData.fromJson(Map<String, dynamic> json) => InboxDetailData(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    field2: json["field2"],
    field3: json["field3"],
    field4: json["field4"],
    link: json["link"],
    isRead: json["is_read"],
  );
}
