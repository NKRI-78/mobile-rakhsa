import 'package:flutter/material.dart';

import 'package:googleapis_auth/auth_io.dart';

import 'package:googleapis/calendar/v3.dart' as calendar;

const scopes = [calendar.CalendarApi.calendarScope];

class GoogleCalendarExample extends StatefulWidget {
  const GoogleCalendarExample({super.key});

  @override
  GoogleCalendarExampleState createState() => GoogleCalendarExampleState();
}

class GoogleCalendarExampleState extends State<GoogleCalendarExample> {
  calendar.CalendarApi? calendarApi;

  @override
  void initState() {
    super.initState();
    initializeCalendarApi();
  }

  Future<void> initializeCalendarApi() async {
    final clientId = ClientId(
      'YOUR_CLIENT_ID',
      '',
    );

    await clientViaUserConsent(clientId, scopes, (url) {
      debugPrint('Please go to the following URL and authorize the app:');
      debugPrint(url);
    }).then((AuthClient client) {
      calendarApi = calendar.CalendarApi(client);
      listEvents();
    }).catchError((e) {
      debugPrint('Error during authorization: $e');
    });
  }

  Future<void> listEvents() async {
    if (calendarApi == null) return;

    try {
      final events = await calendarApi!.events.list('primary');
      for (var event in events.items!) {
        debugPrint('Event: ${event.summary}');
      }
    } catch (e) {
      debugPrint('Error fetching events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Calendar API Example')
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: listEvents,
          child: const Text('Fetch Calendar Events'),
        ),
      ),
    );
  }
}