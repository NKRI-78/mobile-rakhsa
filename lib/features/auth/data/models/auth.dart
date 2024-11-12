class AuthModel {
  int status;
  bool error;
  String message;
  AuthData data;

  AuthModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
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

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    role: json["role"],
  );
}
