import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/blocs/chat_bloc/chat_bloc.dart';
import 'package:travelcrew/blocs/chat_bloc/chat_event.dart';
import 'package:travelcrew/blocs/chat_bloc/chat_state.dart';
import 'package:travelcrew/models/chat_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/screens/trip_details/chat/chat_card.dart';


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

  final TextEditingController _chatController = new TextEditingController();

  Future<void> clearChat(String uid) async {
    await DatabaseService(tripDocID: widget.trip.documentId, uid: uid).clearChatNotifications();
  }

  @override
  void initState() {
    bloc = BlocProvider.of<ChatBloc>(context);
    bloc.add(LoadingChatData());
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    clearChat(userService.currentUserID);


    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state){
              if(state is ChatLoadingState){
                return Loading();
              } else if (state is ChatHasDataState){
                List<ChatData> chatList = state.data;
                return Column(
                  children: <Widget>[
                    Flexible(
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            reverse: true,
                            itemCount: chatList != null ? chatList.length : 0,
                            itemBuilder: (context, index){
                              return ChatCard(message: chatList[index], tripDocID: widget.trip.documentId,);
                            })
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
                                      String displayName = currentUserProfile.displayName;
                                      String uid = userService.currentUserID;
                                      try {
                                        String action = 'Saving new message for ${widget.trip.documentId}';
                                        CloudFunction().logEvent(action);
                                        await DatabaseService(
                                            tripDocID: widget.trip.documentId)
                                            .addNewChatMessage(
                                            displayName, message, uid, status);
                                      } on Exception catch (e) {
                                        CloudFunction().logError('Error saving new chat message (Chat.dart):  ${e.toString()}');
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
    );
  }
  createStatus() {
    Map<String, bool> status = {};
    var users = widget.trip.accessUsers.where((f) => f != userService.currentUserID);
    users.forEach((f) => status[f] = false);
    return status;
  }
}

