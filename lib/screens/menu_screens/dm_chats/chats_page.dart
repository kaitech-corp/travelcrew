import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/menu_screens/users/dm_chat/dm_chat.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/badge_icon.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import '../../../services/widgets/loading.dart';


class DMChatListPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats',style: Theme.of(context).textTheme.headline3,),
      ),
      body: StreamBuilder(
        stream: DatabaseService().retrieveDMChats(),
        builder: (context, users) {
          if(users.hasError){
            CloudFunction().logError('Error streaming dm chat list: ${users.error.toString()}');
          }
          if (users.hasData) {
            var chats = users.data;
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                UserPublicProfile user = chats[index];
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
  Widget userCard(BuildContext context, UserPublicProfile user){
    return Card(
      color: ReusableThemeColor().color(context),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            ListTile(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DMChat(user: user,)
                ));
              },
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.blue,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: user.urlToImage != null ? Image.network(user.urlToImage,height: 75, width: 75,fit: BoxFit.fill,): null,
                ),
              ),
              title: Text("${user.displayName}",
                textAlign: TextAlign.start,style: Theme.of(context).textTheme.subtitle2,),
              trailing: chatNotificationBadges(user),
            ),
          ],
        ),
      ),
    );
  }

}
Widget chatNotificationBadges(UserPublicProfile user){
  return StreamBuilder(
    builder: (context, chats){
      if(chats.hasError){
        CloudFunction().logError('Error streaming chats for DM notifications: ${chats.error.toString()}');
      }
      if(chats.hasData){
        if(chats.data.length > 0) {
          chatNotifier.value = 1;
          return Tooltip(
            message: 'New Messages',
            child: BadgeIcon(
              icon: const Icon(Icons.chat, color: Colors.grey,),
              badgeCount: chats.data.length,
            ),
          );
        } else {
          return const Icon(Icons.chat, color: Colors.grey,);
        }
      } else {
        return const Icon(Icons.chat, color: Colors.grey,);
      }
    },
    stream: DatabaseService(userID: user.uid).dmChatListNotification,
  );
}

