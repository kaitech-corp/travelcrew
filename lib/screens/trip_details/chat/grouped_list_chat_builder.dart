import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../../models/chat_model.dart';
import '../../../services/widgets/chat_date_display.dart';
import 'chat_card.dart';

class GroupedListChatView extends StatelessWidget {
  const GroupedListChatView({Key? key, required this.data, required this.documentId}) : super(key: key);
  final List<ChatData> data;
  final String documentId;

  @override
  Widget build(BuildContext context) {
    return GroupedListView<ChatData, String>(
      elements: data,
      reverse: true,
      groupBy: (ChatData chat) => DateTime(
              chat.timestamp.toDate().year,
              chat.timestamp.toDate().month,
              chat.timestamp.toDate().day,
              chat.timestamp.toDate().hour)
          .toString(),
      order: GroupedListOrder.DESC,
      itemComparator: (ChatData a, ChatData b) => a.timestamp.compareTo(b.timestamp),
      groupSeparatorBuilder: (String chat) => Padding(
          padding: const EdgeInsets.all(4.0),
          child: ChatDateDisplay(
            dateString: chat,
          )),
      itemBuilder: (BuildContext context, ChatData chat) {
        return ChatCard(
          message: chat,
          tripDocID: documentId,
        );
      },
    );
  }
}
