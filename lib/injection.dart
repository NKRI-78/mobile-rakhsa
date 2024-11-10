import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:rakhsa/common/helpers/dio.dart';

import 'package:rakhsa/websockets.dart';

final locator = GetIt.instance;

void init() {

  // REMOTE DATA SOURCE 

  // REPOSITORY 

  // USE CASE

  // NOTIFIER

  // NOT AFFECTED IN WEBSOCKET IF USE ONLY REGISTER FACTORY

  locator.registerFactory(() => WebSocketsService());

  DioHelper dio = DioHelper();
  Dio getDio = dio.getClient();

  locator.registerLazySingleton(() => getDio);
}