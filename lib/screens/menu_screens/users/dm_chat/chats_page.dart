import 'package:flutter/material.dart';

import '../../../../models/chat_model.dart';
import '../../../../models/custom_objects.dart';
import '../../../../services/constants/constants.dart';
import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../../../../services/widgets/appbar_gradient.dart';
import '../../../../services/widgets/appearance_widgets.dart';
import '../../../../services/widgets/badge_icon.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';
import '../../main_menu.dart';
import 'dm_chat.dart';

class DMChatListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: Theme.of(context).textTheme.headline5,
        ),
        flexibleSpace: const AppBarGradient(),
      ),
      body: StreamBuilder<List<UserPublicProfile>>(
        stream: DatabaseService().retrieveDMChats(),
        builder: (BuildContext context, AsyncSnapshot<List<UserPublicProfile>> users) {
          if (users.hasError) {
            CloudFunction().logError(
                'Error streaming dm chat list: ${users.error.toString()}');
          }
          if (users.hasData) {
            final List<UserPublicProfile> chats = users.data as List<UserPublicProfile>;
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (BuildContext context, int index) {
                final UserPublicProfile user = chats[index];
                return userCard(context, user);
              },
            );
          } else {
            return Loading();
          }
        },
      ),
    );
  }

  Widget userCard(BuildContext context, UserPublicProfile user) {
    return Card(
      color: ReusableThemeColor().color(context),
      child: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight * .09,
        padding: const EdgeInsets.all(2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: SizeConfig.blockSizeHorizontal * 7,
                child: FadeInImage.assetNetwork(placeholder: profileImagePlaceholder, image: user.urlToImage),
              ),
            ),
            Expanded(
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => DMChat(
                            user: user,
                          )));
                },
                // leading:
                title: Text(
                  user.displayName,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                trailing: chatNotificationBadges(user),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget chatNotificationBadges(UserPublicProfile user) {
  return StreamBuilder<List<ChatData>>(
    builder: (BuildContext context, AsyncSnapshot<List<ChatData>> chats) {
      if (chats.hasError) {
        CloudFunction()
            .logError('Error streaming chats '
            'for DM notifications: ${chats.error.toString()}');
      }
      if (chats.hasData) {
        final List<ChatData> chatList = chats.data as List<ChatData>;
        if (chatList.isNotEmpty) {
          chatNotifier.value = 1;
          return Tooltip(
            message: 'New Messages',
            child: BadgeIcon(
              icon: const Icon(
                Icons.chat,
                color: Colors.grey,
              ),
              badgeCount: chatList.length,
            ),
          );
        } else {
          return const Icon(
            Icons.chat,
            color: Colors.grey,
          );
        }
      } else {
        return const Icon(
          Icons.chat,
          color: Colors.grey,
        );
      }
    },
    stream: DatabaseService(userID: user.uid).dmChatListNotification,
  );
}
