
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';

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

  late TimePickerSpinnerController _pickerSpinnerController;

  late DateTime _selectedDate;

  String _messageValue = '';

  @override
  void initState() {
    super.initState();
    _saveEventNotifier = context.read<EventNotifier>();
    _pickerSpinnerController = TimePickerSpinnerController();
    _selectedDate = widget.selectedDate;

    _messageC = TextEditingController(text: widget.event?.title ?? '');
  }

  @override
  void dispose() {
    _reset();
    _messageC.dispose();
    _pickerSpinnerController.dispose();
    
    super.dispose();
  }

  void _reset(){
    _messageC.clear();
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

  void _showTimePicker(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),

    );

    if (selectedTime != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onSubmitted: (_) => _pickerSpinnerController.showMenu(),
              ),
              const SizedBox(height: 16),

              // pilih tanggal dan waktu
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
                            DateFormat('dd MMMM yyyy', 'id').format(widget.selectedDate),
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
                          child: Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.grey),
                            ),
                            child: InkWell(
                              onTap: () => _showTimePicker(context),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14, 
                                  horizontal: 12,
                                ),
                                child: Text.rich(
                                  textAlign: TextAlign.center,
                                  style: robotoRegular.copyWith(
                                    fontSize: 16,
                                  ),
                                  TextSpan(
                                    text: '${_selectedDate.hour}',
                                    children: [
                                      const TextSpan(text: ' : '),
                                      TextSpan(
                                        text: '${_selectedDate.minute}',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // button
              Consumer<EventNotifier>(
                builder: (context, notifier, child) {
                  bool validForm = _messageValue.isNotEmpty;
                  bool loading = notifier.createEventState == ProviderState.loading 
                          || notifier.editEventState == ProviderState.loading;
                  
                  return ItineraryButton(
                    label: loading 
                          ? 'Memuat' 
                          : (widget.event != null) 
                                ? 'update' 
                                : 'Submit',
                    action: validForm && !loading
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