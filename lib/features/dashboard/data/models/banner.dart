
class BannerModel {
  int status;
  bool error;
  String message;
  List<BannerData> data;

  BannerModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: List<BannerData>.from(json["data"].map((x) => BannerData.fromJson(x))),
  );
}

class BannerData {
  int id;
  String title;
  String link;
  String imageUrl;
  DateTime createdAt;
  DateTime updatedAt;

  BannerData({
    required this.id,
    required this.title,
    required this.link,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,  
  });

  factory BannerData.fromJson(Map<String, dynamic> json) => BannerData(
    id: json["id"],
    title: json["title"],
    link: json["link"],
    imageUrl: json["image_url"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
   );
}
