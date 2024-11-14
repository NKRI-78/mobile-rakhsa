class AuthModel {
  int? status;
  bool? error;
  String? message;
  AuthData? data;

  AuthModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: AuthData.fromJson(json["data"]),
  );
}

class AuthData {
  String token;
  String refreshToken;
  User user;

  AuthData({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
    token: json["token"],
    refreshToken: json["refresh_token"],
    user: User.fromJson(json["user"]),
  );
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
    id: json["id"] ?? "",
    name: json["name"] ?? "",
    email: json["email"] ?? "",
    phone: json["phone"] ?? "",
    role: json["role"] ?? "",
    enabled: json["enabled"] ?? "",
  );
}
