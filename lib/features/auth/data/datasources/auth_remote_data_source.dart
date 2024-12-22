import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/data/models/profile.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login({
    required String value, 
    required String password
  });
  Future<void> updateIsLoggedIn({
    required String userId,
    required String type
  });
  Future<ProfileModel> getProfile();
  Future<void> updateProfile({
    required String avatar
  });
  Future<AuthModel> register({
    required String fullname,
    required String email,
    required String phone,
    required String passport,
    required String emergencyContact,
    required String password
  });
  Future<void> verifyOtp({
    required String email,
    required String otp,
  });
  Future<void> resendOtp({
    required String email,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {

  Dio client;

  AuthRemoteDataSourceImpl({required this.client});

  @override 
  Future<AuthModel> login({
    required String value,
    required String password
  }) async {
    try {
      final response = await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/auth/login",
        data: {
          "value": value,
          "password": password
        }
      );
      Map<String, dynamic> data = response.data;
      AuthModel authModel = AuthModel.fromJson(data);
      return authModel;
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    } 
  }

  @override 
  Future<void> updateIsLoggedIn({
    required String userId,
    required String type
  }) async {
    try {
      await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/auth/is-logged-in",
        data: {
          "user_id": userId,
          "type": type
        }
      );
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override 
  Future<ProfileModel> getProfile() async {
    try {
      final response = await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile",
        data: {
          "user_id": StorageHelper.getUserId(),
        }
      );
      Map<String, dynamic> data = response.data;
      ProfileModel profileModel = ProfileModel.fromJson(data);
      return profileModel;
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    } 
  }

  @override 
  Future<void> updateProfile({required String avatar}) async {
    try {
      await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile/update",
        data: {
          "user_id": StorageHelper.getUserId(),
          "avatar": avatar,
        }
      );
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    } 
  }

  @override
  Future<AuthModel> register({
    required String fullname,
    required String email,
    required String phone,
    required String passport,
    required String emergencyContact,
    required String password
  }) async {
    try {
      final response = await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/auth/register-member",
        data: {
          "fullname": fullname,
          "email": email,
          "phone": phone,
          "passport": passport,
          "emergency_contact": emergencyContact,
          "password": password
        }
      );
      Map<String, dynamic> data = response.data;
      AuthModel authModel = AuthModel.fromJson(data);
      return authModel;
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    } 
  }
  
  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    try {
      await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/auth/verify-otp",
        data: {
          "email": email,
          "otp": otp,
        }
      );
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> resendOtp({required String email}) async {
    try {
      await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/auth/resend-otp",
        data: {
          "email": email,
        }
      );
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

}