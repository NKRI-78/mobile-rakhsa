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
          ? "Anda belum memiliki akun Marlinda. Silakan daftar terlebih dahulu untuk melanjutkan."
          : e.message == "Credentials invalid"
          ? "Password Anda salah silahkan coba lagi"
          : e.message;
      throw ClientException(
        errorCode: e.message,
        code: e.code,
        message: message,
      );
    } on DataParsingException catch (e) {
      throw ClientException(
        code: e.code,
        message: e.message,
        errorCode: e.errorCode,
      );
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
          ? "Pengguna sudah terdaftar. Silakan masuk untuk melanjutkan."
          : e.message;
      throw ClientException(
        errorCode: e.message,
        code: e.code,
        message: message,
      );
    } on DataParsingException catch (e) {
      throw ClientException(
        code: e.code,
        message: e.message,
        errorCode: e.errorCode,
      );
    }
  }

  Future<void> forgotPassword(String phone, String newPassword) async {
    try {
      await _client.post(
        endpoint: '/auth/forgot-password',
        data: {"phone": phone, "new_password": newPassword},
      );
    } on ClientException catch (e) {
      final message = e.message == "User not found"
          ? "Tidak ada akun yang terdaftar untuk nomor ini. Cek kembali nomor anda atau Registrasi ulang dengan nomor yang baru."
          : e.message;
      throw ClientException(
        errorCode: e.message,
        code: e.code,
        message: message,
      );
    } on DataParsingException catch (e) {
      throw ClientException(
        code: e.code,
        message: e.message,
        errorCode: e.errorCode,
      );
    }
  }

  Future<void> logout(String uid) async {
    await _client.post(endpoint: "/auth/logout", data: {"user_id": uid});
  }
}
