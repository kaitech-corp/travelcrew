// ignore_for_file: only_throw_errors

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/chat_model.dart';
import '../../../../models/custom_objects.dart';
import '../../../../services/database.dart';
import '../../../../services/theme/text_styles.dart';
import '../../../../services/widgets/appearance_widgets.dart';
import '../../../../size_config/size_config.dart';
import '../../../alerts/alert_dialogs.dart';

class DMChatMessageLayout extends StatelessWidget {

  const DMChatMessageLayout({Key? key, required this.message, required this.user}) : super(key: key);
  final ChatData message;
  final UserPublicProfile user;

  @override
  Widget build(BuildContext context) {
    return message.uid == userService.currentUserID
        ? InkWell(
            key: Key(message.fieldID),
            onLongPress: () {
              showBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: SizeConfig.screenHeight * .3,
                      width: SizeConfig.screenWidth,
                      color: Colors.grey.shade200,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          OutlinedButton(
                            onPressed: () {
                              FlutterClipboard.copy(message.message)
                                  .whenComplete(() => TravelCrewAlertDialogs()
                                      .copiedToClipboardDialog(context));
                              navigationService.pop();
                            },
                            child: Text(
                              'Copy',
                              style: titleMedium(context),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              DatabaseService()
                                  .deleteDMChatMessage(message: message);
                              navigationService.pop();
                            },
                            child: Text(
                              'Delete',
                              style: titleMedium(context),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              navigationService.pop();
                            },
                            child: Text(
                              'Close',
                              style: titleMedium(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.fromLTRB(80, 5, 5, 5),
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
                            onOpen: (LinkableElement link) async {
                              if (await canLaunchUrl(Uri(path: link.url))) {
                                await launchUrl(Uri(path: link.url));
                              } else {
                                throw 'Could not launch ${link.url}';
                              }
                            },
                            text: message.message,
                            style: titleMedium(context),
                            // textScaleFactor: 1.2,
                            maxLines: 50,
                            overflow: TextOverflow.ellipsis,
                            linkStyle: const TextStyle(color: Colors.blue),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.all(10),
                            child: Text(
                              readTimestamp(
                                  message.timestamp.millisecondsSinceEpoch),
                              style: ChatTextStyle().timestampStyle(),
                              textScaleFactor: 0.75,
                            )),
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
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.fromLTRB(5, 5, 80, 5),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
                          child: Linkify(
                            onOpen: (LinkableElement link) async {
                              if (await canLaunchUrl(Uri(path: link.url))) {
                                await launchUrl(Uri(path: link.url));
                              } else {
                                throw 'Could not launch ${link.url}';
                              }
                            },
                            text: message.message,
                            style: titleMedium(context),
                            // textScaleFactor: 1.2,
                            maxLines: 50,
                            overflow: TextOverflow.ellipsis,
                            linkStyle: const TextStyle(color: Colors.blue),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.all(10),
                            child: Text(
                                readTimestamp(
                                    message.timestamp.millisecondsSinceEpoch),
                                style: ChatTextStyle().timestampStyle(),
                                textScaleFactor: 0.75)),
                      ],
                    )),
              ],
            ),
          );
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
}
