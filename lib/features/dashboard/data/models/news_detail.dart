class NewsDetailModel {
  int status;
  bool error;
  String message;
  NewsDetailData data;

  NewsDetailModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory NewsDetailModel.fromJson(Map<String, dynamic> json) => NewsDetailModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: NewsDetailData.fromJson(json["data"]),
  );
}

class NewsDetailData {
  int? id;
  String? title;
  String? img;
  String? lat;
  String? lng;
  String? desc;
  String? location;
  String? createdAt;

  NewsDetailData({
    this.id,
    this.title,
    this.img,
    this.lat,
    this.lng,
    this.desc,
    this.location,
    this.createdAt,
  });

  factory NewsDetailData.fromJson(Map<String, dynamic> json) => NewsDetailData(
    id: json["id"],
    title: json["title"],
    img: json["img"],
    lat: json["lat"],
    lng: json["lng"],
    desc: json["desc"],
    location: json["location"],
    createdAt: json["created_at"],
  );
}