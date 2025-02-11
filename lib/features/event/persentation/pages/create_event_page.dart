
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/features/event/persentation/provider/save_event_notifier.dart';
import 'package:rakhsa/features/event/persentation/widget/itinerary_text_field.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../provider/list_event_notifier.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage(this.details, {super.key});

  final CalendarTapDetails  details;

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  late SaveEventNotifier _saveEventNotifier; 
  late ListEventNotifier _listEventNotifier; 

  late TextEditingController _titileC;

  String _titleValue = '';

  @override
  void initState() {
    super.initState();
    _saveEventNotifier = context.read<SaveEventNotifier>();
    _listEventNotifier = context.read<ListEventNotifier>();

    _titileC = TextEditingController();
  }

  @override
  void dispose() {
    _reset();
    _titileC.dispose();

    // get agenda saat back dari halaman create event
    _listEventNotifier.list();
    super.dispose();
  }

  void _reset(){
    _titileC.clear();
  }

  bool validateForm(){
    return _titleValue.isNotEmpty;
  }

  void _createEvent() async {
    final date = widget.details.date!;
    if (validateForm()) {
      await _saveEventNotifier.save(
        context,
        title: _titileC.text, 
        startDate: DateFormat('yyyy-MM-dd').format(date),
        endDate: DateFormat('yyyy-MM-dd').format(date), 
        continentId: 1, stateId: 1,
        description: 'none',
      );
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: 'notification',
          title: 'Reminder',
          body: _titileC.text,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          year: date.year,
          month: date.month,
          day: date.day,
          hour: date.hour,
          minute: date.minute,
          second: 0,
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          preciseAlarm: true,
        ),
      );
      _reset();
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text('Buat Agenda'),
        titleTextStyle: robotoRegular.copyWith(
          fontSize: 20,
          color: whiteColor,
        ),
        leading: CupertinoNavigationBarBackButton(
          color: whiteColor,
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: FlexibleSpaceBar(
          background: Image.asset(
            AssetSource.loginOrnament,
            fit: BoxFit.cover,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // input judul
              ItineraryTextField(
                controller: _titileC,
                title: 'Reminder',
                hint: 'Masukan Reminder',
                autofocus: true,
                textInputAction: TextInputAction.done,
                onChanged: (value) => setState(() {
                  if (value.isEmpty){
                    _titleValue = '';
                  } else {
                    _titleValue = value;
                  }
                }),
                onSubmitted: (_) {
                  _createEvent();
                },
              ),
              const SizedBox(height: 16),

              // tanggal mulai
              Text(
                'Tanggal Reminder',
                style: robotoRegular.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14, 
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  DateFormat('dd MMMM yyyy', 'id').format(widget.details.date!),
                  style: robotoRegular.copyWith(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Consumer<SaveEventNotifier>(
                builder: (context, notifier, child) {
                  return Container(
                    width: double.infinity,
                    color: whiteColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: ElevatedButton(
                      onPressed: validateForm()
                            ? () => _createEvent()
                            : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        backgroundColor: primaryColor,
                        foregroundColor: whiteColor,
                        padding: const EdgeInsets.all(16),
                        textStyle: robotoRegular.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: (notifier.state == ProviderState.loading) 
                          ? const Text('Memuat..') 
                          : const Text('Submit'),
                    ),
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}