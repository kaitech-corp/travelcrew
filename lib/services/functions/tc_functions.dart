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
    final format = DateFormat.jm(); //"6:00 AM"

    return TimeOfDay.fromDateTime(format.parse(time));
  }
  
  Event createEvent(
      {ActivityData activity,
      DateTimeModel timeModel,
      LodgingData lodging,
      String type}){

    if(type == "Activity") {
      Event event = Event(
        title: activity.activityType,
        description: activity.comment,
        location: activity.location,
        startDate: timeModel.startDate,
        endDate: timeModel.endDate,
      );
      return event;
    } else{
      Event event = Event(
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

        DateTime _startDate = DateTime(
            _startDateX.toDate().year,
            _startDateX.toDate().month,
            _startDateX.toDate().day,
            _startTime.hour,
            _startTime.minute
        );
        DateTime _endDate = DateTime(
            _endDateX.toDate().year,
            _endDateX.toDate().month,
            _endDateX.toDate().day,
            _endTime.hour,
            _endTime.minute
        );
        return DateTimeModel(endDate: _endDate,startDate: _startDate);
      } catch (e) {
        TimeOfDay _startTime = TimeOfDay.now();
        TimeOfDay _endTime = TimeOfDay.now();
        Timestamp _startDateX = Timestamp.now();
        Timestamp _endDateX = Timestamp.now();

        DateTime _startDate = DateTime(
            _startDateX.toDate().year,
            _startDateX.toDate().month,
            _startDateX.toDate().day,
            _startTime.hour,
            _startTime.minute
        );
        DateTime _endDate = DateTime(
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


        DateTime _startDate = DateTime(
            _startDateX.toDate().year,
            _startDateX.toDate().month,
            _startDateX.toDate().day,
            _startTime.hour,
            _startTime.minute
        );
        DateTime _endDate = DateTime(
            _endDateX.toDate().year,
            _endDateX.toDate().month,
            _endDateX.toDate().day,
            _endTime.hour,
            _endTime.minute
        );
        return DateTimeModel(endDate: _endDate,startDate: _startDate);
      } catch (e) {
        TimeOfDay _startTime = TimeOfDay.now();
        TimeOfDay _endTime = TimeOfDay.now();
        Timestamp _startDateX = Timestamp.now();
        Timestamp _endDateX = Timestamp.now();

        DateTime _startDate = DateTime(
            _startDateX.toDate().year,
            _startDateX.toDate().month,
            _startDateX.toDate().day,
            _startTime.hour,
            _startTime.minute
        );
        DateTime _endDate = DateTime(
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
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  String appReviewDocID() {
    DateTime now = DateTime.now();
    return DateFormat('yM').format(now).replaceAll('/', 'x');
  }

  String dateToMonthDay(String dateTime){
    return dateTime.split(',')[0];
  }

  String dateToMonthDayFromTimestamp(Timestamp timestamp){
    var dateTime = formatTimestamp(timestamp, wTime: false);
    return dateTime.split(',')[0];
  }

  CountDownDate dateGauge(int dateCreatedTimeStamp, int startDateTimeStamp){
    var now = new DateTime.now();
    var createdDate = new DateTime.fromMillisecondsSinceEpoch(dateCreatedTimeStamp);
    var startDate = new DateTime.fromMillisecondsSinceEpoch(startDateTimeStamp);
    var daysLeft = (startDate.difference(now).inDays > 0) ? (startDate.difference(now).inHours/24.0).ceil().toDouble() : 0.0;
    var initialDayCount = startDate.difference(createdDate).inDays.toDouble();
    var gaugeCount = initialDayCount - daysLeft;
    gaugeCount = (gaugeCount>0) ? gaugeCount : initialDayCount;
    return CountDownDate(
      daysLeft: daysLeft,
      initialDayCount: initialDayCount,
      gaugeCount: gaugeCount,
    );
  }

  String checkDate(int startDateTimeStamp, int endDateTimeStamp){
    var now = new DateTime.now();
    var startDate = DateTime.fromMillisecondsSinceEpoch(startDateTimeStamp);
    var endDate = DateTime.fromMillisecondsSinceEpoch(endDateTimeStamp);
    if(startDate.difference(now).inDays > 0){
      return 'before';
    } else if(endDate.difference(now).inDays > 0){
      return 'during';
    } else{
      return 'after';
    }
  }

  String readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var format = new DateFormat('HH:mm a');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = date.difference(now);
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

  String createChatDoc(String x, String y){
    var _userList = [x,y];
    _userList.sort();
    String _docID = '${_userList[0]}_${_userList[1]}';
    return _docID;
  }

  List<String> splitDocID(List<String> x){
    var _idList = [];
    x.forEach((id) {
      var _y = id.split('_');
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
      var format = new DateFormat('yMMMd');
      var format2 = new DateFormat('yMMMd').add_jm();
      var date = new DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
      return (wTime) ? format2.format(date) : format.format(date);
    } catch (e) {
      CloudFunction().logError('Error formatting timestamp: ${e.toString()}');
      return '';
    }
  }

}