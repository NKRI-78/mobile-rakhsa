class PaymentModel {
  int status;
  bool error;
  String message;
  List<PaymentData> data;

  PaymentModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: List<PaymentData>.from(json["data"].map((x) => PaymentData.fromJson(x))),
  );
}

class PaymentData {
  int id;
  String paymentType;
  String name;
  String nameCode;
  String logo;
  String platform;
  int fee;
  dynamic serviceFee;
  dynamic howToUseUrl;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  PaymentData({
    required this.id,
    required this.paymentType,
    required this.name,
    required this.nameCode,
    required this.logo,
    required this.platform,
    required this.fee,
    required this.serviceFee,
    required this.howToUseUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) => PaymentData(
    id: json["id"],
    paymentType: json["paymentType"],
    name: json["name"],
    nameCode: json["nameCode"],
    logo: json["logo"],
    platform: json["platform"],
    fee: json["fee"],
    serviceFee: json["service_fee"],
    howToUseUrl: json["howToUseUrl"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    deletedAt: json["deletedAt"],
  );
}
