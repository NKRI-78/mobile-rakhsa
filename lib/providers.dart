import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:rakhsa/features/administration/presentation/provider/get_continent_notifier.dart';
import 'package:rakhsa/features/administration/presentation/provider/get_country_notifier.dart';
import 'package:rakhsa/features/administration/presentation/provider/get_state_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/forgot_password_notifier.dart';

import 'package:rakhsa/features/auth/presentation/provider/login_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/register_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/resend_otp_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/update_is_loggedin_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/update_profile_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/verify_otp_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_chats_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/insert_message_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/detail_news_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/sos_rating_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/delete_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/detail_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/list_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/save_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/update_event_notifier.dart';
import 'package:rakhsa/features/information/presentation/provider/kbri_notifier.dart';
import 'package:rakhsa/features/information/presentation/provider/passport_notifier.dart';
import 'package:rakhsa/features/information/presentation/provider/visa_notifier.dart';
import 'package:rakhsa/features/media/presentation/provider/upload_media_notifier.dart';
import 'package:rakhsa/firebase.dart';

import 'package:rakhsa/injection.dart' as di;
import 'package:rakhsa/websockets.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
];

List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider(create: (_) => di.locator<FirebaseProvider>()),
  ChangeNotifierProvider(create: (_) => di.locator<DashboardNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<DetailNewsNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<SosNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<SosRatingNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<ListEventNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<ProfileNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<LoginNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<RegisterNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<ResendOtpNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<VerifyOtpNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<GetChatsNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<GetMessagesNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<GetContinentNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<GetCountryNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<SaveEventNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<DetailEventNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<DeleteEventNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<UpdateEventNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<UpdateAddressNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<UpdateProfileNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<UpdateIsLoggedinNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<UploadMediaNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<GetStateNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<KbriNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<VisaNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<ForgotPasswordNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<PassportNotifier>()),  
  ChangeNotifierProvider(create: (_) => di.locator<InsertMessageNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<WebSocketsService>(), lazy: false),
];