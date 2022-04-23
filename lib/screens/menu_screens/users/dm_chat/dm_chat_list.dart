import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/chat_model.dart';
import '../../../../models/custom_objects.dart';
import '../../../../services/widgets/loading.dart';
import 'dm_chat_message_layout.dart';



class DMChatList extends StatefulWidget {

  final UserPublicProfile user;
  DMChatList({this.user});

  @override
  _DMChatListState createState() => _DMChatListState();
}

class _DMChatListState extends State<DMChatList> {
  @override
  Widget build(BuildContext context) {

    bool loading = true;
    final chatList = Provider.of<List<ChatData>>(context);
    if(chatList != null) {
      setState(() {
        loading = false;
      });

    }

    return loading ? Loading() : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        reverse: true,
        itemCount: chatList != null ? chatList.length : 0,
        itemBuilder: (context, index){
          return DMChatMessageLayout(message: chatList[index], user: widget.user,);
        });
  }
}