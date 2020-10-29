import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/size_config/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatMessageLayout extends StatelessWidget {
  var userService = locator<UserService>();
  final ChatData message;
  final String tripDocID;

  ChatMessageLayout({this.message, this.tripDocID});

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
                        CloudFunction().deleteChatMessage(tripDocID: tripDocID, fieldID: message.fieldID);
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
      child: Container(
          decoration: BoxDecoration(
            color: Colors.lightBlue[100],
          ),
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
                    Text(message.displayName ?? '',style: Theme.of(context).textTheme.subtitle2,),
                    Container(
                      margin: const EdgeInsets.all(5.0),
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
                      // Text(message.message ?? '',style: Theme.of(context).textTheme.subtitle1, maxLines: 50, overflow: TextOverflow.ellipsis, textScaleFactor: 1.2),
                    ),
                    Text(readTimestamp(message.timestamp.millisecondsSinceEpoch ?? ''), textScaleFactor: .75,style: Theme.of(context).textTheme.headline6,),
                  ],
                ),
              )
            ],
          )
      ),
    ) :
    InkWell(
      key: Key(message.fieldID),
      child: Container(
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
                     Text(message.displayName ?? '',style: Theme.of(context).textTheme.subtitle2,),
                     Container(
                      margin: const EdgeInsets.all(5.0),
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
                    Text(readTimestamp(message.timestamp.millisecondsSinceEpoch ?? ''), textScaleFactor: .75,style: Theme.of(context).textTheme.headline6,),
                  ],
                ),
              )
            ],
          )
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