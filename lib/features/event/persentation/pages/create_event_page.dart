
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/features/event/data/models/list.dart';
import 'package:rakhsa/features/event/persentation/provider/event_notifier.dart';
import 'package:rakhsa/features/event/persentation/widget/itinerary_button.dart';
import 'package:rakhsa/features/event/persentation/widget/itinerary_text_field.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage(this.selectedDate, {super.key, this.event});

  final DateTime selectedDate;
  final EventData? event;

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  late EventNotifier _saveEventNotifier;

  late TextEditingController _messageC;

  late DateTime _selectedDate;

  String _messageValue = '';

  @override
  void initState() {
    super.initState();
    _saveEventNotifier = context.read<EventNotifier>();
    _selectedDate = widget.selectedDate;

    _messageC = TextEditingController(text: widget.event?.title ?? '');
  }

  @override
  void dispose() {
    _reset();
    _messageC.dispose();
    
    super.dispose();
  }

  void _reset(){
    _messageC.clear();
  }

  bool _validForm() {
    DateTime now = DateTime.now();

    if (widget.event != null){
      return true;
    } else if (_messageValue.isEmpty) {
      return false;
    } else if (_selectedDate.isBefore(now)) {
      return false;
    }

    // valid
    return true;
  }

  void _createEvent() async {
    final date = _selectedDate;
    final event = widget.event;

    if (widget.event != null) {
      // update 
      await context.read<EventNotifier>().editEvent(
        context, EventData(
          id: event!.id, 
          title: _messageC.text, 
          description: event.description, 
          state: event.state, 
          continent: event.continent, 
          startDay: event.startDay, 
          endDay: event.endDay, 
          startDate: date.toString(), 
          endDate: event.endDate, 
          user: event.user, 
          type: event.type,
        ),
      );
    } else {
      // add
      await _saveEventNotifier.createEvent(
        context,
        message: _messageC.text,
        date: date.toString(),
      ).then((_) => _reset());
    }
    
  }

  String get _title {
    if (widget.event != null) {
      return 'Update Agenda';
    } else {
      return 'Buat Agenda';
    }
  }

  @override
  Widget build(BuildContext context) {
    log('selected date $_selectedDate');
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(_title),
        titleTextStyle: robotoRegular.copyWith(
          fontSize: 20,
          color: whiteColor,
        ),
        leading: CupertinoNavigationBarBackButton(
          color: whiteColor,
          onPressed: () async {
            Navigator.pop(context);
            _saveEventNotifier.getEvent();
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
                controller: _messageC,
                title: 'Agenda',
                hint: 'Masukan agenda anda',
                autofocus: true,
                onChanged: (value) => setState(() {
                  if (value.isEmpty){
                    _messageValue = '';
                  } else {
                    _messageValue = value;
                  }
                }),
              ),
              const SizedBox(height: 16),

              Text(
                'Waktu Agenda',
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
                child: Text.rich(
                  TextSpan(
                    text: DateFormat('EEEE dd MMMM yyyy', 'id').format(_selectedDate),
                    children: [
                      const TextSpan(text: ', Jam '),
                      TextSpan(
                        text: DateFormat('HH:mm', 'id').format(_selectedDate),
                      ),
                    ],
                  ),
                  style: robotoRegular.copyWith(
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // pilih tanggal dan waktu
              Text(
                'Pilih Jam',
                style: robotoRegular.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // pilih waktu
              TimePickerSpinner(
                spacing: 50,
                time: _selectedDate,
                isForce2Digits: true,
                normalTextStyle: robotoRegular.copyWith(
                  fontSize: 24,
                  color: Colors.grey.shade700,
                ),
                highlightedTextStyle: robotoRegular.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: redColor,
                ),
                onTimeChange: (time) {
                  setState(() => _selectedDate = time);
                },
              ),
              const SizedBox(height: 24),

              // button
              Consumer<EventNotifier>(
                builder: (context, notifier, child) {
                  bool loading = notifier.createEventState == ProviderState.loading 
                          || notifier.editEventState == ProviderState.loading;
                  
                  return ItineraryButton(
                    label: loading 
                          ? 'Memuat' 
                          : (widget.event != null) 
                                ? 'update' 
                                : 'Submit',
                    action: _validForm() && !loading
                          ? () => _createEvent()
                          : null,
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