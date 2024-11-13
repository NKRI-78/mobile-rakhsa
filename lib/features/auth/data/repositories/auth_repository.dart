import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/utils/dio.dart';
import 'package:rakhsa/features/auth/data/models/user.dart';

class AuthRepository {
  Dio? dioClient;

  AuthRepository({required this.dioClient}) {
    dioClient ??= DioManager.shared.getClient();
  }

  Future<UserModel> register(
      {required String fullname,
      required String email,
      required String phone,
      required String passport,
      required String emergencyContact,
      required String password,
      required String lastName}) async {
    try {
      Response res = await dioClient!.post("${RemoteDataSourceConsts.baseUrl}/api/v1/auth/register-member", data: {
        "fullname": fullname,
        "email": email,
        "phone": phone,
        "passport": passport,
        "emergency_contact": emergencyContact,
        "password": password
      });
      Map<String, dynamic> dataJson = res.data;
      UserModel data = UserModel.fromJson(dataJson);
      return data;
    } on DioException catch (e) {
      throw handleDioException(e);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw ServerException(e.toString());
    }
  }
}