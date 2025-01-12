import 'package:rakhsa/features/ppob/domain/entities/inquiry_pulsa.dart';

class PPOBPulsaInquiryModel {
  final int? code;
  dynamic error;
  final String? message;
  final List<PPOBPulsaInquiryData>? data;

  PPOBPulsaInquiryModel({
    this.code,
    this.error,
    this.message,
    this.data,
  });

  factory PPOBPulsaInquiryModel.fromJson(Map<String, dynamic> json) => PPOBPulsaInquiryModel(
    code: json["code"],
    error: json["error"],
    message: json["message"],
    data: List<PPOBPulsaInquiryData>.from(json["body"].map((x) => PPOBPulsaInquiryData.fromJson(x))),
  );
}

class PPOBPulsaInquiryData {
  final String? productCode;
  final int? productPrice;
  final int? productFee;
  final String? productName;

  PPOBPulsaInquiryData({
    this.productCode,
    this.productPrice,
    this.productFee,
    this.productName,
  });

  factory PPOBPulsaInquiryData.fromJson(Map<String, dynamic> json) => PPOBPulsaInquiryData(
    productCode: json["product_code"],
    productPrice: json["product_price"],
    productFee: json["product_fee"],
    productName: json["product_name"],
  );

  PPOBPulsaInquiryDataEntity toEntity() {
    return PPOBPulsaInquiryDataEntity(
      productCode: productCode!,
      productFee: productFee!,
      productName: productName!,
      productPrice: productPrice!
    );
  }
}
