
class KbriInfoModel {
  int? status;
  bool? error;
  String? message;
  KbriInfoData? data;

  KbriInfoModel({
    this.status,
    this.error,
    this.message,
    this.data,
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
  String stateName;
  dynamic emergencyCall;

  KbriInfoData({
    required this.title,
    required this.img,
    required this.description,
    required this.lat,
    required this.lng,
    required this.address,
    required this.stateName,
    required this.emergencyCall,
  });

  factory KbriInfoData.fromJson(Map<String, dynamic> json) => KbriInfoData(
    title: json["title"],
    img: json["img"],
    description: json["description"],
    lat: json["lat"],
    lng: json["lng"],
    address: json["address"],
    stateName: json["state_name"],
    emergencyCall: json["emergency_call"],
  );
}
