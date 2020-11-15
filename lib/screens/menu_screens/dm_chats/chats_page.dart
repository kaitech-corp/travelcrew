import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/menu_screens/users/dm_chat/dm_chat.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/services/badge_icon.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import '../../../loading.dart';


class DMChatListPage extends StatelessWidget{

  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats',style: Theme.of(context).textTheme.headline3,),
      ),
      body: StreamBuilder(
        stream: DatabaseService().retrieveDMChats(),
        builder: (context, users) {
          if (users.hasData) {
            var chats = users.data;
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                UserProfile user = chats[index];
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
  Widget userCard(BuildContext context, UserProfile user){
    return Card(
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
              title: Text('${user.firstName} ${user.lastName}'),
              subtitle: Text("${user.displayName}",
                textAlign: TextAlign.start,style: Theme.of(context).textTheme.subtitle2,),
              trailing: chatNotificationBadges(user),
            ),
          ],
        ),
      ),
    );
  }
  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: const Text('Invite sent.')));
  }
}
Widget chatNotificationBadges(UserProfile user){
  return StreamBuilder(
    builder: (context, chats){
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

