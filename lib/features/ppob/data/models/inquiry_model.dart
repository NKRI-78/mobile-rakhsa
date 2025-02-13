class InquiryPayPpobModel {
  int status;
  bool error;
  String message;
  InquiryDataPayPpobData data;

  InquiryPayPpobModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory InquiryPayPpobModel.fromJson(Map<String, dynamic> json) => InquiryPayPpobModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: InquiryDataPayPpobData.fromJson(json["data"]),
  );
}

class InquiryDataPayPpobData {
  String paymentAccess;
  String paymentType;

  InquiryDataPayPpobData({
    required this.paymentAccess,
    required this.paymentType,
  });

  factory InquiryDataPayPpobData.fromJson(Map<String, dynamic> json) => InquiryDataPayPpobData(
    paymentAccess: json["payment_access"],
    paymentType: json["payment_type"],
  );
}
