import 'package:rakhsa/features/ppob/domain/entities/inquiry_tokenlistrik.dart';

class PPOBTokenListrikInquiryModel {
  int code;
  dynamic error;
  String message;
  PPOBTokenListrikInquiryDataEntity data;

  PPOBTokenListrikInquiryModel({
    required this.code,
    required this.error,
    required this.message,
    required this.data,
  });

  factory PPOBTokenListrikInquiryModel.fromJson(Map<String, dynamic> json) => PPOBTokenListrikInquiryModel(
    code: json["code"],
    error: json["error"],
    message: json["message"],
    data: PPOBTokenListrikInquiryDataEntity.fromJson(json["body"]),
  );
}