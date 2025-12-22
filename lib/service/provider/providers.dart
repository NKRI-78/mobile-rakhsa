import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:rakhsa/modules/referral/provider/referral_provider.dart';

import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_chats_notifier.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/detail_news_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/sos_rating_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/modules/information/presentation/provider/information_provider.dart';
import 'package:rakhsa/modules/sos/provider/sos_provider.dart';
import 'package:rakhsa/modules/weather/provider/weather_notifier.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';
import 'package:rakhsa/modules/nearme/presentation/provider/near_me_provider.dart';

import 'package:rakhsa/injection.dart' as di;
import 'package:rakhsa/service/socket/socketio.dart';

List<SingleChildWidget> providers = [...independentServices];

List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider.value(value: di.locator<AuthProvider>()),
  ChangeNotifierProvider(create: (_) => LocationProvider()),
  ChangeNotifierProvider.value(value: di.locator<DashboardNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<DetailNewsNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<SosRatingNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<UserProvider>()),
  ChangeNotifierProvider.value(value: di.locator<GetChatsNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<GetMessagesNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<InformationProvider>()),
  ChangeNotifierProvider.value(value: di.locator<UpdateAddressNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<NearMeProvider>()),
  ChangeNotifierProvider.value(value: di.locator<SosProvider>()),
  ChangeNotifierProvider.value(value: di.locator<ReferralProvider>()),
  ChangeNotifierProxyProvider<LocationProvider, WeatherNotifier>(
    create: (_) => WeatherNotifier(),
    update: (_, locationProvider, weatherNotifier) {
      weatherNotifier ??= WeatherNotifier();
      weatherNotifier.updateFromLocation(locationProvider.location);
      return weatherNotifier;
    },
  ),
  ChangeNotifierProvider(
    create: (_) {
      final socketService = di.locator<SocketIoService>();
      socketService.connect();
      return socketService;
    },
  ),
];
