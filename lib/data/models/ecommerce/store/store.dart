class StoreModel {
  int? status;
  bool? error;
  String? message;
  StoreData? data;

  StoreModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: StoreData.fromJson(json["data"]),
  );
}

class StoreData {
  String id;
  String name;
  String logo;
  String description;
  String address;
  String province;
  String city;
  String district;
  String subdistrict;
  String postalCode;
  String phone;
  String lat;
  String lng;
  String email;
  bool isOpen;
  DateTime createdAt;

  StoreData({
    required this.id,
    required this.name,
    required this.logo,
    required this.description,
    required this.address,
    required this.province,
    required this.city,
    required this.district,
    required this.subdistrict,
    required this.postalCode,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.email,
    required this.isOpen,
    required this.createdAt,
  });

  factory StoreData.fromJson(Map<String, dynamic> json) => StoreData(
    id: json["id"],
    name: json["name"],
    logo: json["logo"],
    description: json["description"],
    address: json["address"],
    province: json["province"],
    city: json["city"],
    district: json["district"],
    subdistrict: json["subdistrict"],
    postalCode: json["postal_code"],
    phone: json["phone"],
    lat: json["lat"],
    lng: json["lng"],
    email: json["email"],
    isOpen: json["is_open"],
    createdAt: DateTime.parse(json["created_at"]),
  );
}
