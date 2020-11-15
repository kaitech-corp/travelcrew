import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/size_config/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

class DMChatMessageLayout extends StatelessWidget {
  var userService = locator<UserService>();
  final ChatData message;
  final UserProfile user;

  DMChatMessageLayout({this.message, this.user});

  @override
  Widget build(BuildContext context) {

    

    return message.uid == userService.currentUserID ? InkWell(
      key: Key(message.fieldID),
      onLongPress: (){
        showBottomSheet(
            context: context,
            builder: (context){
              return Container(
                height: SizeConfig.screenHeight * .2,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlineButton(
                      color: Colors.grey,
                      child: const Text('Delete',style: TextStyle(fontSize: 18),),
                      onPressed: (){
                        DatabaseService().deleteDMChatMessage(message: message);
                       Navigator.pop(context);
                      },
                    ),
                    OutlineButton(
                      color: Colors.grey,
                      child: const Text('Close',style: TextStyle(fontSize: 18),),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(80,5,5,5),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius:  BorderRadius.circular(15.0)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.fromLTRB(5.0,5.0,10.0,5.0),
                    child:  Linkify(
                      onOpen: (link) async{
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text: message.message ?? '',
                      style: Theme.of(context).textTheme.subtitle1,
                      textScaleFactor: 1.2,
                      maxLines: 50,
                      overflow: TextOverflow.ellipsis,
                      linkStyle: TextStyle(color: Colors.blue),
                      textAlign: TextAlign.left,
                    ),
                    // Text(message.message ?? '',style: Theme.of(context).textTheme.subtitle1, maxLines: 50, overflow: TextOverflow.ellipsis, textScaleFactor: 1.2),
                  ),
                  Container(
                      margin:EdgeInsets.all(10),
                      child: Text(readTimestamp(message.timestamp.millisecondsSinceEpoch ?? ''), textScaleFactor: .75,style: Theme.of(context).textTheme.headline6,)),
                ],
              )
          ),
        ],
      ),
    ) :
    InkWell(
      key: Key(message.fieldID),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.fromLTRB(5,5,80,5),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(15.0)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                   Container(
                     margin: const EdgeInsets.fromLTRB(10.0,5.0,5.0,5.0),
                    child:  Linkify(
                      onOpen: (link) async{
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text: message.message ?? '',
                      style: Theme.of(context).textTheme.subtitle1,
                      textScaleFactor: 1.2,
                      maxLines: 50,
                      overflow: TextOverflow.ellipsis,
                      linkStyle: TextStyle(color: Colors.blue),
                    ),
                    ),
                    // Text(message.message ?? '',style: Theme.of(context).textTheme.subtitle1, textScaleFactor: 1.2, maxLines: 50, overflow: TextOverflow.ellipsis,),
                  // ),
                  Container(
                      margin:EdgeInsets.all(10),
                      child: Text(readTimestamp(message.timestamp.millisecondsSinceEpoch ?? ''), textScaleFactor: .75,style: Theme.of(context).textTheme.headline6,)),
                ],
              )
          ),
        ],
      ),
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