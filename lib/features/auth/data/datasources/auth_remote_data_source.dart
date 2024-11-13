import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/errors/exception.dart';

import 'package:rakhsa/features/auth/data/models/auth.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login({
    required String value, 
    required String password
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
    debugPrint(value);
    debugPrint(password);
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

}