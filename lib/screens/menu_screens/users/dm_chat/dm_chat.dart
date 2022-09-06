import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/chat_model.dart';
import '../../../../models/custom_objects.dart';
import '../../../../services/database.dart';
import '../../../../services/locator.dart';
import '../../../../services/widgets/appearance_widgets.dart';
import 'dm_chat_list.dart';

class DMChat extends StatefulWidget {
  const DMChat({required this.user});
  final UserPublicProfile user;

  @override
  State<StatefulWidget> createState() {
    return _DMChatState();
  }
}

class _DMChatState extends State<DMChat> {
  final TextEditingController _chatController = TextEditingController();
  UserPublicProfile currentUserProfile =
      locator<UserProfileService>().currentUserProfileDirect();
  Future<void> clearChat(String uid) async {
    await DatabaseService(userID: widget.user.uid).clearDMChatNotifications();
  }

  @override
  Widget build(BuildContext context) {
    clearChat(widget.user.uid);

    return StreamProvider<List<ChatData>>.value(
      initialData:  <ChatData>[defaultChatData],
      value: DatabaseService(userID: widget.user.uid).dmChatList,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.user.displayName,
              style: Theme.of(context).textTheme.headline5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: Column(
            children: <Widget>[
              Flexible(
                  child: DMChatList(
                user: widget.user,
              )),
              const Divider(
                height: 1.0,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: IconTheme(
                  data: const IconThemeData(color: Colors.blue),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(25, 0, 0, 25),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: TextField(
                            decoration: const InputDecoration.collapsed(
                              hintText: 'Start typing ...',
                            ),
                            controller: _chatController,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: ChatTextStyle().messageStyle(),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () async {
                              if (_chatController.text != '') {
                                final String message = _chatController.text;
                                final Map<String, bool> status = createStatus();
                                _chatController.clear();
                                final String displayName =
                                    currentUserProfile.displayName;
                                final String uid = userService.currentUserID;
                                await DatabaseService(userID: widget.user.uid)
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

  Map<String, bool> createStatus() {
    final List<String> members = [userService.currentUserID, widget.user.uid];
    final Map<String, bool> status = {};
    final Iterable<String> users = members.where((String f) => f != userService.currentUserID);
    for (final String f in users) {
      status[f] = false;
    }
    return status;
  }
}
