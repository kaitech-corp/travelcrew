// ignore_for_file: only_throw_errors

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/theme/text_styles.dart';
import '../../../size_config/size_config.dart';
import '../../models/chat_model/chat_model.dart';
import '../Alerts/alert_dialogs.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    Key? key,
    required this.message,
    required this.tripDocID,
  }) : super(key: key);

  final ChatModel message;
  final String tripDocID;

  Future<void> _copyMessage(BuildContext context) async {
    await FlutterClipboard.copy(message.message);
    TravelCrewAlertDialogs().copiedToClipboardDialog(context);
    navigationService.pop();
  }

  void _deleteMessage(BuildContext context) {
    CloudFunction().deleteChatMessage(tripDocID: tripDocID, fieldID: message.fieldID);
    navigationService.pop();
  }

  Widget _buildContextMenu(BuildContext context) {
    return Container(
      height: SizeConfig.screenHeight * 0.3,
      width: SizeConfig.screenWidth,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          OutlinedButton(
            onPressed: () => _copyMessage(context),
            child: Text(
              'Copy',
              style: titleMedium(context),
            ),
          ),
          OutlinedButton(
            onPressed: () => _deleteMessage(context),
            child: Text(
              'Delete',
              style: titleMedium(context),
            ),
          ),
          const SizedBox(width: 15),
          OutlinedButton(
            onPressed: navigationService.pop,
            child: Text(
              'Close',
              style: titleMedium(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        message.uid == userService.currentUserID ? 80 : 5,
        5,
        message.uid == userService.currentUserID ? 5 : 80,
        5,
      ),
      decoration: BoxDecoration(
        color: message.uid == userService.currentUserID ? Colors.lightBlue[100] : Colors.grey[300],
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: message.uid == userService.currentUserID ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(5, 5, 10, 5),
            child: Linkify(
              onOpen: (LinkableElement link) async {
                if (await canLaunchUrl(Uri(path: link.url))) {
                  await launchUrl(Uri(path: link.url));
                } else {
                  throw 'Could not launch ${link.url}';
                }
              },
              text: message.message,
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Cantata One',
                fontSize: 18.0,
              ),
              maxLines: 50,
              overflow: TextOverflow.ellipsis,
              linkStyle: const TextStyle(color: Colors.blue),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Text(
              TCFunctions().chatViewGroupByDateTimeOnlyTime(message.timestamp),
              textScaleFactor: 0.75,
              style: const TextStyle(
                color: Colors.black,
                fontStyle: FontStyle.italic,
                fontFamily: 'Cantata One',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return message.uid == userService.currentUserID
        ? GestureDetector(
            key: Key(message.fieldID),
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            onLongPress: () {
              showBottomSheet(
                context: context,
                builder: (BuildContext context) => _buildContextMenu(context),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _buildChatBubble(context),
              ],
            ),
          )
        : InkWell(
            key: Key(message.fieldID),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildChatBubble(context),
              ],
            ),
          );
  }
}
