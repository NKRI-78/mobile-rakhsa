
class BadgeOrderModel {
  int status;
  bool error;
  String message;
  BadgeData data;

  BadgeOrderModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory BadgeOrderModel.fromJson(Map<String, dynamic> json) => BadgeOrderModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: BadgeData.fromJson(json["data"]),
  );
}

class BadgeData {
  int count;

  BadgeData({
    required this.count,
  });

  factory BadgeData.fromJson(Map<String, dynamic> json) => BadgeData(
    count: json["count"],
  );
}