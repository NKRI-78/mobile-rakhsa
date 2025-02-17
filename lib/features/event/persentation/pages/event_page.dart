
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rakhsa/common/constants/theme.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/event/data/models/list.dart';

import 'package:rakhsa/features/event/persentation/provider/event_notifier.dart';
import 'package:rakhsa/features/event/persentation/widget/calendar_view.dart';
import 'package:rakhsa/features/event/persentation/widget/itinerary_button.dart';
import 'package:rakhsa/features/event/persentation/widget/itinerary_list_tile.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => EventPageState();
}

class EventPageState extends State<EventPage> {
  final now = DateTime.now();
  late DateTime _selectedDate;

  @override 
  void initState() {
    super.initState();
    _selectedDate = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventNotifier>().getEvent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F4F7),
        leading: CupertinoNavigationBarBackButton(
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
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
            final events = notifier.kEvents[_selectedDate] ?? [];
        
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CalendarView(
                    selectedDay: _selectedDate,
                    eventLoader: (day) {
                      log('day pada event loader $day');
                      return notifier.kEvents[day] ?? [];
                    },
                    onDaySelected: (selectedDay, _) {
                      log('selected date pada onDaySelected $selectedDay');
                      setState(() {
                        _selectedDate = selectedDay;
                      });
                      log('selected date $selectedDay');
                    },
                  ),
                  const SizedBox(height: 16),
                      
                  // add event
                  ItineraryButton(
                    label: 'Buat Agenda',
                    action: () {
                      final now = DateTime.now();
                      
                      notifier.navigateToCreateEventPage(
                        context, 
                        // selected date + (waktu sekarang + 1 jam)
                        DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          now.hour,
                          now.minute,
                        ).add(const Duration(hours: 1)),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // title day && navigate to all event
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // title day
                      Text(
                        DateFormat('dd', 'id').format(_selectedDate),
                        style: robotoRegular.copyWith(
                          fontSize: 24,
                          color: redColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // navigate to all event
                      InkWell(
                        onTap: () {
                          notifier.navigateToAllEventPage(context);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // title
                            Text(
                              'Semua agenda',
                              style: robotoRegular.copyWith(
                                fontSize: 12,
                                color: redColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),

                            // icon
                            const Icon(
                              Icons.arrow_forward, 
                              size: 18,
                              color: redColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                      
                  // showing event state
                  if(notifier.getEventState == ProviderState.loading)...[
                    _loadingEventView(),
                  ]else if(notifier.getEventState == ProviderState.error)...[
                    _errorEventView(notifier.errorMessageGetEvent!),
                  ]else...[
                    // success state
                    if(events.isEmpty)...[
                      _noEventView(),
                    ]else...[
                      // empty events view
                      _eventListView(events),
                    ]
                  ],
                ],
              ),
            );
          },
        ),
      )
    );
  }

  Widget _eventListView(List<EventData> events){
    return ListView.separated(
      shrinkWrap: true,
      itemCount: events.length,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final event = events[index];
        return ItineraryListTile(event);
      },
    );
  }

  Widget _noEventView(){
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Center(
        child: Text(
          'Tidak ada reminder di tanggal ini',
          textAlign: TextAlign.center,
          style: robotoRegular.copyWith(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _loadingEventView(){
    return const SizedBox(
      width: double.infinity,
      height: 180,
      child: Center(
        child: CircularProgressIndicator(color: redColor),
      ),
    );
  }

  Widget _errorEventView(String message){
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(
            color: redColor,
          ),
        ),
      ),
    );
  }
}