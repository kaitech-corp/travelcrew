import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/badge_icon.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/size_config/size_config.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SliverGridView extends StatelessWidget{
  final List<Trip> trips;
  final int length;

  const SliverGridView({Key key, this.trips, this.length}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: SizeConfig.screenHeight,
      child: CustomScrollView(
          slivers: <Widget>[
            SliverStaggeredGrid.countBuilder(
              crossAxisCount: 4,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
              itemCount: trips.length,
              itemBuilder: (context, index){
                // return trips4[index].urlToImage.isEmpty ? TripCard3(context, trips4[index]) : TripCard4(context, trips4[index]);
                return TappableCrewTripGrid(trip: trips[index],);
              },
              staggeredTileBuilder: (index){
                if(trips[index].urlToImage.isNotEmpty){
                  return StaggeredTile.count(2, 2);
                } else {
                  return StaggeredTile.count(2, 1);
                }
              },
            )]),
    );
  }
}

class TappableCrewTripGrid extends StatelessWidget {

  final Trip trip;
  final heroTag;

  TappableCrewTripGrid({this.trip, this.heroTag});

  @override
  Widget build(BuildContext context) {

    return Card(
      key: Key(trip.documentId),
      margin: const EdgeInsets.only(left: 20, bottom: 10, right: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
      child:
      InkWell(
        onTap: (){
          navigationService.navigateTo(ExploreRoute, arguments: trip);
        },
        child: Container(
          decoration: (ThemeProvider.themeOf(context).id == 'light_theme') ?
          BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.lightBlueAccent.shade200
                ]
            ),
          ): BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade700,
                  Color(0xAA2D3D49)
                ]
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              trip.urlToImage.isNotEmpty ? Flexible(flex: 4,child: Hero(tag: trip.urlToImage, transitionOnUserGestures: true,child: ImageLayout(trip.urlToImage))) : Spacer(),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Tooltip(
                    message: trip.tripName,
                    child: Text(trip.tripName ?? trip.location,style: Theme.of(context).textTheme.headline4,maxLines: 2,overflow: TextOverflow.ellipsis,)),
              ),
              Flexible(
                flex: 2,
                child: ListTile(
                  title: Text(trip.startDate != null ? '${TCFunctions().dateToMonthDay(trip.startDate)} - ${trip.endDate}' : 'Dates',style: Theme.of(context).textTheme.subtitle1,),
                  trailing: Tooltip(
                    message: 'Members',
                    child: Wrap(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 3,
                      children: <Widget>[
                        Text('${trip.accessUsers.length} ',style: Theme.of(context).textTheme.subtitle1,),
                        IconThemeWidget(icon:Icons.people,),
                      ],
                    ),
                  ),

                ),
              ),
              Flexible(
                flex: 2,
                child: ButtonBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    if(trip.favorite.length > 0) Tooltip(
                      message: 'Likes',
                      child: BadgeIcon(
                        icon: const Icon(Icons.favorite,color: Colors.redAccent,),
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
        if(chats.hasError){
          CloudFunction().logError('Error streaming chats for notifications on Crew cards: ${chats.error.toString()}');
        }
        if(chats.hasData){
          if(chats.data.length > 0) {
            return Tooltip(
              message: 'New Messages',
              child: BadgeIcon(
                icon: IconThemeWidget(icon: Icons.chat,),
                badgeCount: chats.data.length,
              ),
            );
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
      stream: DatabaseService(tripDocID: trip.documentId, uid: userService.currentUserID).chatListNotification,
    );
  }

  Widget needListBadges(Trip trip){

    return StreamBuilder(
      builder: (context, items){
        if(items.hasError){
          CloudFunction().logError('Error streaming need list for Crew trip cards: ${items.error.toString()}');
        }
        if(items.hasData && items.data.length > 0){
            return Tooltip(
              message: 'Need List',
              child: BadgeIcon(
                icon: IconThemeWidget(icon: Icons.shopping_basket,),
                badgeCount: items.data.length,
              ),
            );
        } else {
          return Container();
        }
      },
      stream: DatabaseService().getNeedList(trip.documentId),
    );
  }
}