import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../../../services/widgets/chat_date_display.dart';
import '../../../models/chat_model/chat_model.dart';
import '../chat_card.dart';

class GroupedListChatView extends StatelessWidget {
  const GroupedListChatView({Key? key, required this.data, required this.documentId}) : super(key: key);
  final List<ChatModel> data;
  final String documentId;

  @override
  Widget build(BuildContext context) {
    return GroupedListView<ChatModel, String>(
      elements: data,
      reverse: true,
      groupBy: (ChatModel chat) => DateTime(
              chat.timestamp!.year,
              chat.timestamp!.day,
              chat.timestamp!.month,
              chat.timestamp!.hour)
          .toString(),
      order: GroupedListOrder.DESC,
      itemComparator: (ChatModel a, ChatModel b) => a.timestamp!.compareTo(b.timestamp!),
      groupSeparatorBuilder: (String chat) => Padding(
          padding: const EdgeInsets.all(4.0),
          child: ChatDateDisplay(
            dateString: chat,
          )),
      itemBuilder: (BuildContext context, ChatModel chat) {
        return ChatCard(
          message: chat,
          tripDocID: documentId,
        );
      },
    );
  }
}
