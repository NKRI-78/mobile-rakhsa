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
  String email;
  String avatar;
  String address;
  String passport;
  String contact;
  String emergencyContact;
  String createdAt;
  ProfileSos sos;

  ProfileData({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.address,
    required this.passport,
    required this.contact,
    required this.emergencyContact,
    required this.createdAt,
    required this.sos,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    id: json["id"],
    username: json["username"],
    email: json["email"],
    avatar: json["avatar"] ?? "-",
    address: json["address"],
    passport: json["passport"],
    contact: json["contact"],
    emergencyContact: json["emergency_contact"],
    createdAt: json["created_at"],
    sos: ProfileSos.fromJson(json["sos"]),
  );
}

class ProfileSos {
  String id;
  String chatId;
  String recipientId;
  bool running;

  ProfileSos({
    required this.id,
    required this.chatId,
    required this.recipientId,
    required this.running,
  });

  factory ProfileSos.fromJson(Map<String, dynamic> json) => ProfileSos(
    id: json["id"],
    chatId: json["chat_id"],
    running: json["running"],
    recipientId: json["recipient_id"]
  );
}
