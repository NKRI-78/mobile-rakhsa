import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:rakhsa/features/administration/presentation/provider/get_continent_notifier.dart';
import 'package:rakhsa/features/administration/presentation/provider/get_state_notifier.dart';

import 'package:rakhsa/features/auth/presentation/provider/login_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/register_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/resend_otp_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/verify_otp_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_chats_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/delete_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/list_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/save_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/update_event_notifier.dart';
import 'package:rakhsa/features/media/presentation/provider/upload_media_notifier.dart';

import 'package:rakhsa/injection.dart' as di;
import 'package:rakhsa/websockets.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
];

List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider(create: (_) => di.locator<DashboardNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<SosNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<ListEventNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<ProfileNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<LoginNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<RegisterNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<VerifyOtpNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<ResendOtpNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<UploadMediaNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<GetChatsNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<GetMessagesNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<GetContinentNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<SaveEventNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<DeleteEventNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<UpdateEventNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<GetStateNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<WebSocketsService>()),
];