import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/errors/exception.dart';

import 'package:rakhsa/features/dashboard/data/models/news.dart';

abstract class DashboardRemoteDataSource {
  Future<NewsModel> getNews();
  Future<void> expireSos({required String sosId});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {

  Dio client;

  DashboardRemoteDataSourceImpl({required this.client});

  @override
  Future<NewsModel> getNews() async {
    try { 
      final response = await client.get("${RemoteDataSourceConsts.baseUrlProd}/api/v1/news?type=ews");
      Map<String, dynamic> data = response.data;
      NewsModel newsModel = NewsModel.fromJson(data);
      return newsModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override 
  Future<void> expireSos({required String sosId}) async {
    try {
      await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/sos/expire",
        data: {
          "id": sosId
        }
      );
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }


}