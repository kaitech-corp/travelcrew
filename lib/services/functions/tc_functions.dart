import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travelcrew/models/activity_model.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/lodging_model.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_webservice/places.dart';
import '../locator.dart';

class TCFunctions {

  var userService = locator<UserService>();

  TimeOfDay stringToTimeOfDay(String time) {
    final DateFormat format = DateFormat.jm(); //"6:00 AM"

    return TimeOfDay.fromDateTime(format.parse(time));
  }
  
  Event createEvent(
      {ActivityData activity,
      DateTimeModel timeModel,
      LodgingData lodging,
      String type}){

    if(type == 'Activity') {
      final Event event = Event(
        title: activity.activityType,
        description: activity.comment,
        location: activity.location,
        startDate: timeModel.startDate,
        endDate: timeModel.endDate,
      );
      return event;
    } else{
      final Event event = Event(
        title: lodging.lodgingType,
        description: lodging.comment,
        location: lodging.location,
        startDate: timeModel.startDate,
        endDate: timeModel.endDate,
        // allDay: true,
      );
      return event;
    }

  }


  DateTimeModel addDateAndTime(
      {Timestamp startDate,
      Timestamp endDate,
      String startTime,
      String endTime,
      bool hasEndDate}){

    if(hasEndDate){
      try {
        TimeOfDay _startTime = TimeOfDay.now();
        TimeOfDay _endTime = TimeOfDay.now();
        Timestamp _startDateX = Timestamp.now();
        Timestamp _endDateX = Timestamp.now();

        _startTime = stringToTimeOfDay(startTime) ?? TimeOfDay.now();
        _endTime = stringToTimeOfDay(endTime) ?? TimeOfDay.now();

        _startDateX = startDate ?? Timestamp.now();
        _endDateX = endDate ?? Timestamp.now();

        final DateTime _startDate = DateTime(
            _startDateX.toDate().year,
            _startDateX.toDate().month,
            _startDateX.toDate().day,
            _startTime.hour,
            _startTime.minute
        );
        final DateTime _endDate = DateTime(
            _endDateX.toDate().year,
            _endDateX.toDate().month,
            _endDateX.toDate().day,
            _endTime.hour,
            _endTime.minute
        );
        return DateTimeModel(endDate: _endDate,startDate: _startDate);
      } catch (e) {
        final TimeOfDay _startTime = TimeOfDay.now();
        final TimeOfDay _endTime = TimeOfDay.now();
        final Timestamp _startDateX = Timestamp.now();
        final Timestamp _endDateX = Timestamp.now();

        final DateTime _startDate = DateTime(
            _startDateX.toDate().year,
            _startDateX.toDate().month,
            _startDateX.toDate().day,
            _startTime.hour,
            _startTime.minute
        );
        final DateTime _endDate = DateTime(
            _endDateX.toDate().year,
            _endDateX.toDate().month,
            _endDateX.toDate().day,
            _endTime.hour,
            _endTime.minute
        );
        return DateTimeModel(endDate: _endDate,startDate: _startDate);
      }
    } else {
      try {
        TimeOfDay _startTime = TimeOfDay.now();
        TimeOfDay _endTime = TimeOfDay.now();
        Timestamp _startDateX = Timestamp.now();
        Timestamp _endDateX = Timestamp.now();

        _startTime = stringToTimeOfDay(startTime) ?? TimeOfDay.now();
        _endTime = stringToTimeOfDay(endTime) ?? TimeOfDay.now();
        _startDateX = startDate;
        _endDateX = startDate;


        final DateTime _startDate = DateTime(
            _startDateX.toDate().year,
            _startDateX.toDate().month,
            _startDateX.toDate().day,
            _startTime.hour,
            _startTime.minute
        );
        final DateTime _endDate = DateTime(
            _endDateX.toDate().year,
            _endDateX.toDate().month,
            _endDateX.toDate().day,
            _endTime.hour,
            _endTime.minute
        );
        return DateTimeModel(endDate: _endDate,startDate: _startDate);
      } catch (e) {
        final TimeOfDay _startTime = TimeOfDay.now();
        final TimeOfDay _endTime = TimeOfDay.now();
        final Timestamp _startDateX = Timestamp.now();
        final Timestamp _endDateX = Timestamp.now();

        final DateTime _startDate = DateTime(
            _startDateX.toDate().year,
            _startDateX.toDate().month,
            _startDateX.toDate().day,
            _startTime.hour,
            _startTime.minute
        );
        final DateTime _endDate = DateTime(
            _endDateX.toDate().year,
            _endDateX.toDate().month,
            _endDateX.toDate().day,
            _endTime.hour,
            _endTime.minute
        );
        return DateTimeModel(endDate: _endDate,startDate: _startDate);
      }
    }
  }


  int calculateTimeDifference(DateTime date) {
    final DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  String appReviewDocID() {
    final DateTime now = DateTime.now();
    if(now.month < 6){
      return '${DateFormat('y').format(now)}first';
    } else{
      return '${DateFormat('y').format(now)}second';
    }
  }

  String dateToMonthDay(String dateTime){
    return dateTime.split(',')[0];
  }

  String dateToMonthDayFromTimestamp(Timestamp timestamp){
    final String dateTime = formatTimestamp(timestamp, wTime: false);
    return dateTime.split(',')[0];
  }
  String chatViewGroupByDateTime(Timestamp timestamp){
    final String dateTime = formatTimestamp(timestamp, wTime: true);
    return dateTime;
  }

  String chatViewGroupByDateTimeOnlyTime(Timestamp timestamp){
    final String dateTime = formatTimestampTimeOnly(timestamp);
    // print(dateTime);
    return dateTime;
  }



  String dateToYearMonthFromTimestamp(Timestamp timestamp){
    final String dateTime = formatTimestampYM(timestamp, wTime: false);
    // print(dateTime);
    return dateTime.split(',')[0];
  }

  CountDownDate dateGauge(int dateCreatedTimeStamp, int startDateTimeStamp){
    final DateTime now = DateTime.now();
    final DateTime createdDate = DateTime
        .fromMillisecondsSinceEpoch(dateCreatedTimeStamp);
    final DateTime startDate = DateTime
        .fromMillisecondsSinceEpoch(startDateTimeStamp);
    final double daysLeft = (startDate.difference(now).inDays > 0)
        ? (startDate.difference(now).inHours/24.0).ceil().toDouble()
        : 0.0;
    final double initialDayCount = startDate
        .difference(createdDate).inDays.toDouble();
    var gaugeCount = initialDayCount - daysLeft;
    gaugeCount = (gaugeCount>0)
        ? gaugeCount
        : initialDayCount;
    return CountDownDate(
      daysLeft: daysLeft,
      initialDayCount: initialDayCount,
      gaugeCount: gaugeCount,
    );
  }

  String checkDate(int startDateTimeStamp, int endDateTimeStamp){
    final DateTime now = DateTime.now();
    final DateTime startDate = DateTime
        .fromMillisecondsSinceEpoch(startDateTimeStamp);
    final DateTime endDate = DateTime
        .fromMillisecondsSinceEpoch(endDateTimeStamp);
    if(startDate.difference(now).inDays > 0){
      return 'before';
    } else if(endDate.difference(now).inDays > 0){
      return 'during';
    } else{
      return 'after';
    }
  }

  String readTimestamp(int timestamp) {
    final DateTime now = DateTime.now();
    final DateFormat format = DateFormat('HH:mm a');
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final Duration diff = date.difference(now);
    var time = '';
    if (diff.inDays == 0) {
      time = format.format(date);
    } else {
      if ((diff.inDays).abs() == 1) {
        time = '1 DAY AGO';
      } else {
        time = (diff.inDays).abs().toString() + ' DAYS AGO';
      }
    }

    return time;
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  dynamic launchURL2(String url) async {
    if (await canLaunch(url)) {
      return await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String createChatDoc(String x, String y){
    final _userList = [x,y];
    _userList.sort();
    final String _docID = '${_userList[0]}_${_userList[1]}';
    return _docID;
  }

  List<String> splitDocID(List<String> x){
    final _idList = [];
    x.forEach((id) {
      final _y = id.split('_');
      _y.remove(userService.currentUserID);
      _idList.add(_y[0]);
    });
    return _idList;
  }

  dynamic getLocation(dynamic lat, dynamic lng){
    return Location(lat: lat, lng: lng);
  }

  String formatTimestamp (Timestamp timestamp, {bool wTime}){
    try {
      final DateFormat format = DateFormat('yMMMd');
      final DateFormat format2 = DateFormat('yMMMd').add_jm();
      final DateTime date = DateTime
          .fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
      return wTime ? format2.format(date) : format.format(date);
    } catch (e) {
      CloudFunction().logError('Error formatting timestamp: ${e.toString()}');
      return '';
    }
  }

  String formatTimestampTimeOnly (Timestamp timestamp){
    try {
      final DateFormat format = DateFormat.jm();

      final DateTime date = DateTime
          .fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
      return format.format(date);
    } catch (e) {
      CloudFunction().logError('Error formatting timestamp: ${e.toString()}');
      return '';
    }
  }

  String formatTimestampYM (Timestamp timestamp, {bool wTime}){
    try {
      final DateFormat format = DateFormat('yMMM');
      final DateFormat format2 = DateFormat('yMMM').add_jm();
      final DateTime date = DateTime
          .fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
      return wTime ? format2.format(date) : format.format(date);
    } catch (e) {
      CloudFunction().logError('Error formatting timestamp: ${e.toString()}');
      return '';
    }
  }

}