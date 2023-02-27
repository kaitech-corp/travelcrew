import 'package:flutter/material.dart';

import '../theme/text_styles.dart';
import 'appearance_widgets.dart';

class TimePickers extends StatefulWidget {
  const TimePickers(
      {Key? key,
      required this.lodging,
      required this.startTime,
      required this.endTime})
      : super(key: key);

  final bool lodging;
  final ValueNotifier<TimeOfDay> startTime;
  final ValueNotifier<TimeOfDay> endTime;

  @override
  State<TimePickers> createState() => _TimePickersState();
}

class _TimePickersState extends State<TimePickers> {
  late TimeOfDay timeStart;
  late TimeOfDay timeEnd;

  @override
  void initState() {
    timeStart = widget.lodging
        ? TimeOfDay.fromDateTime(DateTime.utc(2021, 1, 1, 15))
        : TimeOfDay.fromDateTime(DateTime.utc(2021, 1, 1, 9));
    timeEnd = widget.lodging
        ? TimeOfDay.fromDateTime(DateTime.utc(2021, 1, 1, 11))
        : TimeOfDay.fromDateTime(DateTime.utc(2021, 1, 1, 15));
    super.initState();
  }

  String get _labelTextTimeStart {
    final String startTime = timeStart.format(context);
    widget.startTime.value = timeStart;
    return startTime;
  }

  String get _labelTextTimeEnd {
    final String endTime = timeEnd.format(context);
    widget.endTime.value = timeEnd;
    return endTime;
  }

  Future<void> showTimePickerStart(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: timeStart,
    );
    if (picked != null && picked != timeStart) {
      setState(() {
        timeStart = picked;
      });
    }
  }

  Future<void> showTimePickerEnd(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: timeEnd,
    );
    if (picked != null && picked != timeEnd) {
      setState(() {
        timeEnd = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  const TripDetailsIconThemeWidget(
                    icon: Icons.access_time,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    _labelTextTimeStart,
                    style: titleMedium(context),
                  ),
                ],
              ),
            ),
//                                SizedBox(height: 16),
            ButtonTheme(
              minWidth: 150,
              child: ElevatedButton(
                child: widget.lodging
                    ? const Text('Check In')
                    : const Text(
                        'Start Time',
                      ),
                onPressed: () async {
                  showTimePickerStart(context);
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  const TripDetailsIconThemeWidget(
                    icon: Icons.access_time,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    _labelTextTimeEnd,
                    style: titleMedium(context),
                  ),
                ],
              ),
            ),
//                                SizedBox(height: 16),
            ButtonTheme(
              minWidth: 150,
              child: ElevatedButton(
                child: widget.lodging
                    ? const Text('Checkout')
                    : const Text(
                        'End Time',
                      ),
                onPressed: () {
                  showTimePickerEnd(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
