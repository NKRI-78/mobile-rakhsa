import 'package:rakhsa/misc/client/dio_client.dart';
import 'package:rakhsa/repositories/auth/model/user_session.dart';

class AuthRepository {
  AuthRepository({required DioClient client}) : _client = client;

  final DioClient _client;

  Future<UserSession> login(String phone, String password) async {
    final res = await _client.post(
      endpoint: '/auth/login',
      data: {"value": phone, "password": password},
    );
    return UserSession.fromJson(res.data);
  }

  Future<UserSession> register(
    String fullname,
    String phone,
    String password,
  ) async {
    final res = await _client.post(
      endpoint: '/auth/register-member',
      data: {
        "fullname": fullname,
        "phone": phone,
        "password": password,
        "email": "-",
        "passport": "-",
        "emergency_contact": "-",
      },
    );
    return UserSession.fromJson(res.data);
  }
}
