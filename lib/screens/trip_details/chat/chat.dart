import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/chat/chat_list.dart';
import 'package:travelcrew/services/database.dart';


class Chat extends StatefulWidget {

  final Trip trip;
  Chat({this.trip});

  @override
  State<StatefulWidget> createState() {
    return _ChatState();
  }
}

class _ChatState extends State<Chat> {

  final TextEditingController _chatController = new TextEditingController();


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);
    DatabaseService(tripDocID: widget.trip.documentId, uid: user.uid).clearChatNotifications();
    String displayName = user.displayName;
    String uid = user.uid;

    return StreamProvider.value(
      value: DatabaseService(tripDocID: widget.trip.documentId).chatList,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Flexible(
                child: ChatList(tripDocID: widget.trip.documentId,)
            ),
            new Divider(
              height: 1.0,
            ),
            Container(
              decoration: new BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: IconTheme(
                data: new IconThemeData(color: Colors.blue),
                child: new Container(
                  margin: const EdgeInsets.fromLTRB(25, 0, 0, 25),
                  child: new Row(
                    children: <Widget>[
                      new Flexible(
                        child: new TextField(
                          decoration: new InputDecoration.collapsed(hintText: "Starts typing ..."),
                          controller: _chatController,
//                    onSubmitted: _handleSubmit,
                        ),
                      ),
                      new Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: new IconButton(
                          icon: new Icon(Icons.send),
                          onPressed: () async {
                            if (_chatController.text != '') {
                              String message = _chatController.text;
                              var status = createStatus();
                              _chatController.clear();
                              await DatabaseService(
                                  tripDocID: widget.trip.documentId)
                                  .addNewChatMessage(
                                  displayName, message, uid, status);
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
    );
  }
  createStatus() {
    final user = Provider.of<UserProfile>(context, listen: false);
    Map<String, bool> status = {};
    var users = widget.trip.accessUsers.where((f) => f != user.uid);

    users.forEach((f) => status[f] = false);
//    print(status.toList());
    return status;
  }
}

