import 'package:rakhsa/misc/client/dio_client.dart';
import 'package:rakhsa/misc/client/errors/exceptions.dart';
import 'package:rakhsa/repositories/auth/model/user_session.dart';

class AuthRepository {
  AuthRepository({required DioClient client}) : _client = client;

  final DioClient _client;

  Future<UserSession> login(String phone, String password) async {
    try {
      final res = await _client.post(
        endpoint: '/auth/login',
        data: {"value": phone, "password": password},
      );
      return UserSession.fromJson(res.data);
    } on ClientException catch (e) {
      final message = e.message == "User not found"
          ? "Nomor telepon atau kata sandi yang Anda masukkan salah silahkan cek kembali. Jika Anda belum memiliki akun, silakan daftar terlebih dahulu."
          : e.message == "Credentials invalid"
          ? "Password Anda salah silahkan coba lagi"
          : e.message;
      throw ClientException(message: message);
    }
  }

  Future<UserSession> register(
    String fullname,
    String phone,
    String password,
  ) async {
    try {
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
    } on ClientException catch (e) {
      final message = e.message == "User already exist"
          ? "Pengguna sudah terdaftar silahkan pakai nomor telepon lain."
          : e.message;
      throw ClientException(message: message);
    }
  }
}
