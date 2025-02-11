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
import 'package:rakhsa/features/dashboard/presentation/provider/track_user_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/weather_notifier.dart';
import 'package:rakhsa/features/document/presentation/provider/document_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/delete_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/detail_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/list_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/save_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/update_event_notifier.dart';
import 'package:rakhsa/features/information/presentation/provider/kbri_id_notifier.dart';
import 'package:rakhsa/features/information/presentation/provider/kbri_name_notifier.dart';
import 'package:rakhsa/features/information/presentation/provider/passport_notifier.dart';
import 'package:rakhsa/features/information/presentation/provider/visa_notifier.dart';
import 'package:rakhsa/features/media/presentation/provider/upload_media_notifier.dart';
import 'package:rakhsa/features/nearme/presentation/provider/nearme_notifier.dart';
import 'package:rakhsa/features/ppob/presentation/providers/inquiry_pulsa_listener.dart';
import 'package:rakhsa/features/ppob/presentation/providers/pay_pulsa_and_paket_listener.dart';
import 'package:rakhsa/features/ppob/presentation/providers/payment_channel_listener.dart';
import 'package:rakhsa/firebase.dart';

import 'package:rakhsa/injection.dart' as di;
import 'package:rakhsa/providers/ecommerce/ecommerce.dart';
import 'package:rakhsa/socketio.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
];

List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider.value(value: di.locator<FirebaseProvider>()),
  ChangeNotifierProvider.value(value: di.locator<DashboardNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<DetailNewsNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<SosNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<TrackUserNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<SosRatingNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<ListEventNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<ProfileNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<LoginNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<DocumentNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<RegisterNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<ResendOtpNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<VerifyOtpNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<GetChatsNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<GetMessagesNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<GetContinentNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<GetCountryNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<GetStateNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<SaveEventNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<DetailEventNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<DeleteEventNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<UpdateEventNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<UpdateAddressNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<UpdateProfileNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<UpdateIsLoggedinNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<UploadMediaNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<KbriIdNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<KbriNameNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<VisaNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<ForgotPasswordNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<PassportNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<InsertMessageNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<EcommerceProvider>()),
  // ChangeNotifierProvider.value(value: di.locator<PassportScannerNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<GetNearbyPlacenNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<InquiryPulsaProvider>()),
  ChangeNotifierProvider.value(value: di.locator<PaymentChannelProvider>()),
  ChangeNotifierProvider.value(value: di.locator<PayPulsaAndPaketDataProvider>()),
  ChangeNotifierProvider.value(value: di.locator<WeatherNotifier>()),
  ChangeNotifierProvider.value(value: di.locator<SocketIoService>()..connect()),
];
