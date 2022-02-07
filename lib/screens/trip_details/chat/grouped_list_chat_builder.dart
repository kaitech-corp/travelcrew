import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../../models/chat_model.dart';
import '../../../services/widgets/chat_date_display.dart';
import 'chat_card.dart';

class GroupedListChatView extends StatelessWidget {
  final dynamic data;
  final String documentId;
  GroupedListChatView({Key key, this.data, this.documentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupedListView<ChatData, String>(
      elements: data,
      reverse: true,
      groupBy: (chat) => DateTime(
              chat.timestamp.toDate().year,
              chat.timestamp.toDate().month,
              chat.timestamp.toDate().day,
              chat.timestamp.toDate().hour)
          .toString(),
      order: GroupedListOrder.DESC,
      itemComparator: (a, b) => a.timestamp.compareTo(b.timestamp),
      groupSeparatorBuilder: (chat) => Padding(
          padding: const EdgeInsets.all(4.0),
          child: ChatDateDisplay(
            dateString: chat,
          )),
      itemBuilder: (context, chat) {
        return ChatCard(
          message: chat,
          tripDocID: documentId,
        );
      },
    );
  }
}
