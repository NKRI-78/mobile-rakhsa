import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/data/models/passport.dart';
import 'package:rakhsa/features/auth/data/models/profile.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login({required String value, required String password});
  Future<void> updateIsLoggedIn({required String userId, required String type});
  Future<ProfileModel> getProfile();
  Future<void> updateProfile({required String avatar});
  Future<void> forgotPassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  });
  Future<AuthModel> register({
    required String fullName,
    required String emergencyContact,
    required String password,

    // required String email,
    // required String countryCode,
    // required String passportNumber,
    // required String nasionality,
    // required String placeOfBirth,
    // required String dateOfBirth,
    // required String gender,
    // required String dateOfIssue,
    // required String dateOfExpiry,
    // required String registrationNumber,
    // required String issuingAuthority,
    // required String mrzCode,
  });
  Future<AuthModel> verifyOtp({required String email, required String otp});
  Future<void> resendOtp({required String email});
  Future<PassportDataExtraction> registerPassport({required String imagePath});
  Future<void> checkRegisterStatus({
    required String passport,
    required String noReg,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  Dio client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthModel> login({
    required String value,
    required String password,
  }) async {
    try {
      final response = await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/auth/login",
        data: {"value": value, "password": password},
      );
      Map<String, dynamic> data = response.data;
      AuthModel authModel = AuthModel.fromJson(data);
      return authModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateIsLoggedIn({
    required String userId,
    required String type,
  }) async {
    try {
      await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/auth/is-logged-in",
        data: {"user_id": userId, "type": type},
      );
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile",
        data: {"user_id": StorageHelper.getUserId()},
      );
      Map<String, dynamic> data = response.data;
      ProfileModel profileModel = ProfileModel.fromJson(data);
      return profileModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateProfile({required String avatar}) async {
    try {
      await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile/update",
        data: {"user_id": StorageHelper.getUserId(), "avatar": avatar},
      );
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<AuthModel> register({
    required String fullName,
    required String emergencyContact,
    required String password,

    // required String email,
    // required String countryCode,
    // required String passportNumber,
    // required String nasionality,
    // required String placeOfBirth,
    // required String dateOfBirth,
    // required String gender,
    // required String dateOfIssue,
    // required String dateOfExpiry,
    // required String registrationNumber,
    // required String issuingAuthority,
    // required String mrzCode,
  }) async {
    try {
      final response = await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/auth/register-member",
        // data: {
        //   "code_country": countryCode,
        //   "passport": passportNumber,
        //   "fullname": fullName,
        //   "citizen": nasionality,
        //   "birth_place": placeOfBirth,
        //   "birth_date": dateOfBirth,
        //   "gender": gender,
        //   "passport_issued": dateOfIssue,
        //   "passport_expired": dateOfExpiry,
        //   "no_reg": registrationNumber,
        //   "issuing_authority": issuingAuthority,
        //   "mrz_code": mrzCode,
        //   "email": email,
        //   "emergency_contact": emergencyContact,
        //   "password": password
        // }
        data: {
          "fullname": fullName,
          "phone": emergencyContact,
          "password": password,

          "email": "-",
          "passport": "-",
          "emergency_contact": "-",
        },
      );
      Map<String, dynamic> data = response.data;
      AuthModel authModel = AuthModel.fromJson(data);
      return authModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<AuthModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/auth/verify-otp",
        data: {"email": email, "otp": otp},
      );
      Map<String, dynamic> data = response.data;
      AuthModel authModel = AuthModel.fromJson(data);
      return authModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> resendOtp({required String email}) async {
    try {
      await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/auth/resend-otp",
        data: {"email": email},
      );
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> forgotPassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/auth/change-password",
        data: {
          "email": email,
          "old_password": oldPassword,
          "new_password": newPassword,
        },
      );
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<PassportDataExtraction> registerPassport({
    required String imagePath,
  }) async {
    try {
      final fileName = imagePath.split('/').last;
      final formData = FormData.fromMap({
        "media": await MultipartFile.fromFile(imagePath, filename: fileName),
        "folder": 'passport-scan',
        "subfolder": "broadcast-raksha",
      });

      final scanResult = await client.post(
        '${RemoteDataSourceConsts.baseUrlProd}/api/v1/auth/extract-passport',
        data: formData,
      );

      return PassportDataExtraction.fromMap(scanResult.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException(
          'Dokumen yang dipindai bukan paspor atau tidak dikenali. Pastikan Anda memindai halaman identitas paspor yang valid.',
        );
      } else {
        String message = handleDioException(e);
        throw ServerException(message);
      }
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> checkRegisterStatus({
    required String passport,
    required String noReg,
  }) async {
    try {
      await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/auth/check-passport",
        data: {"passport": passport, "no_reg": noReg},
      );
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }
}
