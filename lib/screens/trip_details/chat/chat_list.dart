import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/loading.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/chat/chat_message_layout.dart';


class ChatList extends StatefulWidget {

  final String tripDocID;
  ChatList({this.tripDocID});

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
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
        padding: new EdgeInsets.all(8.0),
        reverse: true,
        itemCount: chatList != null ? chatList.length : 0,
        itemBuilder: (context, index){
          return ChatMessageLayout(message: chatList[index], tripDocID: widget.tripDocID,);
        });
  }
}