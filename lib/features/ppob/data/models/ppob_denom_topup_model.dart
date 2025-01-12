import 'package:rakhsa/features/ppob/domain/entities/denom_topup.dart';

class DenomTopupModel {
  int code;
  dynamic error;
  String message;
  DenomTopupDataEntity body;

  DenomTopupModel({
    required this.code,
    required this.error,
    required this.message,
    required this.body,
  });

  factory DenomTopupModel.fromJson(Map<String, dynamic> json) => DenomTopupModel(
    code: json["code"],
    error: json["error"],
    message: json["message"],
    body: DenomTopupDataEntity.fromJson(json["body"]),
  );
}
