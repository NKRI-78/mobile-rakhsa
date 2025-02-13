
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rakhsa/common/constants/theme.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/utils/color_resources.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

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
  DateTime _selectedDay = DateTime.now();

  @override 
  void initState() {
    super.initState();

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
            final events = notifier.events[_selectedDay] ?? [];
        
            if(notifier.getEventState == ProviderState.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(redColor),
                )
              );
            } else if(notifier.getEventState == ProviderState.error) {
              return Center(
                child: Text(notifier.errorMessageGetEvent!,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: ColorResources.black
                  ),
                ),
              );
            } else {
        
              // success view
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    CalendarView(
                      selectedDay: _selectedDay,
                      eventLoader: (day) {
                        debugPrint(day.toString());
                        return notifier.events[day] ?? [];
                      },
                      onDaySelected: (selectedDay, _) {
                        setState(() {
                          _selectedDay = DateTime(
                            selectedDay.year,
                            selectedDay.month,
                            selectedDay.day,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                        
                    // add event
                    Row(
                      children: [
                        Flexible(
                          flex: 5,
                          fit: FlexFit.tight,
                          child: ItineraryButton(
                            label: 'Buat Agenda',
                            action: () {
                              notifier.navigateToCreateEventPage(context, _selectedDay);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Material(
                            color: redColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                            child: InkWell(
                              onTap: () => notifier.navigateToAllEventPage(context),
                              borderRadius: BorderRadius.circular(100),
                              child: const Padding(
                                padding: EdgeInsets.all(14),
                                child: Icon(
                                  Icons.arrow_forward, 
                                  color: redColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                        
                    // showing event
                    if(events.isNotEmpty)...[
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: events.length,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return ItineraryListTile(event);
                        },
                      ),
                    ]else...[
                      // empty events view
                      SizedBox(
                        width: double.infinity,
                        height: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // tanggal
                            Text(
                              _selectedDay.day.toString(),
                              style: robotoRegular.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // message
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Tidak ada reminder di tanggal ini',
                                  textAlign: TextAlign.center,
                                  style: robotoRegular.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }
          },
        ),
      )
    );
  }
}