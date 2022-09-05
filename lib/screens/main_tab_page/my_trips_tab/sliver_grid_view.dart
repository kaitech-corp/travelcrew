import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../models/chat_model.dart';
import '../../../models/custom_objects.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/widgets/badge_icon.dart';
import '../../../size_config/size_config.dart';
import '../../image_layout/image_layout_trips.dart';

/// Sliver Grid View for all trips
class SliverGridView extends StatelessWidget {

  const SliverGridView({Key? key, required this.trips, required this.length}) : super(key: key);
  final List<Trip> trips;
  final int length;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.screenHeight,
      child: CustomScrollView(slivers: <Widget>[
        SliverStaggeredGrid.countBuilder(
          crossAxisCount: 4,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
          itemCount: trips.length,
          itemBuilder: (BuildContext context, int index) {
            return TappableCrewTripGrid(
              trip: trips[index],
            );
          },
          staggeredTileBuilder: (int index) {
            if (trips[index].urlToImage.isNotEmpty) {
              return const StaggeredTile.count(2, 2);
            } else {
              return const StaggeredTile.count(2, 1);
            }
          },
        )
      ]),
    );
  }
}

class TappableCrewTripGrid extends StatelessWidget {

  const TappableCrewTripGrid({required this.trip, this.heroTag});
  final Trip trip;
  final heroTag;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key(trip.documentId),
      margin: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          navigationService.navigateTo(ExploreRoute, arguments: trip);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Colors.blue.shade50, Colors.lightBlueAccent.shade200]),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if(trip.urlToImage.isNotEmpty)
                      Flexible(
                          flex: 4,
                          child: Hero(
                              tag: trip.urlToImage,
                              transitionOnUserGestures: true,
                              child: ImageLayout(trip.urlToImage))),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Tooltip(
                        message: trip.tripName,
                        child: Text(
                          trip.tripName,
                          style: Theme.of(context).textTheme.headline4,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textScaleFactor: 1.2,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      trip.startDate != null
                          ? '${TCFunctions()
                          .dateToMonthDay(trip.startDate)} - ${trip.endDate}'
                          : 'Dates',
                      style: Theme.of(context).textTheme.subtitle2,
                      textScaleFactor: 2,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: SizeConfig.screenHeight*.05,
                  width: SizeConfig.screenWidth*.25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      favoriteIcon(),
                      chatNotificationBadges(trip),
                      needListBadges(trip),
                      BadgeIcon(
                        icon: (trip.accessUsers.length > 1) ? const Icon(
                          Icons.people,
                          color: Colors.purpleAccent,
                        ):
                        const Icon(
                          Icons.people_outline,
                          color: Colors.purpleAccent,
                        ),
                        badgeCount: trip.accessUsers.length,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Tooltip favoriteIcon() {
    return Tooltip(
      message: 'Likes',
      child: BadgeIcon(
        icon: (trip.favorite.isNotEmpty) ? const Icon(
          Icons.favorite,
          color: Colors.redAccent,
        ):
        const Icon(
          Icons.favorite_border,
          color: Colors.redAccent,
        ),
        badgeCount: trip.favorite.length,
      ),
    );
  }

  String ownerName(String currentUserID) {
    if (trip.ownerID == currentUserID) {
      return 'You';
    } else {
      return trip.displayName;
    }
  }

  Widget chatNotificationBadges(Trip trip) {
    return StreamBuilder(
      builder: (BuildContext context, AsyncSnapshot<Object?> chats) {
        if (chats.hasError) {
          CloudFunction()
              .logError('Error streaming chats for '
              'notifications on Crew cards: ${chats.error.toString()}');
        }
        if (chats.hasData) {
          final List<ChatData> chatList = chats.data as List<ChatData>;
            return Tooltip(
              message: 'New Messages',
              child: BadgeIcon(
                icon: const Icon(Icons.chat,color: Colors.greenAccent,),
                badgeCount: chatList.length,
              ),
            );
          } else {
            return const Tooltip(
              message: 'No new messages',
              child: Icon(Icons.chat_bubble_outline,color: Colors.greenAccent,),
            );
          }
      },
      stream: DatabaseService(
              tripDocID: trip.documentId, uid: userService.currentUserID)
          .chatListNotification,
    );
  }

  Widget needListBadges(Trip trip) {
    return StreamBuilder<List<Need>>(
      builder: (BuildContext context, AsyncSnapshot<List<Need>> items) {
        final List<Need> needs = items.data as List<Need>;
        if (items.hasError) {
          CloudFunction()
              .logError('Error streaming need '
              'list for Crew trip cards: ${items.error.toString()}');
        }
        if (items.hasData && needs.isNotEmpty) {
          return Tooltip(
            message: 'Need List',
            child: BadgeIcon(
              icon: const Icon(Icons.shopping_basket,color: Colors.orangeAccent,),
              badgeCount: items.data!.length,
            ),
          );
        } else {
          return const Icon(Icons.shopping_basket_outlined,color: Colors.orangeAccent,);
        }
      },
      stream: DatabaseService().getNeedList(trip.documentId),
    );
  }
}
