import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/features/administration/data/models/continent.dart';
import 'package:rakhsa/features/administration/data/models/state.dart';
import 'package:rakhsa/features/administration/presentation/provider/get_state_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/save_event_notifier.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/features/administration/presentation/provider/get_continent_notifier.dart';

class EventCreatePage extends StatefulWidget {
  const EventCreatePage({super.key});

  @override
  State<EventCreatePage> createState() => EventCreatePageState();
}

class EventCreatePageState extends State<EventCreatePage> {

  late TextEditingController titleC;
  late TextEditingController descC;

  late SaveEventNotifier saveEventNotifier;
  late GetContinentNotifier getContinentNotifier;
  late GetStateNotifier getStateNotifier;

  int continentId = -1;
  int stateId = -1;

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  DateTime? rangeStart;
  DateTime? rangeEnd;
  
  RangeSelectionMode rangeSelectionMode = RangeSelectionMode.toggledOff;

  Future<void> getData() async {
    if(!mounted) return;
      getContinentNotifier.getContinent();
  }

  Future<void> save() async {
    String title = titleC.text;
    String desc = descC.text;
    String startDate = DateFormat('yyyy-MM-dd').format(rangeStart!);
    String endDate = DateFormat('yyyy-MM-dd').format(rangeEnd!);
    if(title.isEmpty) {
      ShowSnackbar.snackbarErr("Field title is required");
      return;
    }

    if(desc.isEmpty) {
      ShowSnackbar.snackbarErr("Field description is required");
      return;
    }

    await saveEventNotifier.save(
      title: title, 
      startDate: startDate, 
      endDate: endDate, 
      continentId: continentId, 
      stateId: stateId, 
      description: desc
    );

    if(saveEventNotifier.message != "") {
      ShowSnackbar.snackbarErr(saveEventNotifier.message);
      return;
    }
    
    if(!mounted) return;
      Navigator.pop(context, "refetch");
  }

  @override 
  void initState() {
    super.initState();

    titleC = TextEditingController();
    descC = TextEditingController();

    saveEventNotifier = context.read<SaveEventNotifier>();
    getContinentNotifier = context.read<GetContinentNotifier>();
    getStateNotifier = context.read<GetStateNotifier>();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    titleC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F4F7),
        leading: CupertinoNavigationBarBackButton(
          color: ColorResources.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.only(left: 16.0, right: 32, bottom: 10),
            child: Text(
              'Buat Rencana Perjalanan mu ke Luar Negri',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          )
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: titleC,
            decoration: InputDecoration(
              fillColor: const Color(0xffF4F4F7),
              filled: true,
              hintText: 'Judul Perjalanan',
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  style: BorderStyle.none,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            'Pilih Tanggal Berangkat - Tanggal Kepulangan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xffFE1717),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: TableCalendar(
              focusedDay: focusedDay,
              firstDay: DateTime.now(),
              lastDay: DateTime(2050),
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              rangeStartDay: rangeStart,
              rangeEndDay: rangeEnd,
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              onRangeSelected: (DateTime? start, DateTime? end, DateTime focusedDay) {
                setState(() {

                  rangeStart = start;
                  rangeEnd = end;
                  
                });
              },
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.white
                ),
                weekendStyle: TextStyle(
                  color: Colors.white
                )
              ),
              calendarStyle: CalendarStyle(
                rangeHighlightColor: Colors.white.withOpacity(0.3),
                todayTextStyle: const TextStyle(
                  color: Colors.black
                ),
                outsideTextStyle: const TextStyle(
                  color: Colors.white
                ),
                weekendTextStyle: const TextStyle(
                  color: Colors.white
                ),
                todayDecoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                rangeStartDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          
          Consumer<GetContinentNotifier>(
            builder: (BuildContext context, GetContinentNotifier notifier, Widget? child) {
              if(notifier.providerState == ProviderState.loading) {
                return const SizedBox();
              }
              return Autocomplete<CountryData>(
               optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<CountryData>.empty();
                }
                return notifier.entity.where((region) {
                  return region.name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
                });
              },
              displayStringForOption: (CountryData option) => option.name,
              onSelected: (CountryData selection) {
                continentId = selection.id;

                getStateNotifier.getState(continentId: continentId);
              },
              fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      fillColor: const Color(0xffF4F4F7),
                      filled: true,
                      hintText: 'Masukkan Nama Benua',
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          style: BorderStyle.none,
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(
            height: 14.0,
          ),
          Consumer<GetStateNotifier>(
            builder: (BuildContext context, GetStateNotifier notifier, Widget? child) {
              if(notifier.providerState == ProviderState.loading) {
                return const SizedBox();
              }
              return Autocomplete<StateData>(
               optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<StateData>.empty();
                }
                return notifier.entity.where((region) {
                  return region.name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
                });
              },
              displayStringForOption: (StateData option) => option.name,
              onSelected: (StateData selection) {
                stateId = selection.id;
              },
              fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      fillColor: const Color(0xffF4F4F7),
                      filled: true,
                      hintText: 'Masukkan Nama Negara',
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          style: BorderStyle.none,
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(
            height: 14,
          ),
          TextField(
            controller: descC,
            maxLines: 8,
            decoration: InputDecoration(
              fillColor: const Color(0xffF4F4F7),
              filled: true,
              hintText: 'Masukkan Itinerary',
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  style: BorderStyle.none,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Consumer<SaveEventNotifier>(
              builder: (BuildContext context, SaveEventNotifier notifier, Widget? child) {
                return ElevatedButton.icon(
                  onPressed: () async {
                    await save();
                  },
                  icon: const Icon(
                    Icons.save,
                    color: ColorResources.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                      8,
                    )),
                    backgroundColor: const Color(0xffFE1717),
                  ),
                  label: notifier.state == ProviderState.loading 
                  ? const SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(ColorResources.white),
                      ),
                    )
                  : const Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            )
          ),
          const SizedBox(
            height: 36,
          ),
        ],
      ),
    );
  }
}
