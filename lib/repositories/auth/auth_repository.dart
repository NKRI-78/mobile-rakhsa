import 'package:rakhsa/misc/client/dio_client.dart';
import 'package:rakhsa/misc/client/errors/exceptions/exceptions.dart';
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

      final session = UserSession.fromJson(res.data);

      // if (session.user.isLoggedInOnAnotherDevice) {
      //   throw NetworkException(
      //     errorCode: "LOGGEDIN_ON_ANOTHER_DEVICE",
      //     title: "Login Terdeteksi di Perangkat Lain",
      //     message:
      //         "Akun ini sedang aktif di perangkat lain. Silakan logout dari perangkat tersebut terlebih dahulu sebelum mencoba login kembali.",
      //   );
      // }

      return session;
    } on NetworkException catch (e) {
      final message = e.message == "User not found"
          ? "Akun Marlinda tidak ditemukan. Email yang Anda masukkan mungkin salah atau belum terdaftar. Silakan daftar terlebih dahulu untuk melanjutkan."
          : e.message == "Credentials invalid"
          ? "Password Anda salah silahkan coba lagi"
          : e.message;
      throw NetworkException(
        title: e.title,
        message: message,
        errorCode: e.message,
      );
    } on DataParsingException catch (e) {
      throw NetworkException(message: e.message, errorCode: e.errorCode);
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
    } on NetworkException catch (e) {
      final message = e.message == "User already exist"
          ? "Pengguna sudah terdaftar. Silakan masuk untuk melanjutkan."
          : e.message;
      throw NetworkException(message: message, errorCode: e.message);
    } on DataParsingException catch (e) {
      throw NetworkException(message: e.message, errorCode: e.errorCode);
    }
  }

  Future<void> forgotPassword(String phone, String newPassword) async {
    try {
      await _client.post(
        endpoint: '/auth/forgot-password',
        data: {"phone": phone, "new_password": newPassword},
      );
    } on NetworkException catch (e) {
      final message = e.message == "User not found"
          ? "Tidak ada akun yang terdaftar untuk nomor $phone. Cek kembali nomor anda atau Registrasi ulang dengan nomor yang baru."
          : e.message;
      throw NetworkException(message: message, errorCode: e.message);
    } on DataParsingException catch (e) {
      throw NetworkException(message: e.message, errorCode: e.errorCode);
    }
  }

  Future<void> logout(String uid) async {
    await _client.post(endpoint: "/auth/logout", data: {"user_id": uid});
  }
}
