import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/screens/trip_details/explore/stream_to_explore.dart';
import 'package:travelcrew/services/badge_icon.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/size_config/size_config.dart';



class TappableCrewTripTile extends StatelessWidget {

  final Trip trip;

  TappableCrewTripTile({this.trip});

  var userService = locator<UserService>();
  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  var size = SizeConfig.screenHeight;


  @override
  Widget build(BuildContext context) {

    return Card(
      margin: EdgeInsets.only(left: 20, bottom: 20, top: 20, right: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StreamToExplore(trip: trip,)),
          );
        },
        child: Container(
          height: trip.urlToImage.isNotEmpty ? size* .31 : size*.11,
          width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                trip.urlToImage.isNotEmpty ? Flexible(flex: 3,child: ImageLayout2(trip.urlToImage)) : Container(),
                Flexible(
                  flex: 1,
                  child: ListTile(
                    title: Text(trip.location != null ? trip.location : 'Trip Name',style: Theme.of(context).textTheme.headline4,maxLines: 1,overflow: TextOverflow.ellipsis,),
                    subtitle:  Text(trip.startDate != null ? '${trip.startDate} - ${trip.endDate}' : 'Dates',style: Theme.of(context).textTheme.subtitle1,),
                    trailing: Tooltip(
                      message: 'Members',
                      child: Wrap(
                        // mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 3,
                        children: <Widget>[
                          Text('${trip.accessUsers.length} ',style: Theme.of(context).textTheme.subtitle1,),
                          Icon(Icons.people),
                        ],
                      ),
                    ),

                  ),
                ),
                Flexible(
                  flex: 1,
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      if(trip.favorite.length > 0) Tooltip(
                        message: 'Liked',
                        child: BadgeIcon(
                          icon: Icon(Icons.favorite,color: Colors.redAccent,),
                          badgeCount: trip.favorite.length,
                        ),
                      ),
                      chatNotificationBadges(trip),
                      needListBadges(trip),
                    ],
                  ),
                )
              ],
            ),
          ),
      ),
    );
  }
  String ownerName(String currentUserID){
    if (trip.ownerID == currentUserID){
      return 'You';
    }else {
      return trip.displayName;
    }
  }

  Widget chatNotificationBadges(Trip trip){
    return StreamBuilder(
        builder: (context, chats){
          if(chats.hasData){
            if(chats.data.length > 0) {
              return Tooltip(
                message: 'New Messages',
                child: BadgeIcon(
                  icon: Icon(Icons.chat, color: Colors.grey,),
                  badgeCount: chats.data.length,
                ),
              );
            } else {
              return Visibility(child: Container(),visible: false,);
            }
          } else {
            return Visibility(child: Container(),visible: false,);
          }
        },
        stream: DatabaseService(tripDocID: trip.documentId, uid: userService.currentUserID).chatListNotification,
    );
  }

  Widget needListBadges(Trip trip){
    return StreamBuilder(
      builder: (context, items){
        if(items.hasData){
          if(items.data.length > 0) {
            return Tooltip(
              message: 'Need List',
              child: BadgeIcon(
                icon: Icon(Icons.shopping_basket, color: Colors.grey,),
                badgeCount: items.data.length,
              ),
            );
          } else {
            return Visibility(child: Container(),visible: false,);
          }
        } else {
          return Visibility(child: Container(),visible: false,);
        }
      },
      stream: DatabaseService().getNeedList(trip.documentId),
    );
  }

}