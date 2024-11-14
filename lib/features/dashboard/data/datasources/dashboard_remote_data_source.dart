import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/errors/exception.dart';

import 'package:rakhsa/features/dashboard/data/models/news.dart';

abstract class DashboardRemoteDataSource {
  Future<NewsModel> getNews();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {

  Dio client;

  DashboardRemoteDataSourceImpl({required this.client});

  @override
  Future<NewsModel> getNews() async {
    try { 
      final response = await client.get("${RemoteDataSourceConsts.baseUrlProd}/api/v1/news");
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


}