import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/app_bar/popup_menu.dart';
import 'package:travelcrew/screens/trip_details/activity/activity.dart';
import 'package:travelcrew/screens/trip_details/chat/chat.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_member_layout.dart';
import 'package:travelcrew/screens/trip_details/lodging/lodging.dart';
import 'package:travelcrew/screens/trip_details/flight/flight.dart';
import 'package:travelcrew/services/auth.dart';
import 'package:travelcrew/services/badge_icon.dart';
import 'explore_owner_layout.dart';

class Explore extends StatelessWidget {

  final AuthService _auth = AuthService();
  
  final Trip trip;
  Explore({this.trip});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    final chatNotifications = Provider.of<List<ChatData>>(context);
    String uid = user.uid;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: PopupMenuButtons(),
          title: Text('${trip.location}'.toUpperCase()),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),

          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Explore',
              icon: Icon(Icons.assignment),),
              Tab(text: 'Travel',
                icon: Icon(Icons.airplanemode_active),),
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
            checkOwner(uid),
            Flight(trip: trip,),
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
  return ExploreLayout(tripdetails: trip,);
  } else {
  return ExploreMemberLayout(tripdetails: trip,);
  }
}
}

