import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/screens/trip_details/activity/activity.dart';
import 'package:travelcrew/screens/trip_details/chat/chat.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_member_layout.dart';
import 'package:travelcrew/screens/trip_details/lodging/lodging.dart';
import 'package:travelcrew/screens/trip_details/transportation/transportation.dart';
import 'package:travelcrew/services/badge_icon.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'explore_owner_layout.dart';


class Explore extends StatelessWidget {

  final Trip trip;
  Explore({this.trip,});

  final scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController controller;

  @override
  Widget build(BuildContext context) {

    // final chatNotifications = Provider.of<List<ChatData>>(context);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        key: scaffoldKey,
        drawer: MenuDrawer(),
        appBar: AppBar(
          centerTitle: true,
          // leading: MenuDrawer(),
          title: Text('Explore',style: Theme.of(context).textTheme.headline3,),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _closeModalBottomSheet;
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
              const Tab(text: 'Travel',
                icon: const Icon(Icons.flight),),
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
            Transportation(trip: trip,),
            Lodging(trip: trip,),
            Activity(trip: trip,),
            Chat(trip: trip,),
          ],
        )
      ),
    );
  }

  void _closeModalBottomSheet() {
    if (controller != null) {
      controller.close();
      controller = null;
    }
  }

   checkOwner(String uid) {
  if (trip.ownerID == uid){
  return ExploreOwnerLayout(tripDetails: trip,controller: controller,scaffoldKey: scaffoldKey,);
  } else {
  return ExploreMemberLayout(tripDetails: trip,controller: controller,scaffoldKey: scaffoldKey,);
  }
}

Widget getChatNotificationBadge (){
    return StreamBuilder(
        builder: (context, chats){
          if(chats.hasError){
            CloudFunction().logError('Error streaming chats for explore chat notification: ${chats.error.toString()}');
          }
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

