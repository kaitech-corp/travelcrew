import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/screens/trip_details/activity/activity.dart';
import 'package:travelcrew/screens/trip_details/chat/chat.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_member_layout.dart';
import 'package:travelcrew/screens/trip_details/lodging/lodging.dart';
import 'package:travelcrew/services/badge_icon.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import 'explore_owner_layout.dart';
import 'members/members_layout.dart';

class Explore extends StatelessWidget {
  var userService = locator<UserService>();
  final Trip trip;
  Explore({this.trip});

  @override
  Widget build(BuildContext context) {

    // final chatNotifications = Provider.of<List<ChatData>>(context);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        drawer: MenuDrawer(),
        appBar: AppBar(
          centerTitle: true,
          // leading: MenuDrawer(),
          title: Text('${trip.tripName ?? trip.location}'.toUpperCase(),style: Theme.of(context).textTheme.headline3,),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),

          ],
          bottom: TabBar(
            labelStyle: Theme.of(context).textTheme.subtitle2,
            isScrollable: true,
            tabs: [
              const Tab(text: 'Explore',
              icon: const Icon(Icons.assignment),),
              const Tab(text: 'Crew',
                icon: const Icon(Icons.people),),
              const Tab(text: 'Lodging',
                icon: const Icon(Icons.hotel),),
              const Tab(text: 'Activities',
                icon: const Icon(Icons.directions_bike),),
              Tab(text: 'Chat',
                icon: getChatNotificationBadge()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            checkOwner(userService.currentUserID),
            MembersLayout(tripDetails: trip,ownerID: userService.currentUserID,),
            Lodging(trip: trip,),
            Activity(trip: trip,),
            Chat(trip: trip,),
          ],
        )
      ),
    );
  }
  
   checkOwner(String uid) {
  if (trip.ownerID == uid){
  return ExploreLayout(tripDetails: trip,);
  } else {
  return ExploreMemberLayout(tripDetails: trip,);
  }
}

Widget getChatNotificationBadge (){
    return StreamBuilder(
        builder: (context, chats){
          if(chats.hasData){
            if(chats.data.length > 0) {
              int chatNotifications = chats.data.length;
              return Tooltip(
                message: 'Messages',
                child: BadgeIcon(
                  icon: const Icon(Icons.chat),
                  badgeCount: chatNotifications,
                ),
              );
            } else {
              return BadgeIcon(
                icon: const Icon(Icons.chat),
                badgeCount: 0,
              );
            }
          } else {
            return BadgeIcon(
              icon: const Icon(Icons.chat),
              badgeCount: 0,
            );
          }
        },
      stream: DatabaseService(tripDocID: trip.documentId).chatListNotification,
    );
}
}

