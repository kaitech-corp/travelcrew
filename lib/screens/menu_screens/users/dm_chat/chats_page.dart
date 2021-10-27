import 'package:flutter/material.dart';
import 'package:travelcrew/models/chat_model.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/menu_screens/users/dm_chat/dm_chat.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/widgets/appbar_gradient.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/badge_icon.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/size_config/size_config.dart';
import '../../../../services/widgets/loading.dart';

class DMChatListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: Theme.of(context).textTheme.headline5,
        ),
        flexibleSpace: AppBarGradient(),
      ),
      body: StreamBuilder<List<UserPublicProfile>>(
        stream: DatabaseService().retrieveDMChats(),
        builder: (context, users) {
          if (users.hasError) {
            CloudFunction().logError(
                'Error streaming dm chat list: ${users.error.toString()}');
          }
          if (users.hasData) {
            final List<UserPublicProfile> chats = users.data;
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
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
                backgroundImage: (user.urlToImage.isNotEmpty ?? false)
                    ? NetworkImage(
                        user.urlToImage,
                      )
                    : AssetImage(profileImagePlaceholder),
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
    builder: (context, chats) {
      if (chats.hasError) {
        CloudFunction()
            .logError('Error streaming chats '
            'for DM notifications: ${chats.error.toString()}');
      }
      if (chats.hasData) {
        final List<ChatData> chatList = chats.data;
        if (chatList.isNotEmpty) {
          chatNotifier.value = 1;
          return Tooltip(
            message: 'New Messages',
            child: BadgeIcon(
              icon: const Icon(
                Icons.chat,
                color: Colors.grey,
              ),
              badgeCount: chats.data.length,
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
