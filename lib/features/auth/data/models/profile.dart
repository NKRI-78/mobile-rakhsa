class ProfileModel {
  int? status;
  bool? error;
  String? message;
  ProfileData? data;

  ProfileModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: ProfileData.fromJson(json["data"]),
  );
}

class ProfileData {
  String id;
  String username;
  String avatar;
  String address;
  String passport;
  String emergencyContact;
  String createdAt;

  ProfileData({
    required this.id,
    required this.username,
    required this.avatar,
    required this.address,
    required this.passport,
    required this.emergencyContact,
    required this.createdAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    id: json["id"],
    username: json["username"],
    avatar: json["avatar"] ?? "-",
    address: json["address"],
    passport: json["passport"],
    emergencyContact: json["emergency_contact"],
    createdAt: json["created_at"],
  );
}
