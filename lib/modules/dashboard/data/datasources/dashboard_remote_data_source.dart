import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/misc/constants/remote_data_source_consts.dart';
import 'package:rakhsa/misc/client/errors/exception.dart';
import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/modules/dashboard/data/models/banner.dart';

import 'package:rakhsa/modules/dashboard/data/models/news.dart';
import 'package:rakhsa/modules/dashboard/data/models/news_detail.dart';

abstract class DashboardRemoteDataSource {
  Future<BannerModel> getBanner();
  Future<NewsModel> getNews({
    required double lat,
    required double lng,
    required String state,
  });
  Future<NewsDetailModel> getNewsDetail({required int id});
  Future<void> trackUser({
    required String address,
    required double lat,
    required double lng,
  });
  Future<void> updateAddress({
    required String address,
    required String state,
    required double lat,
    required double lng,
  });
  Future<void> expireSos({required String sosId});
  Future<void> ratingSos({required String sosId, required String rating});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  Dio client;

  DashboardRemoteDataSourceImpl({required this.client});

  @override
  Future<BannerModel> getBanner() async {
    try {
      final response = await client.get(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/banner",
      );
      Map<String, dynamic> data = response.data;
      BannerModel bannerModel = BannerModel.fromJson(data);
      return bannerModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<NewsModel> getNews({
    required double lat,
    required double lng,
    required String state,
  }) async {
    try {
      final response = await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/news/list-v2",
        data: {"lat": lat.toString(), "lng": lng.toString(), "state": state},
      );
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
  Future<NewsDetailModel> getNewsDetail({required int id}) async {
    try {
      final response = await client.get(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/news/$id",
      );
      Map<String, dynamic> data = response.data;
      NewsDetailModel newsDetailModel = NewsDetailModel.fromJson(data);
      return newsDetailModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> trackUser({
    required String address,
    required double lat,
    required double lng,
  }) async {
    try {
      final session = await StorageHelper.getUserSession();
      await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile/insert-user-track",
        data: {
          "user_id": session?.user.id,
          "address": address,
          "lat": lat,
          "lng": lng,
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
  Future<void> updateAddress({
    required String address,
    required String state,
    required double lat,
    required double lng,
  }) async {
    try {
      final session = await StorageHelper.getUserSession();
      await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/profile/address/update",
        data: {
          "user_id": session?.user.id,
          "address": address,
          "state": state,
          "lat": lat,
          "lng": lng,
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
  Future<void> expireSos({required String sosId}) async {
    try {
      await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/sos/expire",
        data: {"id": sosId},
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
  Future<void> ratingSos({
    required String sosId,
    required String rating,
  }) async {
    try {
      final session = await StorageHelper.getUserSession();
      await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/sos/rating",
        data: {"id": sosId, "user_id": session?.user.id, "rate": rating},
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
