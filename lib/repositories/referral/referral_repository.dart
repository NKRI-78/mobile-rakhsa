import 'package:dio/dio.dart';
import 'package:rakhsa/core/client/dio_client.dart';
import 'package:rakhsa/core/client/errors/errors.dart';
import 'package:rakhsa/core/client/response/response_dto.dart';
import 'package:rakhsa/core/debug/logger.dart';
import 'package:rakhsa/repositories/referral/model/referral.dart';
import 'package:rakhsa/service/storage/storage.dart';

class ReferralRepository {
  final DioClient _client;

  ReferralRepository(this._client);

  Dio get _newClient => _client.createNewInstance(
    baseUrl: "https://api-marlinda.langitdigital78.com/api/v1",
  );

  final _referalCodeCacheKey = "referral_code_cache_key";

  Future<void> saveReferralCode(String code) async {
    try {
      await StorageHelper.write(_referalCodeCacheKey, code);
      log("referralCode berhasil disimpan = $code", label: "REFERRAL_CODE");
    } catch (_) {}
  }

  String? getReferralCode() {
    return StorageHelper.read(_referalCodeCacheKey);
  }

  bool hasReferralCode() {
    return StorageHelper.containsKey(_referalCodeCacheKey) &&
        (getReferralCode() != null);
  }

  Future<void> deleteReferalCode() async {
    try {
      await StorageHelper.delete(_referalCodeCacheKey);
      log("referralCode berhasil dihapus", label: "REFERRAL_CODE");
    } catch (_) {}
  }

  Future<ReferralData?> activateReferralCode(String uid) async {
    final code = getReferralCode();
    if (code == null) return null;
    try {
      if (!await _client.hasInternet) {
        throw NetworkException.noInternetConnection();
      }

      final res = await _newClient.get(
        "/nbp/activation/notify?token=$code&user_id=$uid",
      );

      log(
        "activate referral code res = ${{"ref_code": code, "uid": uid, "res": res.data}}",
        label: "REFERRAL_CODE",
      );

      final dto = ResponseDto.fromJson(res.data);
      final data = ReferralData.fromJson(dto.data);

      if (data.package == null) {
        if (dto.code == "TOKEN_USED") {
          throw ReferralException(
            title: _titleErrorMapping(dto.code),
            message: _messageErrorMapping(dto.code),
            errorCode: dto.code,
            statusCode: res.statusCode,
          );
        }
      }

      return data;
    } on DioException catch (e) {
      final data = e.response?.data;
      final errorCode = data['code'];
      final mappedMsg = _messageErrorMapping(errorCode);

      log(
        "activate referral code res = ${{"ref_code": code, "uid": uid, "res": data}}",
        label: "REFERRAL_CODE",
      );

      throw ReferralException(
        title: _titleErrorMapping(errorCode),
        message: mappedMsg.isNotEmpty ? mappedMsg : data['message'],
        errorCode: errorCode,
        error: e,
      );
    } on DataParsingException catch (e) {
      throw NetworkException(message: e.message, errorCode: e.errorCode);
    } on ReferralException catch (e) {
      throw ReferralException(
        message: e.message,
        title: e.title,
        errorCode: e.errorCode,
        statusCode: e.statusCode,
        error: e,
      );
    } catch (e) {
      throw NetworkException.unknown();
    } finally {
      await deleteReferalCode();
    }
  }

  String _titleErrorMapping(dynamic code) {
    if (code is String) {
      return switch (code) {
        "TOKEN_NOT_FOUND" => "Kode Referral Tidak Ditemukan",
        "TOKEN_EXPIRED" => "Kode Referral Sudah Kadaluarsa",
        "TOKEN_USED" => "Kode Referral Sudah Digunakan",
        "TOKEN_INVALID" => "Kode Referral Tidak Valid",
        _ => code,
      };
    }
    return code;
  }

  String _messageErrorMapping(dynamic code) {
    if (code is String) {
      return switch (code) {
        "TOKEN_NOT_FOUND" =>
          "Kode referral tidak ditemukan. Pastikan Anda membuka link aktivasi yang benar dari SMS Marlinda.",
        "TOKEN_EXPIRED" =>
          "Kode referral ini sudah kedaluwarsa. Silakan gunakan link aktivasi terbaru dari SMS Marlinda.",
        "TOKEN_USED" =>
          "Kode referral ini sudah digunakan pada proses aktivasi sebelumnya. Silakan pastikan Anda membuka link aktivasi terbaru dari SMS Marlinda.",
        "TOKEN_INVALID" =>
          "Kode referral tidak valid. Silakan cek kembali link aktivasi Anda dari SMS Marlinda.",
        _ => "",
      };
    }
    return "";
  }
}
