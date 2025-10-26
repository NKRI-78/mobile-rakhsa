import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/misc/constants/remote_data_source_consts.dart';
import 'package:rakhsa/misc/client/errors/exception.dart';
import 'package:rakhsa/misc/helpers/storage.dart';

import 'package:rakhsa/repositories/user/model/profile.dart';

abstract class AuthRemoteDataSource {
  Future<ProfileModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  Dio client;

  AuthRemoteDataSourceImpl({required this.client});
  @override
  Future<ProfileModel> getProfile() async {
    try {
      final session = await StorageHelper.getUserSession();
      final response = await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile",
        data: {"user_id": session.user.id},
      );
      Map<String, dynamic> data = response.data;
      log("remote profile data = $data");
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
}
