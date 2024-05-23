import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_places_flutter/model/place_details.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../locator.dart';
import 'cloud_functions/admin_functions.dart';

class TCFunctions {
  UserService userService = locator<UserService>();

  int calculateTimeDifference(DateTime date) {
    final DateTime now = DateTime.now();
    return date.difference(now).inDays;
  }

  String calculateTimeDifferenceInDays(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) {
      return '';
    }
    final int differenceInDays = date2.difference(date1).inDays;

    return '${differenceInDays.abs() + 1} ${(differenceInDays.abs() + 1) == 1 ? 'Day' : 'Days'}';
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

  String tripCardDate(String startDateTime, String endDateTime) {
    if (startDateTime == endDateTime) {
      return dateToMonthDay(startDateTime);
    } else {
      return '${dateToMonthDay(startDateTime)} - $endDateTime';
    }
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
      AdminCloudFunction().logError('Error formatting timestamp: $e');
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
      AdminCloudFunction().logError('Error formatting timestamp: $e');
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
      AdminCloudFunction().logError('Error formatting timestamp: $e');
      return '';
    }
  }

  List<int> randomList() {
    final Random random = Random();
    final List<int> x =
        List<int>.generate(5, (int index) => random.nextInt(28));
    return x;
  }

  int getRandomIndex(List<dynamic> list) {
    final Random random = Random();
    return random.nextInt(list.length);
  }
}

///Model for count down date to show on trip page
class CountDownDate {
  CountDownDate({this.daysLeft, this.initialDayCount, this.gaugeCount});

  double? initialDayCount;
  double? daysLeft;
  double? gaugeCount;
}

String readTimestamp(DateTime timestamp) {
  final DateTime currentTime = DateTime.now();

  final Duration difference = currentTime.difference(timestamp);
  final int days = difference.inDays;
  final int hours = difference.inHours;
  final int minutes = difference.inMinutes;

  if (days > 1) {
    return '$days days ago';
  } else if (days == 1) {
    return '$days day ago';
  } else if (days < 1 && hours == 1) {
    return '$hours hour ago';
  } else if (days < 1 && hours < 1 && minutes == 1) {
    return '$minutes minute ago';
  } else if (days < 1 && hours < 1 && minutes < 1) {
    return 'Just now';
  } else if (days < 1 && hours < 1) {
    return '$minutes minutes ago';
  } else {
    return '$hours hours ago';
  }
}
