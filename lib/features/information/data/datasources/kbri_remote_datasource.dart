import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/errors/exception.dart';

import 'package:rakhsa/features/information/data/models/kbri.dart';
import 'package:rakhsa/features/information/data/models/visa.dart';

abstract class KbriRemoteDataSource {
  Future<KbriInfoModel> infoKbri({required String stateId});
  Future<VisaContentModel> infoVisa({required String stateId});
}

class KbriRemoteDataSourceImpl implements KbriRemoteDataSource {
  Dio client;

  KbriRemoteDataSourceImpl({required this.client});

  @override 
  Future<KbriInfoModel> infoKbri({
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
  Future<VisaContentModel> infoVisa({
    required String stateId
  }) async {
    try {
      Response res = await client.get("${RemoteDataSourceConsts.baseUrlProd}/api/v1/information/info-visa/$stateId");
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


  

}