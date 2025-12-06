import 'dart:io';
import 'dart:math';
import 'package:rakhsa/misc/utils/logger.dart' as d;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/modules/chat/presentation/pages/chat_room_page.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/router/router.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';
import 'package:rakhsa/service/location/location_service.dart';
import 'package:rakhsa/firebase_options.dart';
import 'package:rakhsa/injection.dart';
import 'package:rakhsa/misc/client/dio_client.dart';
import 'package:rakhsa/modules/app/provider/user_provider.dart';

import 'package:rakhsa/modules/news/persentation/pages/detail.dart';

import '../storage/storage.dart';
import '../../modules/dashboard/presentation/provider/dashboard_notifier.dart';
import '../sos/sos_coordinator.dart';

class NotificationType {
  NotificationType._();

  static const resolvedSos = "resolved-sos";
  static const closedSos = "closed-sos";
  static const confirmSos = "confirm-sos";
  static const fetchLatestLocation = "fetch-latest-location";
  static const ews = "ews";
  static const ewsDelete = "ews-delete";
  static const news = "news";
  static const chat = "chat";
  static const historyUser = "history-user";
}

bool isNotificationInitialized = false;

//* ===== FIREBASE BACKGROUND HANDLER =====
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage m) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // penting untuk mendapatkan uid & baseurl dari local storage
  await StorageHelper.init();

  await NotificationManager().initializeLocalNotification();

  final data = m.data;
  String? type = data['type'] ?? "";

  d.log("notifikasi dari background = $data", label: "NOTIFICATION_MANAGER");

  if (type == NotificationType.confirmSos) {
    await SosCoordinator.markPendingStopFromBackground();
  }
}

//* ===== NOTIFICATION MANAGER =====
class NotificationManager {
  static NotificationManager? _instance;
  NotificationManager._privateConstructor();
  factory NotificationManager() {
    _instance ??= NotificationManager._privateConstructor();
    return _instance!;
  }

  Future<void> initializeLocalNotification({
    NotificationImportance importance = NotificationImportance.High,
    bool setAlertForIOS = true,
  }) async {
    if (isNotificationInitialized) return;

    await AwesomeNotifications()
        .initialize('resource://drawable/ic_notification', [
          NotificationChannel(
            channelKey: 'notification',
            channelName: 'notification',
            channelDescription: 'Notification',
            playSound: true,
            channelShowBadge: true,
            criticalAlerts: true,
            importance: importance,
          ),
        ], debug: false);

    // jadi di iOS forebase sendiri udah ngeluarin notifikasi tapi ga bisa di hide
    // cuma bisa disiasati dengan matiin alert, badge sama sound
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: setAlertForIOS,
          badge: setAlertForIOS,
          sound: setAlertForIOS,
        );

    // handle local notification on tap
    final action = await AwesomeNotifications()
        .getInitialNotificationAction()
        .timeout(Duration(seconds: 5), onTimeout: () => null);
    if (action != null) {
      d.log(
        "notifikasi di tap dari AwesomeNotifications().getInitialNotificationAction() | payload = ${action.payload ?? "-"}",
        label: "NOTIFICATION_MANAGER",
      );
      await handleNotificationOnTap(action.payload);
    }

    isNotificationInitialized = true;
  }

  Future<void> initializeFcmToken() async {
    try {
      final session = await StorageHelper.loadlocalSession();
      final token = await FirebaseMessaging.instance.getToken();

      var data = <String, dynamic>{
        "user_id": session?.user.id ?? "-",
        "token": token ?? "-",
      };
      await locator<DioClient>().post(endpoint: "/fcm", data: data);
      d.log("initFCM erhbasil = $data", label: "NOTIFICATION_MANAGER");
    } catch (e) {
      d.log("error initFCM: $e", label: "NOTIFICATION_MANAGER");
    }
  }

  Future<void> initializeFcmHandlers() async {
    final rm = await FirebaseMessaging.instance.getInitialMessage();
    if (rm != null) {
      d.log(
        "notifikasi di tap dari FirebaseMessaging.instance.getInitialMessage() | payload = ${rm.data}",
        label: "NOTIFICATION_MANAGER",
      );
      await handleNotificationOnTap(rm.data);
    }

    // on foreground / ketika aplikasi dibuka
    FirebaseMessaging.onMessage.listen((m) async {
      final data = m.data;
      String type = data['type'] ?? "";

      d.log(
        "notifikasi dari foreground = $data",
        label: "NOTIFICATION_MANAGER",
      );

      // pokoknya jangan show local notification di iOS biar ga dobel notifikasinya
      if (Platform.isIOS) return;

      try {
        // kalau notif terkait ews jangan munculin notifikasi cukup update ews
        if (type == NotificationType.ews ||
            type == NotificationType.ewsDelete) {
          await _revalidateEws();
          return;
        }

        if (type == NotificationType.fetchLatestLocation) {
          await sendLatestLocation(
            "Notification on Foreground",
            otherSource: navigatorKey.currentContext
                ?.read<LocationProvider>()
                .location,
          );
        }

        await showNotification(
          title: m.notification?.title ?? "-",
          body: m.notification?.body ?? "-",
          payload: {
            "type": type,
            "news_id": data["news_id"].toString(),
            "chat_id": data["chat_id"].toString(),
            "recipient_id": data["recipient_id"].toString(),
            "sos_id": data["sos_id"].toString(),
          },
        );
      } catch (e) {
        d.log(
          "error processing notification: $e",
          label: "NOTIFICATION_MANAGER",
        );
      }
    });

    // ketika notifikasi di klik
    FirebaseMessaging.onMessageOpenedApp.listen((m) async {
      d.log(
        "notifikasi di tap dari FirebaseMessaging.onMessageOpenedApp | payload = ${m.data}",
        label: "NOTIFICATION_MANAGER",
      );
      await handleNotificationOnTap(m.data);
    });
  }

  Future<void> setForegroundMessageActionListeners() async {
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod:
          NotificationActionController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationActionController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationActionController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationActionController.onDismissActionReceivedMethod,
    );
  }

  Future<void> showNotification({
    int? id,
    String? title,
    String? body,
    Map<String, String?>? payload,
  }) async {
    final notificationId = id ?? Random().nextInt(105);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        payload: payload,
        notificationLayout: NotificationLayout.Default,
        actionType: ActionType.Default,
        id: notificationId,
        channelKey: 'notification',
        title: title,
        body: body,
      ),
    );
  }

  Future<void> dismissAllNotification() async {
    d.log("cancel semua notif", label: "NOTIFICATION_MANAGER");
    await AwesomeNotifications().dismissAllNotifications();
    await AwesomeNotifications().resetGlobalBadge();
  }

  Future<void> handleNotificationOnTap(
    Map<String, dynamic>? data, {
    bool fromForeground = false,
  }) async {
    String type = data?['type'] ?? "undefined type";
    final c = navigatorKey.currentContext!;

    switch (type) {
      case NotificationType.resolvedSos:
        _handleResolveSOS(c);
        break;
      case NotificationType.closedSos:
        _handleClosedSOS(c);
        break;
      case NotificationType.confirmSos:
        _handleConfirmSOS(c);
        break;
      case NotificationType.news:
        String newsId = data?["news_id"] ?? "0";
        _handleNewsOnTap(c, newsId);
        break;
      case NotificationType.ews:
        String newsId = data?["news_id"] ?? "0";
        _handleEwsOnTap(c, newsId);
        break;
      case NotificationType.chat:
        _handleChatOnTap(c, data);
        break;
      case NotificationType.fetchLatestLocation:
        _handleFetchLatestLocationOnTap(c, fromForeground);
        break;
      default:
        d.log(
          "Unhandled notification type: $type",
          label: "NOTIFICATION_MANAGER",
        );
    }

    // buat increment badge di logo launcher aplikasi
    await AwesomeNotifications().decrementGlobalBadgeCounter();
  }

  Future<void> _revalidateEws() async {
    final c = navigatorKey.currentContext!;
    final user = await c.read<UserProvider>().getUser(enableCache: true);

    final lat = double.tryParse(user?.lat ?? "0") ?? 0;
    final lng = double.tryParse(user?.lng ?? "0") ?? 0;
    final state = user?.state ?? "Indonesia";

    // ignore: use_build_context_synchronously
    await c.read<DashboardNotifier>().getEws(lat: lat, lng: lng, state: state);
  }

  void _handleResolveSOS(BuildContext c) async {
    await c.read<UserProvider>().getUser();
  }

  void _handleClosedSOS(BuildContext c) async {
    await c.read<UserProvider>().getUser();
  }

  void _handleConfirmSOS(BuildContext c) async {
    await c.read<UserProvider>().getUser();
    SosCoordinator().stop(reason: "fcm-opened-app");
  }

  void _handleNewsOnTap(BuildContext c, String id) {
    NewsDetailRoute(
      NewsDetailPageParams(id: int.parse(id), type: "news"),
    ).go(c);
  }

  void _handleEwsOnTap(BuildContext c, String newsId) async {
    final user = await c.read<UserProvider>().getUser(enableCache: true);
    Future.delayed(const Duration(seconds: 1), () async {
      final lat = double.tryParse(user?.lat ?? "0") ?? 0;
      final lng = double.tryParse(user?.lng ?? "0") ?? 0;
      final state = user?.state ?? "Indonesia";
      // ignore: use_build_context_synchronously
      await c.read<DashboardNotifier>().getEws(
        lat: lat,
        lng: lng,
        state: state,
      );
      NewsDetailRoute(
        NewsDetailPageParams(id: int.parse(newsId), type: "news"),
        // ignore: use_build_context_synchronously
      ).go(c);
    });
  }

  void _handleChatOnTap(BuildContext c, Map<String, dynamic>? data) {
    String chatId = data?["chat_id"] ?? "-";
    String recipientId = data?["recipient_id"] ?? "-";
    String sosId = data?["sos_id"] ?? "-";
    final currentState = navigatorKey.currentState;
    d.log(
      "hasCurrentState? ${currentState != null}",
      label: "NOTIFICATION_MANAGER",
    );
    ChatRoomRoute(
      ChatRoomParams(
        sosId: sosId,
        chatId: chatId,
        status: "PROCESS",
        recipientId: recipientId,
        autoGreetings: false,
        newSession: false,
      ),
    ).go(c);
  }

  void _handleFetchLatestLocationOnTap(
    BuildContext c,
    bool fromForeground,
  ) async {
    // kalau dari foreground biarkan trigger sendLatestLocation ada di FirebaseMessaging.onMessage.listen
    if (fromForeground) return;
    // yang ini untuk on tap dari background aja
    await sendLatestLocation("User open the App");
  }
}

//* ===== NOTIFICATION FOREGROUND ON TAP HANDLER =====
class NotificationActionController {
  NotificationActionController._();

  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification r,
  ) async {}

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification r,
  ) async {}

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedAction r) async {
    await AwesomeNotifications().decrementGlobalBadgeCounter();
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction r) async {
    d.log(
      "notifikasi di tap dari NotificationActionController.onActionReceivedMethod() | payload = ${r.payload ?? "-"}",
      label: "NOTIFICATION_MANAGER",
    );
    await NotificationManager().handleNotificationOnTap(
      r.payload,
      fromForeground: true,
    );
  }
}
