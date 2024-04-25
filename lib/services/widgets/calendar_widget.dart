import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/constants.dart';
import '../theme/text_styles.dart';
import 'appearance_widgets.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget(
      {super.key,
      this.startDate,
      this.endDate,
      required this.startDateTimeStamp,
      required this.endDateTimeStamp,
      this.context,
      required this.showBoth});

  final ValueNotifier<String>? startDate;
  final ValueNotifier<String>? endDate;
  final ValueNotifier<DateTime> startDateTimeStamp;
  final ValueNotifier<DateTime> endDateTimeStamp;
  final BuildContext? context;
  final bool showBoth;

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _fromDateDepart = DateTime.now();
  DateTime _fromDateReturn = DateTime.now();

  String get labelTextDepart {
    widget.startDate?.value = DateFormat.yMMMd().format(_fromDateDepart);
    widget.startDateTimeStamp.value = _fromDateDepart;
    return DateFormat.yMd().format(_fromDateDepart);
  }

  String get labelTextReturn {
    widget.endDate?.value = DateFormat.yMMMd().format(_fromDateReturn);
    widget.endDateTimeStamp.value = _fromDateReturn;
    return DateFormat.yMd().format(_fromDateReturn);
  }

  Future<void> showDatePickerDepart() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDateDepart,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _fromDateDepart) {
      setState(() {
        _fromDateDepart = picked;
        _fromDateReturn = picked;
      });
    }
  }

  Future<void> showDatePickerReturn() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDateReturn,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _fromDateReturn) {
      setState(() {
        _fromDateReturn = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.showBoth
        ? Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        showDatePickerDepart();
                      },
                      child: Row(
                        children: <Widget>[
                          const TripDetailsIconThemeWidget(
                            icon: Icons.calendar_today,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            labelTextDepart,
                            style: titleMedium(context),
                          ),
                        ],
                      ),
                    ),
                    const Text('-'),
                    InkWell(
                      onTap: () {
                        showDatePickerReturn();
                      },
                      child: Row(
                        children: <Widget>[
                          const TripDetailsIconThemeWidget(
                            icon: Icons.calendar_today,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            labelTextReturn,
                            style: titleMedium(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
        )
        : InkWell(
            onTap: () {
              showDatePickerDepart();
            },
            child: Row(
              children: <Widget>[
                const TripDetailsIconThemeWidget(
                  icon: Icons.calendar_today,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  labelTextDepart,
                  style: titleMedium(context),
                ),
              ],
            ),
          );
  }
}
