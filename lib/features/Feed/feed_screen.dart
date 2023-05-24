import 'package:flutter/material.dart';

import '../../../../services/database.dart';
import '../../../../services/theme/text_styles.dart';
import '../../../../services/widgets/appearance_widgets.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';
import '../../models/feed_model/feed_model.dart';
import '../../services/functions/tc_functions.dart';
import 'logic/logic.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FeedModel>>(
      stream: getFeed(),
      builder: (BuildContext context, AsyncSnapshot<List<FeedModel>> data) {
        if (data.hasData) {
          final List<FeedModel> feed = data.data!;
          return ListView.builder(
            itemCount: feed.length,
            itemBuilder: (BuildContext context, int index) {
              final FeedModel feedItem = feed[index];
              return feedCard(context, feedItem);
            },
          );
        } else {
          return const Loading();
        }
      },
    );
  }

  Widget feedCard(BuildContext context, FeedModel feed) {
    return Card(
      color: ReusableThemeColor().color(context),
      child: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight * .09,
        padding: const EdgeInsets.all(2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ListTile(
                onTap: () {},
                // leading:
                title: Text(
                  feed.message,
                  textAlign: TextAlign.start,
                  style: titleMedium(context),
                ),
                subtitle: Text(feed.dateCreated!.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
