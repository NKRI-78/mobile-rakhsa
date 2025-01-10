import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/errors/exception.dart';

import 'package:rakhsa/features/information/data/models/kbri.dart';
import 'package:rakhsa/features/information/data/models/passport.dart';
import 'package:rakhsa/features/information/data/models/visa.dart';

abstract class KbriRemoteDataSource {
  Future<KbriInfoModel> infoKbriStateId({required String stateId});
  Future<KbriInfoModel> infoKbriStateName({required String stateName});
  Future<VisaContentModel> infoVisa({required String stateId});
  Future<PassportContentModel> infoPassport({required String stateId});
}

class KbriRemoteDataSourceImpl implements KbriRemoteDataSource {
  Dio client;

  KbriRemoteDataSourceImpl({required this.client});

  @override 
  Future<KbriInfoModel> infoKbriStateId({
    required String stateId
  }) async {
    try {
      Response res = await client.get("${RemoteDataSourceConsts.baseUrlProd}/api/v1/information/info-kbri-state/$stateId");
      Map<String, dynamic> data = res.data;
      KbriInfoModel kbriInfoModel = KbriInfoModel.fromJson(data);
      return kbriInfoModel;
    } on DioException catch(e) {
      debugPrint(e.response.toString());
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override 
  Future<KbriInfoModel> infoKbriStateName({
    required String stateName
  }) async {  
    try {
      Response res = await client.get("${RemoteDataSourceConsts.baseUrlProd}/api/v1/information/info-kbri-state-name/$stateName");
      Map<String, dynamic> data = res.data;
      KbriInfoModel kbriInfoModel = KbriInfoModel.fromJson(data);
      return kbriInfoModel;
    } on DioException catch(e) {
      debugPrint(e.response.toString());
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  } 
  
  @override
  Future<VisaContentModel> infoVisa({
    required String stateId
  }) async {
    try {
      Response res = await client.get("${RemoteDataSourceConsts.baseUrlProd}/api/v1/information/info-visa?state_id=$stateId");
      Map<String, dynamic> data = res.data;
      VisaContentModel visaContentModel = VisaContentModel.fromJson(data);
      return visaContentModel;
    } on DioException catch(e) {
      debugPrint(e.response.toString());
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<PassportContentModel> infoPassport({
    required String stateId
  }) async {
    try {
      Response res = await client.get("${RemoteDataSourceConsts.baseUrlProd}/api/v1/information/info-passport?state_id=$stateId");
      Map<String, dynamic> data = res.data;
      PassportContentModel passportContentModel = PassportContentModel.fromJson(data);
      return passportContentModel;
    } on DioException catch(e) {
      debugPrint(e.response.toString());
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }


}