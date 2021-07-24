import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/menu_screens/users/dm_chat/dm_chat_list.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/database.dart';


class DMChat extends StatefulWidget {


  final UserPublicProfile user;
  DMChat({this.user});

  @override
  State<StatefulWidget> createState() {

    return _DMChatState();
  }
}

class _DMChatState extends State<DMChat> {

  final TextEditingController _chatController = new TextEditingController();
  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  Future<void> clearChat(String uid) async {
    await DatabaseService(userID: widget.user.uid).clearDMChatNotifications();
  }


  @override
  Widget build(BuildContext context) {

    clearChat(widget.user.uid);


    return StreamProvider.value(
      value: DatabaseService(userID: widget.user.uid).dmChatList,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.user.displayName,style: Theme.of(context).textTheme.headline5,overflow: TextOverflow.ellipsis,),
          ),
          body: Column(
            children: <Widget>[
              Flexible(
                  child: DMChatList(user: widget.user,)
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
                            decoration: new InputDecoration.collapsed(
                                hintText: "Start typing ...",
                              border: InputBorder.none,
                            ),
                            controller: _chatController,
                          textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: ChatTextStyle().messageStyle(),

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
                                String displayName = currentUserProfile.displayName;
                                String uid = userService.currentUserID;
                                await DatabaseService(
                                    userID: widget.user.uid)
                                    .addNewDMChatMessage(
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
      ),
    );
  }
  createStatus() {
    List<String> _members = [userService.currentUserID, widget.user.uid];
    Map<String, bool> status = {};
    var users = _members.where((f) => f != userService.currentUserID);
    users.forEach((f) => status[f] = false);
    return status;
  }
}

