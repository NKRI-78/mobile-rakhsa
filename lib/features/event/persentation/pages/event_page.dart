import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/theme.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/utils/color_resources.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/event/data/models/list.dart';
import 'package:rakhsa/features/event/persentation/pages/create_event_page.dart';
import 'package:rakhsa/features/event/persentation/provider/event_notifier.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => EventPageState();
}

class EventPageState extends State<EventPage> {

  late EventNotifier eventNotifier;

  Future<void> getData() async {
    if(!mounted) return;
      await eventNotifier.list();
  }

  @override 
  void initState() {
    super.initState();

    eventNotifier = context.read<EventNotifier>();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F4F7),
        leading: CupertinoNavigationBarBackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 32, bottom: 10),
            child: Text('Kelola Jadwal Perjalananmu dengan Mudah!',
              style: robotoRegular.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: Dimensions.fontSizeOverLarge,
              ),
            ),
          )
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<EventNotifier>(
          builder: (context, notifier, child) {
            if(notifier.state == ProviderState.loading) {
              return const Center(
                child: SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFFFE1717)),
                  ),
                )
              );
            }
            if(notifier.state == ProviderState.error) {
              return Center(
                child: Text(notifier.message,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: ColorResources.black
                  ),
                ),
              );
            }
            return SfCalendar(
              view: CalendarView.month,
              allowedViews: const [
                CalendarView.day,
                CalendarView.month,
                CalendarView.schedule,
              ],
              showWeekNumber: true,
              showNavigationArrow: true,
              showDatePickerButton: true,
              showCurrentTimeIndicator: true,
              todayHighlightColor: redColor,
              selectionDecoration: BoxDecoration(
                border: Border.all(color: redColor, width: 2),
              ),
              initialSelectedDate: DateTime.now(),
              minDate: DateTime.now(),
              dataSource: EventsDatasource(notifier.entity),
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
              onTap: (selectedDetails) {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CreateEventPage(selectedDetails);
                },));
              },
            );
          },
        ),
      )
    );
  }
}

class EventsDatasource extends CalendarDataSource {
  EventsDatasource(List<EventData> source){
    appointments = source;
  }

  @override
  String getSubject(int index) {
    return appointments?[index].title ?? '';
  }

  @override
  DateTime getStartTime(int index) {
    return DateTime.parse(appointments![index].startDate);
  }

  @override
  DateTime getEndTime(int index) {
    return DateTime.parse(appointments![index].endDate);
  }
}