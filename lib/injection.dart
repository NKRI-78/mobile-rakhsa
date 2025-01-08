import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:rakhsa/common/helpers/dio.dart';

import 'package:rakhsa/features/administration/data/datasources/administration_remote_data_source.dart';
import 'package:rakhsa/features/administration/presentation/provider/get_country_notifier.dart';
import 'package:rakhsa/features/administration/presentation/provider/get_state_notifier.dart';
import 'package:rakhsa/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rakhsa/features/auth/domain/usecases/forgot_password.dart';
import 'package:rakhsa/features/auth/domain/usecases/update_is_loggedin.dart';
import 'package:rakhsa/features/auth/domain/usecases/update_profile.dart';
import 'package:rakhsa/features/auth/presentation/provider/forgot_password_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/update_is_loggedin_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/update_profile_notifier.dart';
import 'package:rakhsa/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:rakhsa/features/chat/domain/usecases/insert_message.dart';
import 'package:rakhsa/features/chat/presentation/provider/insert_message_notifier.dart';
import 'package:rakhsa/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:rakhsa/features/dashboard/domain/usecases/detail_news.dart';
import 'package:rakhsa/features/dashboard/domain/usecases/sos_rating.dart';
import 'package:rakhsa/features/dashboard/domain/usecases/update_address.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/detail_news_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/sos_rating_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/features/event/data/datasources/event_remote_datasource.dart';
import 'package:rakhsa/features/event/domain/usecases/delete_event.dart';
import 'package:rakhsa/features/event/domain/usecases/detail_event.dart';
import 'package:rakhsa/features/administration/domain/usecases/get_country.dart';
import 'package:rakhsa/features/administration/domain/usecases/get_state.dart';
import 'package:rakhsa/features/event/domain/usecases/save_event.dart';
import 'package:rakhsa/features/event/domain/usecases/update_event.dart';
import 'package:rakhsa/features/event/persentation/provider/delete_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/detail_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/save_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/update_event_notifier.dart';
import 'package:rakhsa/features/information/data/datasources/kbri_remote_datasource.dart';
import 'package:rakhsa/features/information/data/repositories/information_remote_datasource_impl.dart';
import 'package:rakhsa/features/information/domain/repository/kbri_repository.dart';
import 'package:rakhsa/features/information/domain/usecases/get_kbri.dart';
import 'package:rakhsa/features/information/domain/usecases/get_passport.dart';
import 'package:rakhsa/features/information/domain/usecases/get_visa.dart';
import 'package:rakhsa/features/information/presentation/provider/kbri_notifier.dart';
import 'package:rakhsa/features/information/presentation/provider/passport_notifier.dart';
import 'package:rakhsa/features/information/presentation/provider/visa_notifier.dart';
import 'package:rakhsa/features/media/data/datasources/media_remote_datasource.dart';
import 'package:rakhsa/features/event/data/repositories/event_remote_datasource_impl.dart';

import 'package:rakhsa/features/administration/domain/usecases/get_continent.dart';
import 'package:rakhsa/features/auth/domain/usecases/register.dart';
import 'package:rakhsa/features/auth/domain/usecases/resend_otp.dart';
import 'package:rakhsa/features/auth/domain/usecases/verify_otp.dart';
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
import 'package:rakhsa/firebase.dart';

import 'package:rakhsa/websockets.dart';

final locator = GetIt.instance;

void init() {

  // REMOTE DATA SOURCE 
  locator.registerLazySingleton<AdministrationRemoteDataSource>(() => AdministrationRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<DashboardRemoteDataSource>(() => DashboardRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<KbriRemoteDataSource>(() => KbriRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<MediaRemoteDatasource>(() => MediaRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<EventRemoteDataSource>(() => EventRemoteDataSourceImpl(client: locator()));
  
  // REPOSITORY 
  locator.registerLazySingleton<AdministrationRepository>(() => AdministrationRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<KbriRepository>(() => KbriRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<MediaRepository>(() => MediaRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<EventRepository>(() => EventRepositoryImpl(remoteDataSource: locator()));

  // USE CASE
  locator.registerLazySingleton(() => GetNewsUseCase(locator()));
  locator.registerLazySingleton(() => ProfileUseCase(locator()));
  locator.registerLazySingleton(() => ExpireSosUseCase(locator()));
  locator.registerLazySingleton(() => SosRatingUseCase(locator()));
  locator.registerLazySingleton(() => SaveEventUseCase(locator()));
  locator.registerLazySingleton(() => LoginUseCase(locator()));
  locator.registerLazySingleton(() => ListEventUseCase(locator()));
  locator.registerLazySingleton(() => DetailEventUseCase(locator()));
  locator.registerLazySingleton(() => DetailNewsUseCase(locator()));
  locator.registerLazySingleton(() => DeleteEventUseCase(locator()));
  locator.registerLazySingleton(() => UpdateEventUseCase(locator()));
  locator.registerLazySingleton(() => RegisterUseCase(locator()));
  locator.registerLazySingleton(() => ResendOtpUseCase(locator()));
  locator.registerLazySingleton(() => VerifyOtpUseCase(locator()));
  locator.registerLazySingleton(() => UpdateProfileUseCase(locator()));
  locator.registerLazySingleton(() => UploadMediaUseCase(locator()));
  locator.registerLazySingleton(() => UpdateAddressUseCase(locator()));
  locator.registerLazySingleton(() => UpdateIsLoggedinUseCase(locator()));
  locator.registerLazySingleton(() => GetCountryUseCase(locator()));
  locator.registerLazySingleton(() => GetVisaUseCase(locator()));
  locator.registerLazySingleton(() => GetKbriUseCase(locator()));
  locator.registerLazySingleton(() => GetPassportUseCase(locator()));
  locator.registerLazySingleton(() => GetChatsUseCase(locator()));
  locator.registerLazySingleton(() => GetMessagesUseCase(locator()));
  locator.registerLazySingleton(() => GetContinentUseCase(locator()));
  locator.registerLazySingleton(() => GetStateUseCase(locator()));
  locator.registerLazySingleton(() => InsertMessageUseCase(locator()));
  locator.registerLazySingleton(() => ForgotPasswordUseCase(locator()));

  // NOT AFFECTED IN WEBSOCKET IF USE ONLY REGISTER FACTORY
  // NOTIFIER 
  locator.registerLazySingleton(() => DashboardNotifier(
    profileNotifier: locator(),
    useCase: locator()
  ));
  locator.registerFactory(() => ProfileNotifier(useCase: locator()));
  locator.registerFactory(() => UpdateProfileNotifier(useCase: locator()));
  locator.registerFactory(() => SosNotifier(useCase: locator()));
  locator.registerFactory(() => SosRatingNotifier(useCase: locator()));
  locator.registerFactory(() => ListEventNotifier(useCase: locator()));
  locator.registerFactory(() => SaveEventNotifier(useCase: locator()));
  locator.registerFactory(() => UpdateEventNotifier(useCase: locator()));
  locator.registerFactory(() => DetailEventNotifier(useCase: locator()));
  locator.registerFactory(() => DeleteEventNotifier(useCase: locator()));
  locator.registerLazySingleton(() => LoginNotifier(
    webSocketsService: locator(),
    useCase: locator()
  ));
  locator.registerFactory(() => VisaNotifier(useCase: locator()));
  locator.registerFactory(() => PassportNotifier(useCase: locator()));
  locator.registerLazySingleton(() => RegisterNotifier(
    webSocketsService: locator(),
    useCase: locator(),
  ));
  locator.registerFactory(() => KbriNotifier(useCase: locator()));
  locator.registerFactory(() => VerifyOtpNotifier(useCase: locator()));
  locator.registerFactory(() => ResendOtpNotifier(useCase: locator()));
  locator.registerFactory(() => UploadMediaNotifier(useCase: locator()));
  locator.registerFactory(() => UpdateAddressNotifier(useCase: locator()));
  locator.registerFactory(() => UpdateIsLoggedinNotifier(useCase: locator()));
  locator.registerFactory(() => GetCountryNotifier(useCase: locator()));
  locator.registerFactory(() => GetStateNotifier(useCase: locator()));
  locator.registerFactory(() => GetChatsNotifier(useCase: locator()));
  locator.registerFactory(() => GetMessagesNotifier(useCase: locator()));
  locator.registerFactory(() => GetContinentNotifier(useCase: locator()));
  locator.registerFactory(() => InsertMessageNotifier(useCase: locator()));
  locator.registerFactory(() => ForgotPasswordNotifier(useCase: locator()));
  locator.registerFactory(() => DetailNewsNotifier(useCase: locator()));

  locator.registerFactory(() => FirebaseProvider(
    dio: locator()
  ));
  
  locator.registerFactory(() => WebSocketsService());

  DioHelper dio = DioHelper();
  Dio getDio = dio.getClient();

  locator.registerLazySingleton(() => getDio);
}