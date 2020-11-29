import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_webservice/places.dart';

import 'locator.dart';

class TCFunctions {

  var userService = locator<UserService>();


  int calculateTimeDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  String AppReviewDocID() {
    DateTime now = DateTime.now();
    return DateFormat('yM').format(now).replaceAll('/', 'x');
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
    // print(_idList);
    return _idList;
  }

  dynamic getLocation(dynamic lat, dynamic lng){
    return Location(lat,lng);
  }

}