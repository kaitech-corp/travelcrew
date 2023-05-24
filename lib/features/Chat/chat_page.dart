import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/generics/generic_state.dart';
import '../../../blocs/generics/generics_event.dart';
import '../../../repositories/chat_repository.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/loading.dart';
import '../../../size_config/size_config.dart';
import '../../models/chat_model/chat_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../Chat/components/grouped_list_chat_builder.dart';
import '../Chat/logic/logic.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.trip}) : super(key: key);

  final Trip trip;

  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  late GenericBloc<ChatModel, ChatRepository> bloc;
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GenericBloc<ChatModel, ChatRepository>>(context)
      ..add(LoadingGenericData());
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  Future<void> clearChat(String uid) async {
    await clearChatNotifications();
  }

  Widget _buildChatListView(List<ChatModel> ChatModel) {
    return Column(
      children: <Widget>[
        Expanded(
          child: GroupedListChatView(
            data: ChatModel,
            documentId: widget.trip.documentId,
          ),
        ),
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
                        fillColor: ReusableThemeColor().color(context),
                        hintText: 'Start typing ...',
                      ),
                      controller: _chatController,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final String message = _chatController.text;
                        if (message.isNotEmpty) {
                          final Map<String, bool> status = createStatus();
                          _chatController.clear();
                          final String displayName =
                              currentUserProfile.displayName;
                          final String uid = userService.currentUserID;
                          try {
                            final String action =
                                'Saving message for ${widget.trip.documentId}';
                            CloudFunction().logEvent(action);
                            await addNewChatMessage(
                                displayName, message, uid, status);
                          } on Exception catch (e) {
                            CloudFunction().logError(
                                'Error saving chat message (Chat.dart):  $e');
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
          child:
              BlocBuilder<GenericBloc<ChatModel, ChatRepository>, GenericState>(
            builder: (BuildContext context, GenericState state) {
              if (state is LoadingState) {
                return const Align(child: Loading());
              } else if (state is HasDataState) {
                final List<ChatModel> ChatModel = state.data as List<ChatModel>;
                return _buildChatListView(ChatModel);
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  Map<String, bool> createStatus() {
    final Map<String, bool> status = <String, bool>{};
    final Iterable<String> users = widget.trip.accessUsers
        .where((String f) => f != userService.currentUserID);
    for (final String f in users) {
      status[f] = false;
    }
    return status;
  }
}
