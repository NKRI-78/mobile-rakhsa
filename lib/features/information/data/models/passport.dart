class PassportContentModel {
  int status;
  bool error;
  String message;
  PassportContentData data;

  PassportContentModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory PassportContentModel.fromJson(Map<String, dynamic> json) => PassportContentModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: PassportContentData.fromJson(json["data"]),
  );
}

class PassportContentData {
  String content;

  PassportContentData({
    required this.content,
  });

  factory PassportContentData.fromJson(Map<String, dynamic> json) => PassportContentData(
    content: json["content"],
  );
}