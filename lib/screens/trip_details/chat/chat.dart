import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/chat/chat_list.dart';
import 'package:travelcrew/services/appearance_widgets.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';


class Chat extends StatefulWidget {

  var userService = locator<UserService>();
  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  final Trip trip;
  Chat({this.trip});

  @override
  State<StatefulWidget> createState() {

    return _ChatState();
  }
}

class _ChatState extends State<Chat> {

  final TextEditingController _chatController = new TextEditingController();

  Future<void> clearChat(String uid) async {
    await DatabaseService(tripDocID: widget.trip.documentId, uid: uid).clearChatNotifications();

  }


  @override
  Widget build(BuildContext context) {
    clearChat(widget.userService.currentUserID);


    return StreamProvider.value(
      value: DatabaseService(tripDocID: widget.trip.documentId).chatList,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          body: Column(
            children: <Widget>[
              Flexible(
                  child: ChatList(tripDocID: widget.trip.documentId,)
              ),
              const Divider(
                height: 1.0,
              ),
              Container(
                decoration: new BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: IconTheme(
                  data: const IconThemeData(color: Colors.blue),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(25, 0, 0, 25),
                    child: new Row(
                      children: <Widget>[
                        new Flexible(
                          child: new TextField(
                            decoration: InputDecoration.collapsed(
                              fillColor: ReusableThemeColor().color(context),
                                hintText: "Start typing ..."),
                            controller: _chatController,
//                    onSubmitted: _handleSubmit,
                          textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        new Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: new IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () async {
                              if (_chatController.text != '') {
                                String message = _chatController.text;
                                var status = createStatus();
                                _chatController.clear();
                                String displayName = widget.currentUserProfile.displayName;
                                String uid = widget.userService.currentUserID;
                                try {
                                  String action = 'Saving new message for ${widget.trip.documentId}';
                                  CloudFunction().logEvent(action);
                                  await DatabaseService(
                                      tripDocID: widget.trip.documentId)
                                      .addNewChatMessage(
                                      displayName, message, uid, status);
                                } on Exception catch (e) {
                                  CloudFunction().logError(e.toString());
                                }
                              }
                            },
                          ),
                        )
                      ],
                    ),

                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  createStatus() {
    Map<String, bool> status = {};
    var users = widget.trip.accessUsers.where((f) => f != widget.userService.currentUserID);

    users.forEach((f) => status[f] = false);
//    print(status.toList());
    return status;
  }
}

