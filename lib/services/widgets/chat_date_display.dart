import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../functions/tc_functions.dart';
import '../theme/text_styles.dart';

class ChatDateDisplay extends StatelessWidget{

  const ChatDateDisplay({Key? key, required this.dateString}) : super(key: key);

  final String dateString;



  @override
  Widget build(BuildContext context) {
    final DateTime dateTime = DateTime.parse(dateString);
    return dateTime.isToday() ?
    Text(
      TCFunctions().chatViewGroupByDateTimeOnlyTime(Timestamp.fromDate(dateTime)),
      style: titleSmall(context),textAlign: TextAlign.center,):
    Text(
      TCFunctions().chatViewGroupByDateTime(Timestamp.fromDate(dateTime)),
      style: titleSmall(context),textAlign: TextAlign.center,);
  }

}


class DateCheck{

} extension DateHelpers on DateTime {
  bool isToday() {
    final DateTime now = DateTime.now();
    return now.day == day &&
        now.month == month &&
        now.year == year;
  }
}
