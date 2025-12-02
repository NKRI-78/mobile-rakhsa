import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:rakhsa/modules/referral/provider/referral_provider.dart';
import 'package:rakhsa/modules/information/presentation/provider/information_provider.dart';
import 'package:rakhsa/modules/sos/provider/sos_provider.dart';
import 'package:rakhsa/repositories/information/information_repository.dart';
import 'package:rakhsa/repositories/referral/referral_repository.dart';
import 'package:rakhsa/service/sos/sos_coordinator.dart';
import 'package:rakhsa/modules/nearme/data/datasources/nearme_remote_data_source.dart';

import 'package:rakhsa/repositories/media/media_repository.dart';

import 'package:rakhsa/modules/auth/provider/auth_provider.dart' as ap;
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

import 'package:rakhsa/modules/dashboard/domain/usecases/get_news.dart';
import 'package:rakhsa/modules/chat/domain/usecases/get_chats.dart';
import 'package:rakhsa/modules/chat/domain/usecases/get_messages.dart';

import 'package:rakhsa/modules/dashboard/domain/repository/dashboard_repository.dart';

import 'package:rakhsa/modules/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:rakhsa/modules/chat/data/repositories/chat_repository_impl.dart';

import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_chats_notifier.dart';

import 'package:rakhsa/modules/chat/domain/repository/chat_repository.dart';
import 'package:rakhsa/modules/nearme/data/repositories/nearme_repository_impl.dart';
import 'package:rakhsa/modules/nearme/domain/repository/nearme_repository.dart';
import 'package:rakhsa/modules/nearme/domain/usecases/get_place_nearby.dart';
import 'package:rakhsa/modules/nearme/presentation/provider/nearme_notifier.dart';
import 'package:rakhsa/misc/client/dio_client.dart';
import 'package:rakhsa/repositories/auth/auth_repository.dart';
import 'package:rakhsa/repositories/user/user_repository.dart';
import 'package:rakhsa/service/socket/socketio.dart';

final locator = GetIt.instance;

void init() {
  locator.registerLazySingleton(() => SocketIoService());
  locator.registerLazySingleton(() => DeviceInfoPlugin());
  locator.registerLazySingleton(() => FirebaseAuth.instance);

  locator.registerLazySingleton(() => Dio());
  locator.registerLazySingleton(() => Connectivity());
  locator.registerLazySingleton(() => DioClient(locator<Connectivity>()));
  locator.registerLazySingleton(() => SosCoordinator());
  locator.registerLazySingleton(
    () => AuthRepository(client: locator<DioClient>()),
  );
  locator.registerFactory(
    () => ap.AuthProvider(repository: locator<AuthRepository>()),
  );

  locator.registerLazySingleton(
    () => UserRepository(client: locator<DioClient>()),
  );
  locator.registerLazySingleton<ReferralRepository>(
    () => ReferralRepository(locator()),
  );

  // REMOTE DATA SOURCE
  locator.registerLazySingleton<NearmeRemoteDataSource>(
    () => NearmeRemoteDataSourceImpl(client: locator()),
  );
  locator.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(client: locator()),
  );
  locator.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(client: locator()),
  );

  // REPOSITORY

  locator.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerLazySingleton<NearmeRepository>(
    () => NearmeRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerLazySingleton<MediaRepository>(
    () => MediaRepository(locator()),
  );
  locator.registerLazySingleton<InformationRepository>(
    () => InformationRepository(client: locator()),
  );

  // USE CASE
  locator.registerLazySingleton(() => GetNewsUseCase(locator()));
  locator.registerLazySingleton(() => GetPlaceNearbyUseCase(locator()));
  locator.registerLazySingleton(() => SosRatingUseCase(locator()));
  locator.registerLazySingleton(() => GetBannerUseCase(locator()));
  locator.registerLazySingleton(() => DetailNewsUseCase(locator()));
  locator.registerLazySingleton(() => UpdateAddressUseCase(locator()));
  locator.registerLazySingleton(() => TrackUserUseCase(locator()));
  locator.registerLazySingleton(() => GetChatsUseCase(locator()));
  locator.registerLazySingleton(() => GetMessagesUseCase(locator()));
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
  locator.registerFactory(() => ReferralProvider(locator()));
  locator.registerFactory(() => InformationProvider(repository: locator()));
  locator.registerFactory(() => SosProvider(locator()));
  locator.registerFactory(() => SosRatingNotifier(useCase: locator()));
  locator.registerFactory(() => UpdateAddressNotifier(useCase: locator()));
  locator.registerFactory(() => GetChatsNotifier(useCase: locator()));
  locator.registerFactory(() => GetMessagesNotifier(useCase: locator()));
  locator.registerFactory(() => InsertMessageNotifier(useCase: locator()));
  locator.registerFactory(() => DetailNewsNotifier(useCase: locator()));
  locator.registerFactory(() => TrackUserNotifier(useCase: locator()));
  locator.registerFactory(() => GetNearbyPlacenNotifier(useCase: locator()));
  locator.registerFactory(() => DetailInboxNotifier(useCase: locator()));
  locator.registerFactory(() => GetInboxNotifier(useCase: locator()));
}
