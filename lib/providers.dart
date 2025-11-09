import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:rakhsa/modules/administration/presentation/provider/get_continent_notifier.dart';
import 'package:rakhsa/modules/administration/presentation/provider/get_country_notifier.dart';
import 'package:rakhsa/modules/administration/presentation/provider/get_state_notifier.dart';
import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/modules/chat/presentation/provider/detail_inbox_notifier.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_chats_notifier.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_inbox_notifier.dart';
import 'package:rakhsa/modules/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/modules/chat/presentation/provider/insert_message_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/detail_news_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/sos_rating_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/track_user_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/weather_notifier.dart';
import 'package:rakhsa/modules/information/presentation/provider/kbri_id_notifier.dart';
import 'package:rakhsa/modules/information/presentation/provider/kbri_name_notifier.dart';
import 'package:rakhsa/modules/information/presentation/provider/passport_notifier.dart';
import 'package:rakhsa/modules/information/presentation/provider/visa_notifier.dart';
import 'package:rakhsa/modules/media/presentation/provider/upload_media_notifier.dart';
import 'package:rakhsa/modules/nearme/presentation/provider/nearme_notifier.dart';
import 'package:rakhsa/firebase.dart';

import 'package:rakhsa/injection.dart' as di;
import 'package:rakhsa/socketio.dart';

List<SingleChildWidget> providers = [...independentServices];

List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider.value(value: di.locator<AuthProvider>()),
  ChangeNotifierProvider.value(value: di.locator<FirebaseProvider>()),
  ChangeNotifierProvider.value(value: di.locator<DashboardNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<DetailNewsNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<TrackUserNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<SosRatingNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<UserProvider>()),
  ChangeNotifierProvider.value(value: di.locator<GetChatsNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<GetMessagesNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<GetContinentNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<GetCountryNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<GetStateNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<UpdateAddressNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<UploadMediaNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<KbriIdNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<KbriNameNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<VisaNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<PassportNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<InsertMessageNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<GetNearbyPlacenNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<WeatherNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<DetailInboxNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<GetInboxNotifier>()),
  ChangeNotifierProvider(
    create: (_) {
      final socketService = di.locator<SocketIoService>();
      socketService.connect();
      return socketService;
    },
  ),
];
