
class KbriInfoModel {
  int status;
  bool error;
  String message;
  KbriInfoData data;

  KbriInfoModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory KbriInfoModel.fromJson(Map<String, dynamic> json) => KbriInfoModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: KbriInfoData.fromJson(json["data"]),
  );
}

class KbriInfoData {
  String title;
  String img;
  String description;
  String lat;
  String lng;
  String address;
  dynamic emergencyCall;

  KbriInfoData({
    required this.title,
    required this.img,
    required this.description,
    required this.lat,
    required this.lng,
    required this.address,
    required this.emergencyCall,
  });

  factory KbriInfoData.fromJson(Map<String, dynamic> json) => KbriInfoData(
    title: json["title"],
    img: json["img"],
    description: json["description"],
    lat: json["lat"],
    lng: json["lng"],
    address: json["address"],
    emergencyCall: json["emergency_call"],
  );
}
