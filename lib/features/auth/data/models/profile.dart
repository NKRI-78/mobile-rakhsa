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
  String passportExpired;
  String passportIssued;
  String issuingAuthority;
  String citizen;
  String contact;
  String emergencyContact;
  String noReg;
  String mrzCode;
  String codeCountry;
  String birthplace;
  String birthdate;
  String gender;
  String lat;
  String lng;
  String createdAt;
  ProfileDoc document;
  ProfileSos sos;

  ProfileData({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.address,
    required this.passport,
    required this.passportExpired,
    required this.passportIssued,
    required this.issuingAuthority,
    required this.citizen,
    required this.contact,
    required this.emergencyContact,
    required this.noReg,
    required this.mrzCode,
    required this.codeCountry,
    required this.birthplace,
    required this.birthdate,
    required this.gender,
    required this.lat,
    required this.lng,
    required this.createdAt,
    required this.document,
    required this.sos,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    id: json["id"],
    username: json["username"],
    email: json["email"],
    avatar: json["avatar"],
    address: json["address"],
    passport: json["passport"],
    passportExpired: json["passport_expired"],
    passportIssued: json["passport_issued"],
    issuingAuthority: json["issuing_authority"],
    citizen: json["citizen"],
    contact: json["contact"],
    emergencyContact: json["emergency_contact"],
    noReg: json["no_reg"],
    mrzCode: json["mrz_code"],
    codeCountry: json["code_country"],
    birthdate: json["birth_date"],
    birthplace: json["birth_place"],
    gender: json["gender"],
    lat: json["lat"],
    lng: json["lng"],
    createdAt: json["created_at"],
    document: ProfileDoc.fromJson(json['doc']),
    sos: ProfileSos.fromJson(json["sos"]),
  );
}

class ProfileDoc {
  final String visa;
  final String passport;

  ProfileDoc({required this.visa, required this.passport});

  factory ProfileDoc.fromJson(Map<String, dynamic> json) => ProfileDoc(
    visa: json['visa'],
    passport: json['passport'],
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
