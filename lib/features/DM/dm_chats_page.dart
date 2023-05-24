import 'package:flutter/material.dart';


import '../../../../services/constants/constants.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../../../../services/theme/text_styles.dart';
import '../../../../services/widgets/appbar_gradient.dart';
import '../../../../services/widgets/appearance_widgets.dart';
import '../../../../services/widgets/badge_icon.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';
import '../../models/chat_model/chat_model.dart';
import '../../models/public_profile_model/public_profile_model.dart';
import '../Menu/main_menu.dart';
import 'dm_chat.dart';
import 'logic/logic.dart';

class DMChatListPage extends StatelessWidget {
  const DMChatListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: headlineSmall(context),
        ),
        flexibleSpace: const AppBarGradient(),
      ),
      body: StreamBuilder<List<UserPublicProfile>>(
        stream: retrieveDMChats(),
        builder: (BuildContext context, AsyncSnapshot<List<UserPublicProfile>> users) {
          if (users.hasError) {
            CloudFunction().logError('Error streaming dm chat list: ${users.error}');
          }
          if (users.hasData) {
            final List<UserPublicProfile> chats = users.data!;
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (BuildContext context, int index) {
                final UserPublicProfile user = chats[index];
                return UserCard(
                  user: user,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => DMChat(user: user),
                    ));
                  },
                );
              },
            );
          } else {
            return const Loading();
          }
        },
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  const UserCard({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  final UserPublicProfile user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ReusableThemeColor().color(context),
      child: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight * 0.09,
        padding: const EdgeInsets.all(2),
        child: InkWell(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: CircleAvatar(
                  radius: SizeConfig.blockSizeHorizontal * 7,
                  backgroundImage: user.urlToImage.isNotEmpty
                      ? NetworkImage(user.urlToImage)
                      : const NetworkImage(profileImagePlaceholder),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text(
                    user.displayName,
                    textAlign: TextAlign.start,
                    style: titleMedium(context),
                  ),
                  trailing: ChatNotificationBadges(user: user),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatNotificationBadges extends StatelessWidget {
  const ChatNotificationBadges({
    Key? key,
    required this.user,
  }) : super(key: key);

  final UserPublicProfile user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatModel>>(
      builder: (BuildContext context, AsyncSnapshot<List<ChatModel>> chats) {
        if (chats.hasError) {
          CloudFunction().logError('Error streaming chats for DM notifications: ${chats.error}');
        }
        if (chats.hasData) {
          final List<ChatModel> chatList = chats.data!;
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
          }
        }
        return const Icon(
          Icons.chat,
          color: Colors.grey,
        );
      },
      stream: dmChatListNotification,
    );
  }
}
