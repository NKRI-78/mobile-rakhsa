
class PPOBPulsaInquiryModel {
  int status;
  bool error;
  String message;
  List<PPOBPulsaInquiryData> data;

  PPOBPulsaInquiryModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory PPOBPulsaInquiryModel.fromJson(Map<String, dynamic> json) => PPOBPulsaInquiryModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: List<PPOBPulsaInquiryData>.from(json["data"].map((x) => PPOBPulsaInquiryData.fromJson(x))),
  );
}

class PPOBPulsaInquiryData {
  String id;
  String code;
  int price;
  String name;

  PPOBPulsaInquiryData({
    required this.id,
    required this.code,
    required this.price,
    required this.name,
  });

  factory PPOBPulsaInquiryData.fromJson(Map<String, dynamic> json) => PPOBPulsaInquiryData(
    id: json["id"],
    code: json["code"],
    price: json["price"],
    name: json["name"],
  );
}
