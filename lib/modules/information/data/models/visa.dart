class VisaContentModel {
  int? status;
  bool? error;
  String? message;
  VisaContentData? data;

  VisaContentModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory VisaContentModel.fromJson(Map<String, dynamic> json) => VisaContentModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: VisaContentData.fromJson(json["data"]),
  );
}

class VisaContentData {
  String content;

  VisaContentData({
    required this.content,
  });

  factory VisaContentData.fromJson(Map<String, dynamic> json) => VisaContentData(
    content: json["content"],
  );
}
