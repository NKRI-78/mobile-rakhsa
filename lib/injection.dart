import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:rakhsa/common/helpers/dio.dart';

import 'package:rakhsa/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rakhsa/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:rakhsa/features/auth/domain/usecases/login.dart';
import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';
import 'package:rakhsa/features/auth/presentation/provider/login_notifier.dart';

import 'package:rakhsa/features/chat/domain/repositories/chat_repository.dart';
import 'package:rakhsa/features/chat/domain/usecases/get_chats.dart';
import 'package:rakhsa/features/chat/domain/usecases/get_messages.dart';

import 'package:rakhsa/features/chat/data/repositories/chat_repository_impl.dart';

import 'package:rakhsa/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_chats_notifier.dart';
import 'package:rakhsa/features/media/data/datasources/media_remote_datasource.dart';

import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/media/data/repositories/media_repository_impl.dart';
import 'package:rakhsa/features/media/domain/repositories/media_repository.dart';
import 'package:rakhsa/features/media/domain/usecases/upload_media.dart';
import 'package:rakhsa/features/media/presentation/providers/upload_media_notifier.dart';

import 'package:rakhsa/websockets.dart';

final locator = GetIt.instance;

void init() {

  // REMOTE DATA SOURCE 
  locator.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<MediaRemoteDatasource>(() => MediaRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(client: locator()));
  
  // REPOSITORY 
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<MediaRepository>(() => MediaRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(remoteDataSource: locator()));

  // USE CASE
  locator.registerLazySingleton(() => LoginUseCase(locator()));
  locator.registerLazySingleton(() => UploadMediaUseCase(locator()));
  locator.registerLazySingleton(() => GetChatsUseCase(locator()));
  locator.registerLazySingleton(() => GetMessagesUseCase(locator()));
  
  // NOT AFFECTED IN WEBSOCKET IF USE ONLY REGISTER FACTORY
  // NOTIFIER 
  locator.registerLazySingleton(() => LoginNotifier(useCase: locator()));
  locator.registerLazySingleton(() => UploadMediaNotifier(useCase: locator()));
  locator.registerLazySingleton(() => GetChatsNotifier(useCase: locator()));
  locator.registerLazySingleton(() => GetMessagesNotifier(useCase: locator()));
  
  locator.registerFactory(() => WebSocketsService(
    messageNotifier: locator()
  ));

  DioHelper dio = DioHelper();
  Dio getDio = dio.getClient();

  locator.registerLazySingleton(() => getDio);
}