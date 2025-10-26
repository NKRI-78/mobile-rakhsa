import 'dart:convert';

import 'package:rakhsa/misc/client/errors/code.dart';
import 'package:rakhsa/misc/client/errors/exceptions.dart';

UserSession userSessionFromJson(String str) =>
    UserSession.fromJson(json.decode(str));

String userSessionToJson(UserSession data) => json.encode(data.toJson());

class UserSession {
  final String token;
  final String refreshToken;
  final UserDataSession user;

  UserSession({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  UserSession copyWith({
    String? token,
    String? refreshToken,
    UserDataSession? user,
  }) {
    return UserSession(
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    try {
      return UserSession(
        token: json["token"],
        refreshToken: json["refresh_token"],
        user: UserDataSession.fromJson(json["user"]),
      );
    } catch (e, st) {
      throw DataParsingException(
        ErrorCode.errorDataParsing.message("UserSession"),
        e,
        st,
      );
    }
  }

  Map<String, dynamic> toJson() => {
    "token": token,
    "refresh_token": refreshToken,
    "user": user.toJson(),
  };
}

class UserDataSession {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? access;
  final bool enabled;

  UserDataSession({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.access,
    required this.enabled,
  });

  UserDataSession copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? access,
    bool? enabled,
  }) => UserDataSession(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    role: role ?? this.role,
    access: access ?? this.access,
    enabled: enabled ?? this.enabled,
  );

  factory UserDataSession.fromJson(Map<String, dynamic> json) {
    try {
      return UserDataSession(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        role: json["role"],
        access: json["access"] ?? "-",
        enabled: json["enabled"],
      );
    } catch (e, st) {
      throw DataParsingException(
        ErrorCode.errorDataParsing.message("UserDataSession"),
        e,
        st,
      );
    }
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "role": role,
    "access": access,
    "enabled": enabled,
  };
}
