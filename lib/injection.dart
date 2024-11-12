import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:rakhsa/common/helpers/dio.dart';
import 'package:rakhsa/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rakhsa/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';

import 'package:rakhsa/features/chat/domain/repositories/chat_repository.dart';

import 'package:rakhsa/features/auth/domain/usecases/login.dart';
import 'package:rakhsa/features/chat/domain/usecases/get_messages.dart';

import 'package:rakhsa/features/chat/data/repositories/chat_repository_impl.dart';

import 'package:rakhsa/features/chat/data/datasources/chat_remote_data_source.dart';

import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';

import 'package:rakhsa/websockets.dart';

final locator = GetIt.instance;

void init() {

  // REMOTE DATA SOURCE 
  locator.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(client: locator()));
  
  // REPOSITORY 
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(remoteDataSource: locator()));

  // USE CASE
  locator.registerLazySingleton(() => LoginUseCase(locator()));
  locator.registerLazySingleton(() => GetMessagesUseCase(locator()));
  
  // NOT AFFECTED IN WEBSOCKET IF USE ONLY REGISTER FACTORY
  // NOTIFIER 
  locator.registerLazySingleton(() => GetMessagesNotifier(getMessagesUseCase: locator()));
  
  locator.registerFactory(() => WebSocketsService(
    messageNotifier: locator()
  ));

  DioHelper dio = DioHelper();
  Dio getDio = dio.getClient();

  locator.registerLazySingleton(() => getDio);
}