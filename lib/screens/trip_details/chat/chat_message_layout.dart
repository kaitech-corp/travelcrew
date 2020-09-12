import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';

class ChatMessageLayout extends StatelessWidget {
  final ChatData message;

// constructor to get text from textfield
  ChatMessageLayout({this.message});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);
    

    return message.uid == user.uid ? Container(
      
        decoration: BoxDecoration(
          color: Colors.lightBlue[100],
        ),
//        margin: const EdgeInsets.symmetric(vertical: 2.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
             Container(
              margin: const EdgeInsets.only(right: 16.0),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(message.displayName ?? '', textScaleFactor: .9, style: TextStyle(fontWeight: FontWeight.bold),),
                  Container(
                    margin: const EdgeInsets.all(5.0),
                    child:  Text(message.message ?? '', textScaleFactor: 1.2, maxLines: 50, overflow: TextOverflow.ellipsis,),
                  ),
                  Text(readTimestamp(message.timestamp.millisecondsSinceEpoch ?? ''), textScaleFactor: .75, style: TextStyle(fontStyle: FontStyle.italic),),
                ],
              ),
            )
          ],
        )
    ) :
    Container(
        decoration: BoxDecoration(

        ),
        margin: const EdgeInsets.symmetric(vertical: 2.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 16.0),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                   Text(message.displayName ?? '', textScaleFactor: .9, style: TextStyle(fontWeight: FontWeight.bold),),
                   Container(
                    margin: const EdgeInsets.all(5.0),
                    child:  Text(message.message ?? '', textScaleFactor: 1.2, maxLines: 50, overflow: TextOverflow.ellipsis,),
                  ),
                  Text(readTimestamp(message.timestamp.millisecondsSinceEpoch ?? ''), textScaleFactor: .75, style: TextStyle(fontStyle: FontStyle.italic),),
                ],
              ),
            )
          ],
        )
    );
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
}