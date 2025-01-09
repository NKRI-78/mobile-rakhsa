class OwnerModel {
  int? status;
  bool? error;
  String? message;
  OwnerData? data;

  OwnerModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) => OwnerModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: OwnerData.fromJson(json["data"]),
  );
}

class OwnerData {
  String storeId;
  bool haveStore;

  OwnerData({
    required this.storeId,
    required this.haveStore,
  });

  factory OwnerData.fromJson(Map<String, dynamic> json) => OwnerData(
    storeId: json["store_id"],
    haveStore: json["have_store"],
  );
}