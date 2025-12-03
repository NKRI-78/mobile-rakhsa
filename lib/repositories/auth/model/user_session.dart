// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:rakhsa/misc/client/errors/errors.dart';

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
    } catch (e) {
      throw DataParsingException(error: e);
    }
  }

  Map<String, dynamic> toJson() => {
    "token": token,
    "refresh_token": refreshToken,
    "user": user.toJson(),
  };

  @override
  String toString() =>
      'UserSession(token: $token, refreshToken: $refreshToken, user: $user)';
}

class UserDataSession {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? access;
  final bool enabled;
  final bool isLoggedInOnAnotherDevice;

  UserDataSession({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.access,
    this.enabled = false,
    this.isLoggedInOnAnotherDevice = false,
  });

  UserDataSession copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? access,
    bool? enabled,
    bool? isLoggedInOnAnotherDevice,
  }) => UserDataSession(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    role: role ?? this.role,
    access: access ?? this.access,
    enabled: enabled ?? this.enabled,
    isLoggedInOnAnotherDevice:
        isLoggedInOnAnotherDevice ?? this.isLoggedInOnAnotherDevice,
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
        enabled: json["enabled"] ?? false,
        isLoggedInOnAnotherDevice: json["is_logged_in"] ?? false,
      );
    } catch (e) {
      throw DataParsingException(error: e);
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
    "is_logged_in": isLoggedInOnAnotherDevice,
  };

  @override
  String toString() {
    return 'UserDataSession(id: $id, name: $name, email: $email, phone: $phone, role: $role, access: $access, enabled: $enabled, isLoggedInOnAnotherDevice: $isLoggedInOnAnotherDevice)';
  }
}
