import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/text_styles.dart';
import 'appearance_widgets.dart';

class CalendarWidget  extends StatefulWidget{

  const CalendarWidget(
      {Key? key,  this.startDate,
        this.endDate,
        required this.startDateTimeStamp,
        required this.endDateTimeStamp,
        this.context, required this.showBoth}) : super(key: key);

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
    return DateFormat.yMMMd().format(_fromDateDepart);
  }
  String get labelTextReturn {
    widget.endDate?.value = DateFormat.yMMMd().format(_fromDateReturn);
    widget.endDateTimeStamp.value = _fromDateReturn;
    return DateFormat.yMMMd().format(_fromDateReturn);
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
    return widget.showBoth ? Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  const TripDetailsIconThemeWidget(icon: Icons.calendar_today,),
                  const SizedBox(width: 8,),
                  Text(labelTextDepart,style: titleMedium(context),),
                ],
              ),
            ),
//                                SizedBox(height: 16),
            ButtonTheme(
              minWidth: 150,
              child: ElevatedButton(
                child: const Text(
                  'Start Date',
                ),
                onPressed: () async {
                  showDatePickerDepart();
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
                  const TripDetailsIconThemeWidget(icon: Icons.calendar_today,),
                  const SizedBox(width: 8,),
                  Text(labelTextReturn,style: titleMedium(context),),
                ],
              ),
            ),
//                                SizedBox(height: 16),
            ButtonTheme(
              minWidth: 150,
              child: ElevatedButton(
                child: const Text(
                  'End  Date',
                ),
                onPressed: () {
                  showDatePickerReturn();
                },
                //
              ),
            ),
          ],
        ),
      ],
    ):
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              const TripDetailsIconThemeWidget(icon: Icons.calendar_today,),
              const SizedBox(width: 8,),
              Text(labelTextDepart,style: titleMedium(context),),
            ],
          ),
        ),
//                                SizedBox(height: 16),
        ButtonTheme(
          minWidth: 150,
          child: IconButton(
            icon: const IconThemeWidget(icon: Icons.edit,),
            onPressed: () async {
              showDatePickerDepart();
            },
          ),
        ),
      ],
    );
  }
}
