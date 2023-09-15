import 'package:flutter/material.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';


import '../../features/Chat/chat_card.dart';
import '../../models/chat_model/chat_model.dart';

import '../../services/widgets/chat_date_display.dart';

class StickyGroupedChatListView extends StatelessWidget {
  const StickyGroupedChatListView({
    super.key,
    required this.data,
    required this.documentId
  });

  final List<ChatModel> data;
  final String documentId;

  @override
  Widget build(BuildContext context) {
    return StickyGroupedListView<ChatModel, String>(
      key: Key(data.length.toString()),
      elements: data,
      reverse: true,
      groupBy: (ChatModel chat)
      {
        return DateTime(
            chat.timestamp!.year,
            chat.timestamp!.month,
            chat.timestamp!.day,
            chat.timestamp!.hour)
            .toString();
      },
      order: StickyGroupedListOrder.DESC,
      itemComparator:(ChatModel a,ChatModel b) => a.timestamp!.compareTo(b.timestamp!),
      groupSeparatorBuilder: (ChatModel chat) =>
          Padding(
              padding: const EdgeInsets.all(4.0),
              child:ChatDateDisplay(
                dateString: chat.timestamp!.toString(),)),
      itemBuilder: (BuildContext context, ChatModel chat){
        return ChatCard(message: chat, tripDocID: documentId,);
      },
    );
  }
}
