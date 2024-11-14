import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:table_calendar/table_calendar.dart';

class EventCreatePage extends StatelessWidget {
  const EventCreatePage({super.key});

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
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              // selectedDayPredicate: (day) {
              //   // return isSameDay(_selectedDay, day);
              // },
              onDaySelected: (selectedDay, focusedDay) {
                // setState(() {
                //   _selectedDay = selectedDay;
                //   _focusedDay = focusedDay;
                // });
              },
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.white),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white),
                weekendStyle: TextStyle(color: Colors.white70),
              ),
              calendarStyle: const CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.white70),
                outsideTextStyle: TextStyle(color: Colors.white38),
                todayDecoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
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
          ),
          const SizedBox(
            height: 14,
          ),
          TextField(
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
          ),
          const SizedBox(
            height: 14,
          ),
          TextField(
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
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EventCreatePage()));
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
              label: const Text(
                'Simpan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 36,
          ),
        ],
      ),
    );
  }
}
