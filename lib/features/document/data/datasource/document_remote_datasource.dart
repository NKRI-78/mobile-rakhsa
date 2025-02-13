import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:rakhsa/common/constants/remote_data_source_consts.dart';

abstract interface class DocumentRemoteDatasource {
  Future<void> updateVisa({required String path, required String userId});
  Future<void> deleteVisa({required String userId});
  Future<void> updatePassport({required String path, required String userId});
}

class DocumentRemoteDatasourceImpl implements DocumentRemoteDatasource {
  final Dio client;

  DocumentRemoteDatasourceImpl({required this.client});

  @override
  Future<void> updateVisa({
    required String path,
    required String userId,
  }) async {
    try {
      await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile/update-visa",
        data: {'user_id': userId, 'path': path},
      );
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
    }
  }

  @override
  Future<void> updatePassport({
    required String path,
    required String userId,
  }) async {
    try {
      await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile/update-passport",
        data: {'user_id': userId, 'passport_pic': path},
      );
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
    }
  }
  
  @override
  Future<void> deleteVisa({required String userId}) async {
    try {
      await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile/delete-visa-passport",
        data: {'user_id': userId, 'type': 'visa'},
      );
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
    }
  }
}