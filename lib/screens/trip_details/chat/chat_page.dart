import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/generics/generic_state.dart';
import '../../../blocs/generics/generics_event.dart';
import '../../../models/chat_model.dart';
import '../../../models/trip_model.dart';
import '../../../repositories_v2/chat_repository.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/locator.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/loading.dart';
import '../../../size_config/size_config.dart';
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
  GenericBloc<ChatData,ChatRepository> bloc;

  var currentUserProfile =
      locator<UserProfileService>().currentUserProfileDirect();

  final TextEditingController _chatController = TextEditingController();

  Future<void> clearChat(String uid) async {
    await DatabaseService(tripDocID: widget.trip.documentId, uid: uid)
        .clearChatNotifications();
  }

  @override
  void didChangeDependencies() {
    bloc = BlocProvider.of<GenericBloc<ChatData,ChatRepository>>(context);
    bloc.add(LoadingGenericData());
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
          child: BlocBuilder<GenericBloc<ChatData,ChatRepository>, GenericState>(builder: (context, state) {
            if (state is LoadingState) {
              return Align(alignment: Alignment.center, child: Loading());
            } else if (state is HasDataState<ChatData>) {
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
