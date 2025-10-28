import 'package:rakhsa/injection.dart';
import 'package:rakhsa/misc/client/dio_client.dart';
import 'package:rakhsa/misc/client/errors/exceptions.dart';
import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/repositories/auth/model/user_session.dart';
import 'package:rakhsa/repositories/user/user_repository.dart';
import 'package:rakhsa/socketio.dart';

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
          ? "Pengguna sudah terdaftar silahkan pakai nomor telepon lain."
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

  Future<void> logout() async {
    final session = await StorageHelper.getUserSession();
    if (session != null) {
      locator<SocketIoService>().socket?.emit("leave", {
        "user_id": session.user.id,
      });
    }
    await StorageHelper.removeUserSession();
    await StorageHelper.delete(UserRepository.cacheKey);
  }
}
