import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/errors/exception.dart';

import 'package:rakhsa/features/event/data/models/list.dart';

abstract class EventRemoteDataSource {
  Future<EventModel> list();
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {

  Dio client;

  EventRemoteDataSourceImpl({required this.client});

  @override 
  Future<EventModel> list() async {
    try {
      final response = await client.get("${RemoteDataSourceConsts.baseUrlProd}/api/v1/event");
      Map<String, dynamic> data = response.data;
      EventModel itineraryModel = EventModel.fromJson(data);
      return itineraryModel;
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    } 
  }

}