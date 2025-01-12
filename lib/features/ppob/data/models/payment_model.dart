import 'package:rakhsa/features/ppob/domain/entities/payment.dart';

class PaymentModel {
  int? code;
  dynamic error;
  String? message;
  List<PaymentData>? data;

   PaymentModel({
    this.code,
    this.error,
    this.message,
    this.data,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    code: json["code"],
    error: json["error"],
    message: json["message"],
    data: List<PaymentData>.from(json["body"].map((x) => PaymentData.fromJson(x))),
  );
}

class PaymentData {
  String? channel;
  String? category;
  String? guide;
  int? minAmount;
  String? name;
  String? paymentCode;
  String? paymentDescription;
  String? paymentGateway;
  String? paymentLogo;
  String? paymentMethod;
  String? paymentName;
  String? paymentUrl;
  int? totalAdminFee;
  String? classId;
  bool? isDirect;
  dynamic paymentUrlV2;

  PaymentData({
    this.channel,
    this.category,
    this.guide,
    this.minAmount,
    this.name,
    this.paymentCode,
    this.paymentDescription,
    this.paymentGateway,
    this.paymentLogo,
    this.paymentMethod,
    this.paymentName,
    this.paymentUrl,
    this.totalAdminFee,
    this.classId,
    this.isDirect,
    this.paymentUrlV2,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) => PaymentData(
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

  PaymentDataEntity toEntity() {
    return PaymentDataEntity(
      category: category!,
      channel: channel!,
      classId: classId!,
      guide: guide!,
      isDirect: isDirect!,
      minAmount: minAmount!,
      name: name!,
      paymentCode: paymentCode!,
      paymentDescription: paymentDescription!,
      paymentGateway: paymentGateway!,
      paymentLogo: paymentLogo!,
      paymentMethod: paymentMethod!,
      paymentName: paymentName!,
      paymentUrl: paymentUrl!,
      paymentUrlV2: paymentUrlV2,
      totalAdminFee: totalAdminFee!
    );
  }
}