import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_places_flutter/model/place_details.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/custom_objects.dart';
import '../../services/functions/cloud_functions.dart';
import '../locator.dart';

class TCFunctions {
  UserService userService = locator<UserService>();

  int calculateTimeDifference(DateTime date) {
    final DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
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
    final String dateTime = formatTimestampTimeOnly(timestamp);
    // print(dateTime);
    return dateTime;
  }

  String dateToYearMonthFromTimestamp(Timestamp timestamp) {
    final String dateTime = formatTimestampYM(timestamp, wTime: false);
    // print(dateTime);
    return dateTime.split(',')[0];
  }

  CountDownDate dateGauge(int dateCreatedTimeStamp, int startDateTimeStamp) {
    final DateTime now = DateTime.now();
    final DateTime createdDate =
        DateTime.fromMillisecondsSinceEpoch(dateCreatedTimeStamp);
    final DateTime startDate =
        DateTime.fromMillisecondsSinceEpoch(startDateTimeStamp);
    final double daysLeft = (startDate.difference(now).inDays > 0)
        ? (startDate.difference(now).inHours / 24.0).ceil().toDouble()
        : 0.0;
    final double initialDayCount =
        startDate.difference(createdDate).inDays.toDouble();
    double gaugeCount = initialDayCount - daysLeft;
    gaugeCount = (gaugeCount > 0) ? gaugeCount : initialDayCount;
    return CountDownDate(
      daysLeft: daysLeft,
      initialDayCount: initialDayCount,
      gaugeCount: gaugeCount,
    );
  }

  String checkDate(int startDateTimeStamp, int endDateTimeStamp) {
    final DateTime now = DateTime.now();
    final DateTime startDate =
        DateTime.fromMillisecondsSinceEpoch(startDateTimeStamp);
    final DateTime endDate =
        DateTime.fromMillisecondsSinceEpoch(endDateTimeStamp);
    if (startDate.difference(now).inDays > 0) {
      return 'before';
    } else if (endDate.difference(now).inDays > 0) {
      return 'during';
    } else {
      return 'after';
    }
  }

  String readTimestamp(int timestamp) {
    final DateTime now = DateTime.now();
    final DateFormat format = DateFormat('HH:mm a');
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final Duration diff = date.difference(now);
    String time = '';
    if (diff.inDays == 0) {
      time = format.format(date);
    } else {
      if ((diff.inDays).abs() == 1) {
        time = '1 DAY AGO';
      } else {
        time = '${(diff.inDays).abs()} DAYS AGO';
      }
    }

    return time;
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
    final List<String> userList = [x, y];
    userList.sort();
    final String docID = '${userList[0]}_${userList[1]}';
    return docID;
  }

  List<String> splitDocID(List<String> x) {
    final List<String> idList = [];
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
      CloudFunction().logError('Error formatting timestamp: ${e.toString()}');
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
      CloudFunction().logError('Error formatting timestamp: ${e.toString()}');
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
      CloudFunction().logError('Error formatting timestamp: ${e.toString()}');
      return '';
    }
  }

  List<int> randomList() {
    final Random random = Random();
    final List<int> x =
        List<int>.generate(5, (int index) => random.nextInt(28));
    return x;
  }
}
