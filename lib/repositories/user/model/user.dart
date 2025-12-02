import 'dart:convert';

import 'package:rakhsa/misc/client/errors/errors.dart';
import 'package:rakhsa/repositories/referral/model/referral.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  final String? id;
  final String? username;
  final String? email;
  final String? avatar;
  final String? address;
  final String? passport;
  final String? contact;
  final String? emergencyContact;
  final String? gender;
  final String? passportExpired;
  final String? passportIssued;
  final String? noReg;
  final String? mrzCode;
  final String? issuingAuthority;
  final String? citizen;
  final String? birthDate;
  final String? birthPlace;
  final String? codeCountry;
  final String? state;
  final String? createdAt;
  final String? lat;
  final String? lng;
  final Doc? doc;
  final Sos? sos;
  final String? keyword;
  final String? serviceId;
  final String? expiresAt;
  final bool hasRoamingPackage;
  final List<ReferralPackage> package;

  User({
    this.id,
    this.username,
    this.email,
    this.avatar,
    this.address,
    this.passport,
    this.contact,
    this.emergencyContact,
    this.gender,
    this.passportExpired,
    this.passportIssued,
    this.noReg,
    this.mrzCode,
    this.issuingAuthority,
    this.citizen,
    this.birthDate,
    this.birthPlace,
    this.codeCountry,
    this.state,
    this.createdAt,
    this.lat,
    this.lng,
    this.doc,
    this.sos,
    this.keyword,
    this.serviceId,
    this.expiresAt,
    this.hasRoamingPackage = false,
    this.package = const <ReferralPackage>[],
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    String? address,
    String? passport,
    String? contact,
    String? emergencyContact,
    String? gender,
    String? passportExpired,
    String? passportIssued,
    String? noReg,
    String? mrzCode,
    String? issuingAuthority,
    String? citizen,
    String? birthDate,
    String? birthPlace,
    String? codeCountry,
    String? state,
    String? createdAt,
    String? lat,
    String? lng,
    Doc? doc,
    Sos? sos,
    String? keyword,
    String? serviceId,
    String? expiresAt,
    bool? hasRoamingPackage,
    List<ReferralPackage>? package,
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    email: email ?? this.email,
    avatar: avatar ?? this.avatar,
    address: address ?? this.address,
    passport: passport ?? this.passport,
    contact: contact ?? this.contact,
    emergencyContact: emergencyContact ?? this.emergencyContact,
    gender: gender ?? this.gender,
    passportExpired: passportExpired ?? this.passportExpired,
    passportIssued: passportIssued ?? this.passportIssued,
    noReg: noReg ?? this.noReg,
    mrzCode: mrzCode ?? this.mrzCode,
    issuingAuthority: issuingAuthority ?? this.issuingAuthority,
    citizen: citizen ?? this.citizen,
    birthDate: birthDate ?? this.birthDate,
    birthPlace: birthPlace ?? this.birthPlace,
    codeCountry: codeCountry ?? this.codeCountry,
    state: state ?? this.state,
    createdAt: createdAt ?? this.createdAt,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    doc: doc ?? this.doc,
    sos: sos ?? this.sos,
    keyword: keyword ?? this.keyword,
    serviceId: serviceId ?? this.serviceId,
    expiresAt: expiresAt ?? this.expiresAt,
    hasRoamingPackage: hasRoamingPackage ?? this.hasRoamingPackage,
    package: package ?? this.package,
  );

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        avatar: json["avatar"],
        address: json["address"],
        passport: json["passport"],
        contact: json["contact"],
        emergencyContact: json["emergency_contact"],
        gender: json["gender"],
        passportExpired: json["passport_expired"],
        passportIssued: json["passport_issued"],
        noReg: json["no_reg"],
        mrzCode: json["mrz_code"],
        issuingAuthority: json["issuing_authority"],
        citizen: json["citizen"],
        birthDate: json["birth_date"],
        birthPlace: json["birth_place"],
        codeCountry: json["code_country"],
        state: json["state"],
        createdAt: json["created_at"],
        lat: json["lat"],
        lng: json["lng"],
        doc: json["doc"] == null ? null : Doc.fromJson(json["doc"]),
        sos: json["sos"] == null ? null : Sos.fromJson(json["sos"]),
        keyword: json['keyword'],
        serviceId: json['service_id'],
        expiresAt: json['expires_at'],
        hasRoamingPackage: json['has_roaming_package'],
        package:
            (json['package'] as List<dynamic>?)
                ?.map((e) => ReferralPackage.fromJson(e))
                .toList() ??
            [],
      );
    } catch (e) {
      throw DataParsingException(error: e);
    }
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "avatar": avatar,
    "address": address,
    "passport": passport,
    "contact": contact,
    "emergency_contact": emergencyContact,
    "gender": gender,
    "passport_expired": passportExpired,
    "passport_issued": passportIssued,
    "no_reg": noReg,
    "mrz_code": mrzCode,
    "issuing_authority": issuingAuthority,
    "citizen": citizen,
    "birth_date": birthDate,
    "birth_place": birthPlace,
    "code_country": codeCountry,
    "state": state,
    "created_at": createdAt,
    "lat": lat,
    "lng": lng,
    "doc": doc?.toJson(),
    "sos": sos?.toJson(),
    "keyword": keyword,
    "service_id": serviceId,
    "expires_at": expiresAt,
    "has_roaming_package": hasRoamingPackage,
    "package": package.map((e) => e.toJson()).toList(),
  };
}

class Doc {
  final String? visa;
  final String? passport;

  Doc({this.visa, this.passport});

  Doc copyWith({String? visa, String? passport}) =>
      Doc(visa: visa ?? this.visa, passport: passport ?? this.passport);

  factory Doc.fromJson(Map<String, dynamic> json) {
    try {
      return Doc(visa: json["visa"], passport: json["passport"]);
    } catch (e) {
      throw DataParsingException(error: e);
    }
  }

  Map<String, dynamic> toJson() => {"visa": visa, "passport": passport};
}

class Sos {
  final String? id;
  final String? chatId;
  final String? recipientId;
  final bool? running;

  Sos({this.id, this.chatId, this.recipientId, this.running});

  Sos copyWith({
    String? id,
    String? chatId,
    String? recipientId,
    bool? running,
  }) => Sos(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    recipientId: recipientId ?? this.recipientId,
    running: running ?? this.running,
  );

  factory Sos.fromJson(Map<String, dynamic> json) {
    try {
      return Sos(
        id: json["id"],
        chatId: json["chat_id"],
        recipientId: json["recipient_id"],
        running: json["running"],
      );
    } catch (e) {
      throw DataParsingException(error: e);
    }
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "chat_id": chatId,
    "recipient_id": recipientId,
    "running": running,
  };
}
