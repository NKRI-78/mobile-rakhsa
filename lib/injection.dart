import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:rakhsa/common/helpers/dio.dart';

import 'package:rakhsa/features/administration/data/datasources/administration_remote_data_source.dart';
import 'package:rakhsa/features/administration/domain/usecases/get_state.dart';
import 'package:rakhsa/features/administration/presentation/provider/get_state_notifier.dart';
import 'package:rakhsa/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rakhsa/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:rakhsa/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:rakhsa/features/event/data/datasources/event_remote_datasource.dart';
import 'package:rakhsa/features/event/domain/usecases/save_event.dart';
import 'package:rakhsa/features/event/persentation/provider/save_event_notifier.dart';
import 'package:rakhsa/features/media/data/datasources/media_remote_datasource.dart';
import 'package:rakhsa/features/event/data/repositories/event_remote_datasource_impl.dart';

import 'package:rakhsa/features/administration/domain/usecases/get_continent.dart';
import 'package:rakhsa/features/auth/domain/usecases/register.dart';
import 'package:rakhsa/features/auth/domain/usecases/resendOtp.dart';
import 'package:rakhsa/features/auth/domain/usecases/verifyOtp.dart';
import 'package:rakhsa/features/event/domain/usecases/list_event.dart';
import 'package:rakhsa/features/dashboard/domain/usecases/expire_sos.dart';
import 'package:rakhsa/features/dashboard/domain/usecases/get_news.dart';
import 'package:rakhsa/features/auth/domain/usecases/login.dart';
import 'package:rakhsa/features/auth/domain/usecases/profile.dart';
import 'package:rakhsa/features/chat/domain/usecases/get_chats.dart';
import 'package:rakhsa/features/chat/domain/usecases/get_messages.dart';
import 'package:rakhsa/features/media/domain/usecases/upload_media.dart';

import 'package:rakhsa/features/administration/domain/repository/administration_repository.dart';
import 'package:rakhsa/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:rakhsa/features/event/domain/repository/event_repository.dart';
import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';
import 'package:rakhsa/features/media/domain/repository/media_repository.dart';

import 'package:rakhsa/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:rakhsa/features/administration/data/repositories/administration_repository_impl.dart';
import 'package:rakhsa/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rakhsa/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:rakhsa/features/media/data/repositories/media_repository_impl.dart';

import 'package:rakhsa/features/administration/presentation/provider/get_continent_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/list_event_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/register_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/resend_otp_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/verify_otp_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/login_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/media/presentation/provider/upload_media_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_chats_notifier.dart';

import 'package:rakhsa/features/chat/domain/repository/chat_repository.dart';

import 'package:rakhsa/websockets.dart';

final locator = GetIt.instance;

void init() {

  // REMOTE DATA SOURCE 
  locator.registerLazySingleton<AdministrationRemoteDataSource>(() => AdministrationRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<DashboardRemoteDataSource>(() => DashboardRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<MediaRemoteDatasource>(() => MediaRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<EventRemoteDataSource>(() => EventRemoteDataSourceImpl(client: locator()));
  
  // REPOSITORY 
  locator.registerLazySingleton<AdministrationRepository>(() => AdministrationRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<MediaRepository>(() => MediaRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<EventRepository>(() => EventRepositoryImpl(remoteDataSource: locator()));

  // USE CASE
  locator.registerLazySingleton(() => GetNewsUseCase(locator()));
  locator.registerLazySingleton(() => ProfileUseCase(locator()));
  locator.registerLazySingleton(() => ExpireSosUseCase(locator()));
  locator.registerLazySingleton(() => LoginUseCase(locator()));
  locator.registerLazySingleton(() => ListEventUseCase(locator()));
  locator.registerLazySingleton(() => SaveEventUseCase(locator()));
  locator.registerLazySingleton(() => RegisterUseCase(locator()));
  locator.registerLazySingleton(() => VerifyOtpUseCase(locator()));
  locator.registerLazySingleton(() => ResendOtpUseCase(locator()));
  locator.registerLazySingleton(() => UploadMediaUseCase(locator()));
  locator.registerLazySingleton(() => GetChatsUseCase(locator()));
  locator.registerLazySingleton(() => GetMessagesUseCase(locator()));
  locator.registerLazySingleton(() => GetContinentUseCase(locator()));
  locator.registerLazySingleton(() => GetStateUseCase(locator()));

  // NOT AFFECTED IN WEBSOCKET IF USE ONLY REGISTER FACTORY
  // NOTIFIER 
  locator.registerLazySingleton(() => DashboardNotifier(
    profileNotifier: locator(),
    useCase: locator()
  ));
  locator.registerLazySingleton(() => ProfileNotifier(useCase: locator()));
  locator.registerLazySingleton(() => SosNotifier(useCase: locator()));
  locator.registerLazySingleton(() => ListEventNotifier(useCase: locator()));
  locator.registerLazySingleton(() => SaveEventNotifier(useCase: locator()));
  locator.registerLazySingleton(() => LoginNotifier(useCase: locator()));
  locator.registerLazySingleton(() => RegisterNotifier(useCase: locator()));
  locator.registerLazySingleton(() => VerifyOtpNotifier(useCase: locator()));
  locator.registerLazySingleton(() => ResendOtpNotifier(useCase: locator()));
  locator.registerLazySingleton(() => UploadMediaNotifier(useCase: locator()));
  locator.registerLazySingleton(() => GetStateNotifier(useCase: locator()));
  locator.registerLazySingleton(() => GetChatsNotifier(useCase: locator()));
  locator.registerLazySingleton(() => GetMessagesNotifier(useCase: locator()));
  locator.registerLazySingleton(() => GetContinentNotifier(useCase: locator()));
  
  locator.registerFactory(() => WebSocketsService(
    chatsNotifier: locator(),
    messageNotifier: locator(),
    sosNotifier: locator()
  ));

  DioHelper dio = DioHelper();
  Dio getDio = dio.getClient();

  locator.registerLazySingleton(() => getDio);
}