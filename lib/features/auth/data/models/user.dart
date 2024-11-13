// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
    int status;
    bool error;
    String message;
    Data data;

    UserModel({
        required this.status,
        required this.error,
        required this.message,
        required this.data,
    });

    factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        status: json["status"],
        error: json["error"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "error": error,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    String token;
    String refreshToken;
    User user;

    Data({
        required this.token,
        required this.refreshToken,
        required this.user,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        refreshToken: json["refresh_token"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "refresh_token": refreshToken,
        "user": user.toJson(),
    };
}

class User {
    String id;
    String name;
    String email;
    String phone;
    String role;
    bool enabled;

    User({
        required this.id,
        required this.name,
        required this.email,
        required this.phone,
        required this.role,
        required this.enabled,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        role: json["role"],
        enabled: json["enabled"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "role": role,
        "enabled": enabled,
    };
}
