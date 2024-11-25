class NewsModel {
  int status;
  bool error;
  String message;
  List<NewsData> data;

  NewsModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: List<NewsData>.from(json["data"].map((x) => NewsData.fromJson(x))),
  );
}

class NewsData {
  int id;
  String title;
  String img;
  String desc;
  String createdAt;

  NewsData({
    required this.id,
    required this.title,
    required this.img,
    required this.desc,
    required this.createdAt,
  });

  factory NewsData.fromJson(Map<String, dynamic> json) => NewsData(
    id: json["id"],
    title: json["title"],
    img: json["img"],
    desc: json["desc"],
    createdAt: json["created_at"],
  );
}
