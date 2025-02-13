import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatelessWidget {
  CalendarView({
    super.key,
    required this.selectedDay,
    required this.eventLoader,
    required this.onDaySelected,
  });

  final now = DateTime.now();

  final DateTime selectedDay;
  final List<dynamic> Function(DateTime)? eventLoader;
  final void Function(DateTime, DateTime)? onDaySelected;

  @override
  Widget build(BuildContext context) {
    const border = BorderSide(color: greyColor);
    final tableBorder = TableBorder(
      horizontalInside: border,
      verticalInside: border,
      bottom: border,
      left: border,
      right: border,
      top: border,
      borderRadius: BorderRadius.circular(8),
    );
    const boxDecoration = BoxDecoration(
      color: redColor,
      shape: BoxShape.circle,
    );
    final disabledTextStyle = robotoRegular.copyWith(
      color: Colors.grey.shade500,
      fontWeight: FontWeight.w600,
    );
    final enabledTextStyle = robotoRegular.copyWith(
      color: blackColor,
      fontWeight: FontWeight.w600,
    );

    return TableCalendar(
      locale: 'id',
      rowHeight: 68,
      focusedDay: selectedDay,
      firstDay: DateTime(now.year),
      lastDay: DateTime(2030),
      eventLoader: eventLoader,
      onDaySelected: onDaySelected,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        selectedDecoration: boxDecoration,
        disabledTextStyle: disabledTextStyle,
        defaultTextStyle: enabledTextStyle,
        weekendTextStyle: disabledTextStyle,
        tableBorder: tableBorder,
        todayDecoration: BoxDecoration(
          color: redColor.withOpacity(0.2),
          border: Border.all(color: redColor),
          shape: BoxShape.circle,
        ),
      ),
      enabledDayPredicate: (day) {
        return !day.isBefore(
          DateTime.now().subtract(const Duration(days: 1)),
        );
      },
    );
  }
}