import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeRetrieval {
  Timestamp createNewTimestamp(Timestamp timestamp, TimeOfDay timeOfDay) {
    final Timestamp newTimestamp = Timestamp.fromDate(DateTime(
        timestamp.toDate().year,
        timestamp.toDate().month,
        timestamp.toDate().day,
        timeOfDay.hour,
        timeOfDay.minute));
    return newTimestamp;
  }

  TimeOfDay stringToTimeOfDay(String time) {
    final DateFormat format = DateFormat.jm(); //"6:00 AM"

    return TimeOfDay.fromDateTime(format.parse(time));
  }
}
