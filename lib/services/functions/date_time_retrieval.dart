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

    String dateTimeToTimeOfDay(DateTime date) {
        final DateFormat timeFormat = DateFormat('h:mm a');
    return timeFormat.format(date);

  }
String formatDateTime(DateTime date) {
  if (date.year == DateTime.now().year &&
      date.month == DateTime.now().month &&
      date.day == DateTime.now().day) {
    return 'Today';
  } else if (date.year == DateTime.now().year &&
      date.month == DateTime.now().month &&
      date.day == DateTime.now().day + 1) {
    return 'Tomorrow';
  } else {
    return DateFormat('MM/dd/yyyy').format(date);
  }
}

String dateFormatter(DateTime startDate, DateTime endDate) {
  if (startDate.year == endDate.year &&
      startDate.month == endDate.month &&
      startDate.day == endDate.day) {
    return formatDateTime(startDate);
  } else {
    return '${formatDateTime(startDate)} - ${formatDateTime(endDate)}';
  }
}
}
