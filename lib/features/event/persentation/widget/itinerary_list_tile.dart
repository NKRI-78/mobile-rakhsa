import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/features/event/data/models/list.dart';
import 'package:rakhsa/features/event/persentation/provider/event_notifier.dart';
import 'package:rakhsa/features/event/persentation/widget/delete_event_dialog.dart';

class ItineraryListTile extends StatelessWidget {
  const ItineraryListTile(this. event, {super.key});

  final EventData event;

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(event.startDate);
    return ListTile(
      title: Text(
        event.title,
        style: robotoRegular.copyWith(
          fontWeight: FontWeight.w600,
        )
      ),
      subtitle: Text.rich(
        TextSpan(
          text: DateFormat('EEEE ', 'id').format(dateTime),
          children: [
            TextSpan(
              text: DateFormat('dd MMMM yyyy', 'id').format(dateTime),
            ),
            const TextSpan(text: ' Jam '),
            TextSpan(
              text: DateFormat('HH:mm', 'id').format(dateTime),
            ),
          ],
        ),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        context.read<EventNotifier>().navigateToCreateEventPage(
          context, DateTime.parse(event.startDate),
          event: event,
        );
      },
      trailing: Material(
        color: redColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: () async {
            final deleteEvent = await DeleteEventDialog.launch(context, event);
            if (deleteEvent && context.mounted) {
              await context.read<EventNotifier>().deleteEvent(event);
            }
          },
          borderRadius: BorderRadius.circular(100),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Icon(Icons.delete, color: redColor),
          ),
        ),
      ),
      tileColor: redColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: redColor),
      ),
    );
  }
}