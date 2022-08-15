import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';

class ChatDateDisplay extends StatelessWidget{

  final String dateString;

  const ChatDateDisplay({Key? key, required this.dateString}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(dateString);
    return dateTime.isToday() ?
    Text(
      TCFunctions().chatViewGroupByDateTimeOnlyTime(Timestamp.fromDate(dateTime)),
      style: Theme.of(context).textTheme.subtitle2,textAlign: TextAlign.center,):
    Text(
      TCFunctions().chatViewGroupByDateTime(Timestamp.fromDate(dateTime)),
      style: Theme.of(context).textTheme.subtitle2,textAlign: TextAlign.center,);
  }

}


class DateCheck{

} extension DateHelpers on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.day == this.day &&
        now.month == this.month &&
        now.year == this.year;
  }
}