import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/chat_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../size_config/size_config.dart';
import '../../alerts/alert_dialogs.dart';

class ChatCard extends StatelessWidget {
  final ChatData message;
  final String tripDocID;

  ChatCard({required this.message, required this.tripDocID});

  @override
  Widget build(BuildContext context) {
    return message.uid == userService.currentUserID
        ? GestureDetector(
            key: Key(message.fieldID),
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            onLongPress: () {
              showBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      height: SizeConfig.screenHeight * .3,
                      width: SizeConfig.screenWidth,
                      color: Colors.grey.shade200,
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton(
                            // color: Colors.grey,
                            child: Text(
                              'Copy',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            onPressed: () {
                              FlutterClipboard.copy(message.message)
                                  .whenComplete(() => TravelCrewAlertDialogs()
                                      .copiedToClipboardDialog(context));
                              navigationService.pop();
                            },
                          ),
                          OutlinedButton(
                            // color: Colors.grey,
                            child: Text(
                              'Delete',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            onPressed: () {
                              CloudFunction().deleteChatMessage(
                                  tripDocID: tripDocID,
                                  fieldID: message.fieldID);
                              navigationService.pop();
                            },
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          OutlinedButton(
                            // color: Colors.grey,
                            child: Text(
                              'Close',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            onPressed: () {
                              navigationService.pop();
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
                    margin: EdgeInsets.fromLTRB(80, 5, 5, 5),
                    decoration: BoxDecoration(
                        color: Colors.lightBlue[100],
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(5.0, 5.0, 10.0, 5.0),
                          child: Linkify(
                            onOpen: (link) async {
                              if (await canLaunch(link.url)) {
                                await launch(link.url);
                              } else {
                                throw 'Could not launch $link';
                              }
                            },
                            text: message.message,
                            style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Cantata One',
                                fontSize: 18.0),
                            // textScaleFactor: 1.2,
                            maxLines: 50,
                            overflow: TextOverflow.ellipsis,
                            linkStyle: const TextStyle(color: Colors.blue),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: Text(
                                TCFunctions().chatViewGroupByDateTimeOnlyTime(
                                    message.timestamp),
                                textScaleFactor: .75,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'Cantata One'))),
                      ],
                    )),
              ],
            ),
          )
        : InkWell(
            key: Key(message.fieldID),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: const EdgeInsets.fromLTRB(5, 5, 80, 5),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            margin: const EdgeInsets.all(5),
                            child: Text(
                              message.displayName ?? '',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Cantata One'),
                            )),
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
                          child: Linkify(
                            onOpen: (link) async {
                              if (await canLaunch(link.url)) {
                                await launch(link.url);
                              } else {
                                throw 'Could not launch $link';
                              }
                            },
                            text: message.message ?? '',
                            style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Cantata One',
                                fontSize: 18.0),
                            // textScaleFactor: 1.2,
                            maxLines: 50,
                            overflow: TextOverflow.ellipsis,
                            linkStyle: const TextStyle(color: Colors.blue),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: Text(
                              TCFunctions().chatViewGroupByDateTimeOnlyTime(
                                  message.timestamp),
                              textScaleFactor: .75,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Cantata One'),
                            )),
                      ],
                    )),
              ],
            ),
          );
  }

  //
  String readTimestamp(int timestamp) {
    if (timestamp != null) {
      var now = new DateTime.now();
      var format = new DateFormat.jm();
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
    } else {
      return '';
    }
  }
}
