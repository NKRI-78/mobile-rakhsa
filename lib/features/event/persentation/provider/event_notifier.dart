
import 'dart:collection';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/features/event/data/models/list.dart';
import 'package:rakhsa/features/event/domain/usecases/delete_event.dart';
import 'package:rakhsa/features/event/domain/usecases/list_event.dart';
import 'package:rakhsa/features/event/domain/usecases/save_event.dart';
import 'package:rakhsa/features/event/domain/usecases/update_event.dart';
import 'package:rakhsa/features/event/persentation/pages/all_event_page.dart';
import 'package:rakhsa/features/event/persentation/pages/create_event_page.dart';
import 'package:table_calendar/table_calendar.dart';

class EventNotifier extends ChangeNotifier {
  final SaveEventUseCase useCase;
  final ListEventUseCase listEventUseCase;
  final UpdateEventUseCase updateEventUseCase;
  final DeleteEventUseCase deleteEventUseCase;

  EventNotifier({
    required this.useCase, 
    required this.listEventUseCase,
    required this.updateEventUseCase,
    required this.deleteEventUseCase,
  });

  ProviderState _getEventState = ProviderState.empty;
  ProviderState get getEventState => _getEventState;

  ProviderState _createEventState = ProviderState.empty;
  ProviderState get createEventState => _createEventState;

  ProviderState _editEventState = ProviderState.empty;
  ProviderState get editEventState => _editEventState;

  ProviderState _deleteEventState = ProviderState.empty;
  ProviderState get deleteEventState => _deleteEventState;

  final _kEvents = LinkedHashMap<DateTime, List<EventData>>(
    equals: isSameDay,
    hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
  );
  LinkedHashMap<DateTime, List<EventData>> get kEvents => _kEvents;

  List<EventData> _eventList = [];
  List<EventData> get eventList => _eventList;

  String? _errorMessageGetEvent;
  String? get errorMessageGetEvent => _errorMessageGetEvent;

  Future<void> getEvent() async {    
    _getEventState = ProviderState.loading;
    notifyListeners();

    final result = await listEventUseCase.execute();

    result.fold((l) {
      _errorMessageGetEvent = l.message;
      _getEventState = ProviderState.error;
      notifyListeners();
    }, (r) {
      Map<DateTime, List<EventData>> newEvents = {};

      for (var event in r.data) {
        DateTime eventDate = DateTime.parse(event.startDate);
        DateTime dateKey = DateTime(
          eventDate.year, eventDate.month, eventDate.day,
        );

        if (newEvents[dateKey] == null) {
          newEvents[dateKey] = [];
        }
        newEvents[dateKey]!.add(event);
      }

      _kEvents.clear();
      _kEvents.addAll(newEvents);
      _eventList = r.data;
      _getEventState = ProviderState.loaded;
      notifyListeners();
    });
  }

  Future<void> createEvent(
    BuildContext context, {
    required String message,
    required String date,
  }) async {
    _createEventState = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute(
      title: message,
      startDate: date,
      endDate: date,
      continentId: 1,
      stateId: 1,
      description: 'none',
    );

    result.fold((l) {
      _createEventState = ProviderState.error;
      notifyListeners();

      ShowSnackbar.snackbarErr('Gagal membuat agenda [${l.message}]');
    }, (r) async {
      // create notification
      _createEventNotification(
        message,
        DateTime.parse(date),
      );

      _createEventState = ProviderState.loaded;
      notifyListeners();

      if(context.mounted) Navigator.of(context).pop();
      ShowSnackbar.snackbarOk('Berhasil membuat agenda');

      // dapatkan event kembali
      await getEvent();
    });
  }

  Future<void> editEvent(BuildContext context, EventData event) async {
    _editEventState = ProviderState.loading;
    notifyListeners();

    final editEvent = await updateEventUseCase.execute(
      id: event.id, 
      title: event.title, 
      startDate: event.startDate, 
      endDate: event.endDate,
      continentId: 1, 
      stateId: 1, 
      description: event.description,
    );

    editEvent.fold((l) {
      _editEventState = ProviderState.error;
      notifyListeners();
    }, (r) async {

      await _updateEventNotification(event);

      _editEventState = ProviderState.loaded;
      notifyListeners();

      if(context.mounted) Navigator.of(context).pop();
      ShowSnackbar.snackbarOk('Berhasil mengupdate agenda');

      // dapatkan event kembali
      await getEvent();
    });
  }

  Future<void> deleteEvent(EventData event) async {
    _deleteEventState = ProviderState.loading;
    notifyListeners();

    final deleteEvent = await deleteEventUseCase.execute(id: event.id);

    deleteEvent.fold((l) {
      _deleteEventState = ProviderState.error;
      notifyListeners();
    }, (r) async {
      _deleteEventState = ProviderState.loaded;
      notifyListeners();

      // id notifikasi diambil dari selected date (millisecond)
      _cancelEventNotification(DateTime.parse(event.startDate).millisecond);

      await getEvent();
    });
  }

  Future<void> _createEventNotification(String message, DateTime date) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: date.millisecond,
        body: message,
        title: 'Reminder',
        wakeUpScreen: true,
        displayOnBackground: true,
        displayOnForeground: true,
        channelKey: 'notification',
        payload: {'screen': 'itinerary'},
        category: NotificationCategory.Reminder,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: date.year,
        month: date.month,
        day: date.day,
        hour: date.hour,
        minute: date.minute,
        second: date.second,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
      ),
    );
  }

  Future<void> _cancelEventNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> _updateEventNotification(EventData event) async {
    // hapus notif
    // id notifikasi diambil dari selected date (millisecond)
    await _cancelEventNotification(DateTime.parse(event.startDate).millisecond);

    // create ulang notif
    await _createEventNotification(event.title, DateTime.parse(event.startDate));
  }

  void navigateToCreateEventPage(BuildContext context, DateTime selectedDay, {
    EventData? event,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CreateEventPage(
          selectedDay,
          event: event,
        ),
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, a1, a2, child) => _transition(a1, child),
      ),
    );
  }

   Widget _transition(Animation<double> a, Widget child, {bool moveUp = true}) {
    var begin = moveUp ? const Offset(0.0, 1.0) : const Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;
    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = a.drive(tween);
    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }

  void navigateToAllEventPage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AllEventPage(),
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, a1, a2, child) => _transition(
          a1, 
          child, 
          moveUp: false,
        ),
      ),
    );
  }
}