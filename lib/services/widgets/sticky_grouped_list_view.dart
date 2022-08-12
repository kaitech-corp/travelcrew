import 'package:flutter/material.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../../models/chat_model.dart';
import '../../screens/trip_details/chat/chat_card.dart';
import '../../services/widgets/chat_date_display.dart';

class StickyGroupedChatListView extends StatelessWidget {
  const StickyGroupedChatListView({
    Key? key,
    @required this.data,
    required this.documentId
  }) : super(key: key);

  final dynamic data;
  final String documentId;

  @override
  Widget build(BuildContext context) {
    return StickyGroupedListView<ChatData, String>(
      key: Key(data.length.toString()),
      elements: data,
      reverse: true,
      groupBy: (chat)
      {
        return DateTime(
            chat.timestamp.toDate().year,
            chat.timestamp.toDate().month,
            chat.timestamp.toDate().day,
            chat.timestamp.toDate().hour)
            .toString();
      },
      order: StickyGroupedListOrder.DESC,
      itemComparator:(a,b) => a.timestamp.compareTo(b.timestamp),
      groupSeparatorBuilder: (chat) =>
          Padding(
              padding: const EdgeInsets.all(4.0),
              child:ChatDateDisplay(
                dateString: chat.timestamp.toDate().toString(),)),
      itemBuilder: (context, chat){
        return ChatCard(message: chat, tripDocID: documentId,);
      },
    );
  }
}