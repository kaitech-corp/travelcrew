import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:travelcrew/models/chat_model.dart';
import 'package:travelcrew/services/widgets/chat_date_display.dart';

import 'chat_card.dart';


class GroupedListChatView extends StatelessWidget {
  final dynamic data;
  final String documentId;
  GroupedListChatView({
    Key key,
    this.data,
    this.documentId
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupedListView<ChatData, String>(
      elements: data,
      reverse: true,
      groupBy: (chat) => buildGroupBy(chat),
      order: GroupedListOrder.DESC,
      itemComparator: comparator,
      groupSeparatorBuilder: (chat) => Padding(
        padding: const EdgeInsets.all(4.0),
        child:ChatDateDisplay(dateString: chat,)),
      itemBuilder: (context, chat){
        return ChatCard(message: chat, tripDocID: documentId,);
      },
    );
  }

  int comparator(ChatData a, ChatData b){
    if(a.timestamp != null){
      return a.timestamp.compareTo(b.timestamp);
    } else {
      return 1;
    }

  }

  String buildGroupBy(ChatData chat) {
    if (chat.timestamp != null) {
      return DateTime(
          chat.timestamp
              .toDate()
              .year,
          chat.timestamp
              .toDate()
              .month,
          chat.timestamp
              .toDate()
              .day,
          chat.timestamp
              .toDate()
              .hour).toString();
    } else {
      Future.delayed(const Duration(milliseconds: 500));
      return DateTime(
          chat.timestamp
              .toDate()
              .year,
          chat.timestamp
              .toDate()
              .month,
          chat.timestamp
              .toDate()
              .day,
          chat.timestamp
              .toDate()
              .hour).toString();
    }
  }
}

