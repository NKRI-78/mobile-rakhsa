
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/features/event/persentation/provider/event_notifier.dart';
import 'package:rakhsa/features/event/persentation/widget/itinerary_text_field.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage(this.details, {super.key});

  final CalendarTapDetails  details;

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  late EventNotifier _saveEventNotifier;

  late TextEditingController _titileC;

  late TimePickerSpinnerController _pickerSpinnerController;

  late DateTime _selectedDateTime;

  String _titleValue = '';

  @override
  void initState() {
    super.initState();
    _saveEventNotifier = context.read<EventNotifier>();
    _pickerSpinnerController = TimePickerSpinnerController();
    _selectedDateTime = widget.details.date!;

    _titileC = TextEditingController();
  }

  @override
  void dispose() {
    _reset();
    _titileC.dispose();
    _pickerSpinnerController.dispose();

    // get agenda saat back dari halaman create event
    _saveEventNotifier.list();
    super.dispose();
  }

  void _reset(){
    _titileC.clear();
  }

  bool validateForm(){
    return _titleValue.isNotEmpty;
  }

  void _createEvent() async {
    final date = _selectedDateTime;
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
          payload: {'screen': 'itinerary'},
          displayOnBackground: true,
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
          displayOnForeground: true,
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
          onPressed: () async {
            Navigator.pop(context);
            _saveEventNotifier.list();
            log('save event dipanggil');
          },
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
                onChanged: (value) => setState(() {
                  if (value.isEmpty){
                    _titleValue = '';
                  } else {
                    _titleValue = value;
                  }
                }),
                onSubmitted: (_) => _pickerSpinnerController.showMenu(),
              ),
              const SizedBox(height: 16),

              // pilih
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Agenda',
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Waktu',
                          style: robotoRegular.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TimePickerSpinnerPopUp(
                            mode: CupertinoDatePickerMode.time,
                            use24hFormat: true,
                            cancelText: 'Batal',
                            initTime: _selectedDateTime,
                            confirmTextStyle: robotoRegular.copyWith(
                              fontWeight: FontWeight.bold,
                              color: blackColor,
                            ),
                            confirmText: 'OK',
                            padding: const EdgeInsets.symmetric(
                              vertical: 14, 
                              horizontal: 12,
                            ),
                            textStyle: robotoRegular.copyWith(
                              fontSize: 16,
                            ),
                            isCancelTextLeft: true,
                            controller: _pickerSpinnerController,
                            onChange: (date) {
                              _selectedDateTime = date;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Consumer<EventNotifier>(
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