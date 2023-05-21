import 'package:flutter/material.dart';

import '../theme/text_styles.dart';
import 'appearance_widgets.dart';

class TimePickers extends StatefulWidget {
  const TimePickers({
    Key? key,
    required this.lodging,
    required this.startTime,
    required this.endTime,
  }) : super(key: key);

  final bool lodging;
  final ValueNotifier<TimeOfDay> startTime;
  final ValueNotifier<TimeOfDay> endTime;

  @override
  _TimePickersState createState() => _TimePickersState();
}

class _TimePickersState extends State<TimePickers> {
  late TimeOfDay timeStart;
  late TimeOfDay timeEnd;

  @override
  void initState() {
    timeStart = widget.lodging
        ? const TimeOfDay(hour: 15, minute: 0)
        : const TimeOfDay(hour: 9, minute: 0);
    timeEnd = widget.lodging
        ? const TimeOfDay(hour: 11, minute: 0)
        : const TimeOfDay(hour: 15, minute: 0);
    super.initState();
  }

  Future<void> showTimePickerDialog(BuildContext context, bool isStartTime) async {
    final TimeOfDay initialTime = isStartTime ? timeStart : timeEnd;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null && picked != initialTime) {
      setState(() {
        if (isStartTime) {
          timeStart = picked;
          widget.startTime.value = picked;
        } else {
          timeEnd = picked;
          widget.endTime.value = picked;
        }
      });
    }
  }

  Widget _timePickerRow(String labelText, IconData icon, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              TripDetailsIconThemeWidget(icon: icon),
              const SizedBox(width: 8),
              Text(labelText, style: titleMedium(context)),
            ],
          ),
        ),
        ButtonTheme(
          minWidth: 150,
          child: ElevatedButton(
            onPressed: onPressed,
            child: Text(labelText),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _timePickerRow(
          timeStart.format(context),
          Icons.access_time,
          () => showTimePickerDialog(context, true),
        ),
        _timePickerRow(
          timeEnd.format(context),
          Icons.access_time,
          () => showTimePickerDialog(context, false),
        ),
      ],
    );
  }
}
