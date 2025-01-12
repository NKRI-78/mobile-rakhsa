class PPOBPulsaInquiryDataEntity {
  String? productCode;
  int? productPrice;
  int? productFee;
  String? productName;

  PPOBPulsaInquiryDataEntity({
    this.productCode,
    this.productPrice,
    this.productFee,
    this.productName,
  });

  factory PPOBPulsaInquiryDataEntity.fromJson(Map<String, dynamic> json) => PPOBPulsaInquiryDataEntity(
    productCode: json["product_code"],
    productPrice: json["product_price"],
    productFee: json["product_fee"],
    productName: json["product_name"],
  );
}