import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'appearance_widgets.dart';

class CalendarWidget  extends StatefulWidget{

  final ValueNotifier<String>? startDate;
  final ValueNotifier<String>? endDate;
  final ValueNotifier<Timestamp> startDateTimeStamp;
  final ValueNotifier<Timestamp> endDateTimeStamp;
  final BuildContext? context;
  final bool showBoth;

  CalendarWidget(
      { this.startDate,
        this.endDate,
        required this.startDateTimeStamp,
        required this.endDateTimeStamp,
        this.context, required this.showBoth});

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();

}
class _CalendarWidgetState extends State<CalendarWidget> {
  
  DateTime _fromDateDepart = DateTime.now();
  DateTime _fromDateReturn = DateTime.now();
  

  String get labelTextDepart {
    widget.startDate?.value = DateFormat.yMMMd().format(_fromDateDepart);
    widget.startDateTimeStamp.value = Timestamp.fromDate(_fromDateDepart);
    return DateFormat.yMMMd().format(_fromDateDepart);
  }
  String get labelTextReturn {
    widget.endDate?.value = DateFormat.yMMMd().format(_fromDateReturn);
    widget.endDateTimeStamp.value = Timestamp.fromDate(_fromDateReturn);
    return DateFormat.yMMMd().format(_fromDateReturn);
  }

  Future<void> showDatePickerDepart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDateDepart,
      firstDate: DateTime(2015, 1),
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDateReturn,
      firstDate: DateTime(2015, 1),
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
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    TripDetailsIconThemeWidget(icon: Icons.calendar_today,),
                    SizedBox(width: 8,),
                    Text(labelTextDepart,style: Theme.of(context).textTheme.subtitle1,),
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
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    TripDetailsIconThemeWidget(icon: Icons.calendar_today,),
                    SizedBox(width: 8,),
                    Text(labelTextReturn,style: Theme.of(context).textTheme.subtitle1,),
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
        ),
      ],
    ):
    Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                TripDetailsIconThemeWidget(icon: Icons.calendar_today,),
                SizedBox(width: 8,),
                Text(labelTextDepart,style: Theme.of(context).textTheme.subtitle1,),
              ],
            ),
          ),
//                                SizedBox(height: 16),
          ButtonTheme(
            minWidth: 150,
            child: IconButton(
              icon: IconThemeWidget(icon: Icons.edit,),
              onPressed: () async {
                showDatePickerDepart();
              },
            ),
          ),
        ],
      ),
    );
  }
}