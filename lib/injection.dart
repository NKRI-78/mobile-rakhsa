import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:rakhsa/common/helpers/dio.dart';

import 'package:rakhsa/features/pages/chat/data/datasources/chat_remote_data_source.dart';
import 'package:rakhsa/features/pages/chat/data/repositories/chat_repository_impl.dart';
import 'package:rakhsa/features/pages/chat/domain/repositories/chat_repository.dart';
import 'package:rakhsa/features/pages/chat/domain/usecases/get_messages.dart';
import 'package:rakhsa/features/pages/chat/presentation/provider/get_messages_notifier.dart';

import 'package:rakhsa/websockets.dart';

final locator = GetIt.instance;

void init() {

  // REMOTE DATA SOURCE 
  locator.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(client: locator()));
  
  // REPOSITORY 
  locator.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(remoteDataSource: locator()));

  // USE CASE
  locator.registerLazySingleton(() => GetMessagesUseCase(locator()));
  
  // NOTIFIER
  locator.registerLazySingleton(() => GetMessagesNotifier(getMessagesUseCase: locator()));

  // NOT AFFECTED IN WEBSOCKET IF USE ONLY REGISTER FACTORY

  locator.registerFactory(() => WebSocketsService());

  DioHelper dio = DioHelper();
  Dio getDio = dio.getClient();

  locator.registerLazySingleton(() => getDio);
}