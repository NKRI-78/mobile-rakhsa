class PaymentDataEntity {
  String channel;
  String category;
  String guide;
  int minAmount;
  String name;
  String paymentCode;
  String paymentDescription;
  String paymentGateway;
  String paymentLogo;
  String paymentMethod;
  String paymentName;
  String paymentUrl;
  int totalAdminFee;
  String classId;
  bool isDirect;
  dynamic paymentUrlV2;

  PaymentDataEntity({
    required this.channel,
    required this.category,
    required this.guide,
    required this.minAmount,
    required this.name,
    required this.paymentCode,
    required this.paymentDescription,
    required this.paymentGateway,
    required this.paymentLogo,
    required this.paymentMethod,
    required this.paymentName,
    required this.paymentUrl,
    required this.totalAdminFee,
    required this.classId,
    required this.isDirect,
    required this.paymentUrlV2,
  });

  factory PaymentDataEntity.fromJson(Map<String, dynamic> json) => PaymentDataEntity(
    channel: json["channel"],
    category: json["category"],
    guide: json["guide"],
    minAmount: json["minAmount"],
    name: json["name"],
    paymentCode: json["payment_code"],
    paymentDescription: json["payment_description"],
    paymentGateway: json["payment_gateway"],
    paymentLogo: json["payment_logo"],
    paymentMethod: json["payment_method"],
    paymentName: json["payment_name"],
    paymentUrl: json["payment_url"],
    totalAdminFee: json["total_admin_fee"],
    classId: json["classId"],
    isDirect: json["is_direct"],
    paymentUrlV2: json["payment_url_v2"],
  );
}