import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/blocs/chat_bloc/chat_bloc.dart';
import 'package:travelcrew/blocs/chat_bloc/chat_event.dart';
import 'package:travelcrew/blocs/chat_bloc/chat_state.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/size_config/size_config.dart';

import 'grouped_list_chat_builder.dart';

class ChatPage extends StatefulWidget {
  final Trip trip;
  ChatPage({this.trip});

  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  ChatBloc bloc;
  var currentUserProfile =
      locator<UserProfileService>().currentUserProfileDirect();
  final TextEditingController _chatController = TextEditingController();

  Future<void> clearChat(String uid) async {
    await DatabaseService(tripDocID: widget.trip.documentId, uid: uid)
        .clearChatNotifications();
  }

  @override
  void didChangeDependencies() {
    bloc = BlocProvider.of<ChatBloc>(context);
    bloc.add(LoadingChatData());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    clearChat(userService.currentUserID);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: SizedBox(
          height: SizeConfig.screenHeight,
          child: BlocBuilder<ChatBloc, ChatState>(builder: (context, state) {
            if (state is ChatLoadingState) {
              return Align(alignment: Alignment.center, child: Loading());
            } else if (state is ChatHasDataState) {
              return Column(
                children: <Widget>[
                  Expanded(
                      child: GroupedListChatView(
                    data: state.data,
                    documentId: widget.trip.documentId,
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
                                decoration: InputDecoration.collapsed(
                                    fillColor:
                                        ReusableThemeColor().color(context),
                                    hintText: 'Start typing ...'),
                                controller: _chatController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () async {
                                  if (_chatController.text != '') {
                                    final String message = _chatController.text;
                                    final status = createStatus();
                                    _chatController.clear();
                                    final String displayName =
                                        currentUserProfile.displayName;
                                    final String uid =
                                        userService.currentUserID;
                                    try {
                                      final String action =
                                          "Saving message for ${widget.trip.documentId}";
                                      CloudFunction().logEvent(action);
                                      await DatabaseService(
                                              tripDocID: widget.trip.documentId)
                                          .addNewChatMessage(displayName,
                                              message, uid, status);
                                    } on Exception catch (e) {
                                      CloudFunction().logError(
                                          'Error saving chat message (Chat.dart):  ${e.toString()}');
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
              );
            } else {
              return Container();
            }
          }),
        ),
      ),
    );
  }

  Map<String, bool> createStatus() {
    final Map<String, bool> status = {};
    final users =
        widget.trip.accessUsers.where((f) => f != userService.currentUserID);
    users.forEach((f) => status[f] = false);
    return status;
  }
}
