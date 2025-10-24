import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/misc/constants/remote_data_source_consts.dart';

import 'package:rakhsa/misc/client/errors/exception.dart';

import 'package:rakhsa/features/nearme/data/models/nearme.dart';

abstract class NearmeRemoteDataSource {
  Future<NearbyplaceModel> getNearme({
    required double currentLat,
    required double currentLng,
    required String type,
  });
}

class NearmeRemoteDataSourceImpl implements NearmeRemoteDataSource {
  Dio client;

  NearmeRemoteDataSourceImpl({required this.client});

  @override
  Future<NearbyplaceModel> getNearme({
    required double currentLat,
    required double currentLng,
    required String type,
  }) async {
    try {
      final response = await client.get(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$currentLat,$currentLng&types=$type&radius=3000&key=${RemoteDataSourceConsts.gmaps}",
      );
      Map<String, dynamic> data = response.data;
      NearbyplaceModel nearby = NearbyplaceModel.fromJson(data);
      return nearby;
    } on DioException catch (e) {
      debugPrint(e.response.toString());
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }
}
