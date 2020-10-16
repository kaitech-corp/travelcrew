import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/screens/trip_details/activity/activity.dart';
import 'package:travelcrew/screens/trip_details/chat/chat.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_member_layout.dart';
import 'package:travelcrew/screens/trip_details/lodging/lodging.dart';
import 'package:travelcrew/services/badge_icon.dart';
import 'package:travelcrew/services/locator.dart';
import 'explore_owner_layout.dart';
import 'members/members_layout.dart';

class Explore extends StatelessWidget {
  var userService = locator<UserService>();
  final Trip trip;
  Explore({this.trip});

  @override
  Widget build(BuildContext context) {

    final chatNotifications = Provider.of<List<ChatData>>(context);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: MainMenuButtons(),
          title: Text('${trip.location}'.toUpperCase(),style: Theme.of(context).textTheme.headline3,),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),

          ],
          bottom: TabBar(
            labelStyle: Theme.of(context).textTheme.subtitle2,
            isScrollable: true,
            tabs: [
              Tab(text: 'Explore',
              icon: Icon(Icons.assignment),),
              Tab(text: 'Crew',
                icon: Icon(Icons.people),),
              Tab(text: 'Lodging',
                icon: Icon(Icons.hotel),),
              Tab(text: 'Activities',
                icon: Icon(Icons.directions_bike),),
              Tab(text: 'Chat',
                icon: BadgeIcon(
                  icon: Icon(Icons.chat),
                  badgeCount: chatNotifications !=null ? chatNotifications.length : 0,
                ),),
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
}

