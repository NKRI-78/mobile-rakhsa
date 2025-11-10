import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:rakhsa/misc/helpers/vibration_manager.dart';
import 'package:rakhsa/repositories/sos/sos_coordinator.dart';
import 'package:rakhsa/modules/nearme/data/datasources/nearme_remote_data_source.dart';

import 'package:rakhsa/repositories/media/media_repository.dart';

import 'package:rakhsa/modules/auth/provider/auth_provider.dart' as ap;
import 'package:rakhsa/modules/administration/data/datasources/administration_remote_data_source.dart';
import 'package:rakhsa/modules/administration/presentation/provider/get_country_notifier.dart';
import 'package:rakhsa/modules/administration/presentation/provider/get_state_notifier.dart';
import 'package:rakhsa/modules/chat/data/datasources/chat_remote_data_source.dart';
import 'package:rakhsa/modules/chat/domain/usecases/detail_inbox.dart';
import 'package:rakhsa/modules/chat/domain/usecases/get_inbox.dart';
import 'package:rakhsa/modules/chat/domain/usecases/insert_message.dart';
import 'package:rakhsa/modules/chat/presentation/provider/detail_inbox_notifier.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_inbox_notifier.dart';
import 'package:rakhsa/modules/chat/presentation/provider/insert_message_notifier.dart';
import 'package:rakhsa/modules/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:rakhsa/modules/dashboard/domain/usecases/detail_news.dart';
import 'package:rakhsa/modules/dashboard/domain/usecases/get_banner.dart';
import 'package:rakhsa/modules/dashboard/domain/usecases/sos_rating.dart';
import 'package:rakhsa/modules/dashboard/domain/usecases/track_user.dart';
import 'package:rakhsa/modules/dashboard/domain/usecases/update_address.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/detail_news_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/sos_rating_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/track_user_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/weather_notifier.dart';
import 'package:rakhsa/modules/administration/domain/usecases/get_country.dart';
import 'package:rakhsa/modules/administration/domain/usecases/get_state.dart';
import 'package:rakhsa/modules/information/data/datasources/kbri_remote_datasource.dart';
import 'package:rakhsa/modules/information/data/repositories/information_remote_datasource_impl.dart';
import 'package:rakhsa/modules/information/domain/repository/kbri_repository.dart';
import 'package:rakhsa/modules/information/domain/usecases/get_kbri_id.dart';
import 'package:rakhsa/modules/information/domain/usecases/get_kbri_name.dart';
import 'package:rakhsa/modules/information/domain/usecases/get_passport.dart';
import 'package:rakhsa/modules/information/domain/usecases/get_visa.dart';
import 'package:rakhsa/modules/information/presentation/provider/kbri_id_notifier.dart';
import 'package:rakhsa/modules/information/presentation/provider/kbri_name_notifier.dart';
import 'package:rakhsa/modules/information/presentation/provider/passport_notifier.dart';
import 'package:rakhsa/modules/information/presentation/provider/visa_notifier.dart';
import 'package:rakhsa/modules/media/data/datasources/media_remote_datasource.dart';

import 'package:rakhsa/modules/administration/domain/usecases/get_continent.dart';
import 'package:rakhsa/modules/dashboard/domain/usecases/get_news.dart';
import 'package:rakhsa/modules/chat/domain/usecases/get_chats.dart';
import 'package:rakhsa/modules/chat/domain/usecases/get_messages.dart';
import 'package:rakhsa/modules/media/domain/usecases/upload_media.dart';

import 'package:rakhsa/modules/administration/domain/repository/administration_repository.dart';
import 'package:rakhsa/modules/dashboard/domain/repository/dashboard_repository.dart';
import 'package:rakhsa/modules/media/domain/repository/media_repository.dart';

import 'package:rakhsa/modules/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:rakhsa/modules/administration/data/repositories/administration_repository_impl.dart';
import 'package:rakhsa/modules/chat/data/repositories/chat_repository_impl.dart';
import 'package:rakhsa/modules/media/data/repositories/media_repository_impl.dart';

import 'package:rakhsa/modules/administration/presentation/provider/get_continent_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/media/presentation/provider/upload_media_notifier.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_chats_notifier.dart';

import 'package:rakhsa/modules/chat/domain/repository/chat_repository.dart';
import 'package:rakhsa/modules/nearme/data/repositories/nearme_repository_impl.dart';
import 'package:rakhsa/modules/nearme/domain/repository/nearme_repository.dart';
import 'package:rakhsa/modules/nearme/domain/usecases/get_place_nearby.dart';
import 'package:rakhsa/modules/nearme/presentation/provider/nearme_notifier.dart';
import 'package:rakhsa/firebase.dart';
import 'package:rakhsa/misc/client/dio_client.dart';
import 'package:rakhsa/repositories/auth/auth_repository.dart';
import 'package:rakhsa/repositories/user/user_repository.dart';
import 'package:rakhsa/socketio.dart';
import 'package:weather/weather.dart';

final locator = GetIt.instance;

void init() {
  locator.registerLazySingleton(() => SocketIoService());
  locator.registerLazySingleton(() => DeviceInfoPlugin());
  locator.registerLazySingleton(() => FirebaseAuth.instance);

  locator.registerLazySingleton(() => Dio());
  locator.registerLazySingleton(() => Connectivity());
  locator.registerLazySingleton(() => DioClient(locator<Connectivity>()));
  locator.registerLazySingleton(() => VibrationManager());
  locator.registerLazySingleton(() => SosCoordinator());
  locator.registerLazySingleton(
    () => AuthRepository(client: locator<DioClient>()),
  );
  locator.registerLazySingleton(
    () => ap.AuthProvider(repository: locator<AuthRepository>()),
  );
  locator.registerLazySingleton(
    () => UserRepository(client: locator<DioClient>()),
  );

  // REMOTE DATA SOURCE
  locator.registerLazySingleton<NearmeRemoteDataSource>(
    () => NearmeRemoteDataSourceImpl(client: locator()),
  );
  locator.registerLazySingleton<AdministrationRemoteDataSource>(
    () => AdministrationRemoteDataSourceImpl(client: locator()),
  );
  locator.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(client: locator()),
  );
  locator.registerLazySingleton<KbriRemoteDataSource>(
    () => KbriRemoteDataSourceImpl(client: locator()),
  );
  locator.registerLazySingleton<MediaRemoteDatasource>(
    () => MediaRemoteDataSourceImpl(client: locator()),
  );
  locator.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(client: locator()),
  );

  // REPOSITORY
  locator.registerLazySingleton<AdministrationRepository>(
    () => AdministrationRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerLazySingleton<KbriRepository>(
    () => KbriRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerLazySingleton<MediaRepository>(
    () => MediaRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerLazySingleton<NearmeRepository>(
    () => NearmeRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerLazySingleton<MediaRepo>(() => MediaRepo(dio: locator()));

  // USE CASE
  locator.registerLazySingleton(() => GetNewsUseCase(locator()));
  locator.registerLazySingleton(() => GetPlaceNearbyUseCase(locator()));
  locator.registerLazySingleton(() => SosRatingUseCase(locator()));
  locator.registerLazySingleton(() => GetBannerUseCase(locator()));
  locator.registerLazySingleton(() => DetailNewsUseCase(locator()));
  locator.registerLazySingleton(() => UploadMediaUseCase(locator()));
  locator.registerLazySingleton(() => UpdateAddressUseCase(locator()));
  locator.registerLazySingleton(() => GetCountryUseCase(locator()));
  locator.registerLazySingleton(() => GetVisaUseCase(locator()));
  locator.registerLazySingleton(() => GetKbriIdUseCase(locator()));
  locator.registerLazySingleton(() => TrackUserUseCase(locator()));
  locator.registerLazySingleton(() => GetKbriNameUseCase(locator()));
  locator.registerLazySingleton(() => GetPassportUseCase(locator()));
  locator.registerLazySingleton(() => GetChatsUseCase(locator()));
  locator.registerLazySingleton(() => GetMessagesUseCase(locator()));
  locator.registerLazySingleton(() => GetContinentUseCase(locator()));
  locator.registerLazySingleton(() => GetStateUseCase(locator()));
  locator.registerLazySingleton(() => InsertMessageUseCase(locator()));
  locator.registerLazySingleton(() => GetInboxUseCase(locator()));
  locator.registerLazySingleton(() => DetailInboxUseCase(locator()));

  // NOT AFFECTED IN WEBSOCKET IF USE ONLY REGISTER FACTORY
  // NOTIFIER
  locator.registerLazySingleton(
    () => DashboardNotifier(
      profileNotifier: locator(),
      bannerUseCase: locator(),
      useCase: locator(),
    ),
  );
  locator.registerFactory(
    () => UserProvider(repository: locator<UserRepository>()),
  );
  locator.registerFactory(() => SosRatingNotifier(useCase: locator()));
  locator.registerFactory(() => VisaNotifier(useCase: locator()));
  locator.registerFactory(() => PassportNotifier(useCase: locator()));
  locator.registerFactory(() => KbriIdNotifier(useCase: locator()));
  locator.registerFactory(() => KbriNameNotifier(useCase: locator()));
  locator.registerFactory(() => UploadMediaNotifier(useCase: locator()));
  locator.registerFactory(() => UpdateAddressNotifier(useCase: locator()));
  locator.registerFactory(() => GetCountryNotifier(useCase: locator()));
  locator.registerFactory(() => GetStateNotifier(useCase: locator()));
  locator.registerFactory(() => GetChatsNotifier(useCase: locator()));
  locator.registerFactory(() => GetMessagesNotifier(useCase: locator()));
  locator.registerFactory(() => GetContinentNotifier(useCase: locator()));
  locator.registerFactory(() => InsertMessageNotifier(useCase: locator()));
  locator.registerFactory(() => DetailNewsNotifier(useCase: locator()));
  locator.registerFactory(() => TrackUserNotifier(useCase: locator()));
  locator.registerFactory(() => GetNearbyPlacenNotifier(useCase: locator()));
  locator.registerFactory(() => DetailInboxNotifier(useCase: locator()));
  locator.registerFactory(() => GetInboxNotifier(useCase: locator()));

  locator.registerFactory(() => WeatherNotifier(weather: locator()));

  locator.registerFactory(() => FirebaseProvider(dio: locator()));

  locator.registerLazySingleton(
    () => WeatherFactory(
      '067cd306a519e9153f2ae44e71c8b4f3',
      language: Language.INDONESIAN,
    ),
  );
}
