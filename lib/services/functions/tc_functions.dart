import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_places_flutter/model/place_details.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/custom_objects.dart';
import '../../models/trip_model.dart';
import '../../services/functions/cloud_functions.dart';
import '../locator.dart';

class TCFunctions {
  UserService userService = locator<UserService>();

  int calculateTimeDifference(DateTime date) {
    final DateTime now = DateTime.now();
    return date.difference(now).inDays;
  }

  String appReviewDocID() {
    final DateTime now = DateTime.now();
    if (now.month < 6) {
      return '${DateFormat('y').format(now)}first';
    } else {
      return '${DateFormat('y').format(now)}second';
    }
  }

  String dateToMonthDay(String dateTime) {
    return dateTime.split(',')[0];
  }

  String dateToMonthDayFromTimestamp(Timestamp timestamp) {
    final String dateTime = formatTimestamp(timestamp, wTime: false);
    return dateTime.split(',')[0];
  }

  String chatViewGroupByDateTime(Timestamp timestamp) {
    final String dateTime = formatTimestamp(timestamp, wTime: true);
    return dateTime;
  }

  String chatViewGroupByDateTimeOnlyTime(Timestamp timestamp) {
    return formatTimestampTimeOnly(timestamp);
  }

  String dateToYearMonthFromTimestamp(Timestamp timestamp) {
    return formatTimestampYM(timestamp, wTime: false).split(',')[0];
  }

  String dateToMonthDayYear(String dateTime) {
    return '${dateTime.split(',')[0]} ${dateTime.split(',')[1]}';
  }

  CountDownDate dateGauge(int dateCreatedTimeStamp, int startDateTimeStamp) {
    final int nowMillis = DateTime.now().millisecondsSinceEpoch;
    final int daysLeft = (startDateTimeStamp - nowMillis) ~/ 86400000;
    final int initialDayCount =
        (startDateTimeStamp - dateCreatedTimeStamp) ~/ 86400000;
    final int gaugeCount = daysLeft - initialDayCount;
    return CountDownDate(
      daysLeft: daysLeft.toDouble(),
      initialDayCount: initialDayCount.toDouble(),
      gaugeCount: gaugeCount.toDouble(),
    );
  }
// This function returns a string that indicates whether today is before, after, 
// or during a given time frame specified by start and end times.
  String checkDate(int startDateTimeStamp, int endDateTimeStamp) {
    final int today = DateTime.now().millisecondsSinceEpoch;
    if (today < startDateTimeStamp) {
      return 'before';
    } else if (today > endDateTimeStamp) {
      return 'after';
    } else {
      return 'during';
    }
  }

  String readTimestamp(int timestamp) {
  final DateTime currentTime = DateTime.now();
  final DateTime timestampTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  
  final Duration difference = currentTime.difference(timestampTime);
  final int days = difference.inDays;
  final int hours = difference.inHours;
  
  if (days > 0) {
    return '$days days ago';
  } else {
    return '$hours hours ago';
  }
}

  Future<void> launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  dynamic launchURL2(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      return await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  String createChatDoc(String x, String y) {
    final List<String> userList = <String>[x, y];
    userList.sort();
    final String docID = '${userList[0]}_${userList[1]}';
    return docID;
  }

  List<String> splitDocID(List<String> x) {
    final List<String> idList = <String>[];
    for (final String id in x) {
      final List<String> y = id.split('_');
      y.remove(userService.currentUserID);
      idList.add(y[0]);
    }
    return idList;
  }

  dynamic getLocation(double lat, double lng) {
    return Location(lat: lat, lng: lng);
  }

  String formatTimestamp(Timestamp timestamp, {required bool wTime}) {
    try {
      final DateFormat format = DateFormat('yMMMd');
      final DateFormat format2 = DateFormat('yMMMd').add_jm();
      final DateTime date =
          DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
      return wTime ? format2.format(date) : format.format(date);
    } catch (e) {
      CloudFunction().logError('Error formatting timestamp: $e');
      return '';
    }
  }

  String formatTimestampTimeOnly(Timestamp timestamp) {
    try {
      final DateFormat format = DateFormat.jm();

      final DateTime date =
          DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
      return format.format(date);
    } catch (e) {
      CloudFunction().logError('Error formatting timestamp: $e');
      return '';
    }
  }

  String formatTimestampYM(Timestamp timestamp, {required bool wTime}) {
    try {
      final DateFormat format = DateFormat('yMMM');
      final DateFormat format2 = DateFormat('yMMM').add_jm();
      final DateTime date =
          DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
      return wTime ? format2.format(date) : format.format(date);
    } catch (e) {
      CloudFunction().logError('Error formatting timestamp: $e');
      return '';
    }
  }

  List<int> randomList() {
    final Random random = Random();
    final List<int> x =
        List<int>.generate(5, (int index) => random.nextInt(28));
    return x;
  }

List<Trip> getCurrentPrivateTrips(List<Trip> trips, bool past) {
  final DateTime today = DateTime.now();
  final List<Trip> output = <Trip>[];
  for (int i = 0; i < trips.length; i++) {
    if (past) {
      if (trips[i].endDateTimeStamp.toDate().isBefore(today)) {
        output.add(trips[i]);
      }
    } else {
      if (trips[i].endDateTimeStamp.toDate().isAfter(today)) {
        output.add(trips[i]);
      }
    }
  }
  return output;
}
}
