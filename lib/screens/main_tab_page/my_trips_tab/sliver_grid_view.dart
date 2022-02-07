import 'package:flutter/material.dart';
import "package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart";
import 'package:nil/nil.dart';

import '../../../models/chat_model.dart';
import '../../../models/custom_objects.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/badge_icon.dart';
import '../../../size_config/size_config.dart';
import '../../image_layout/image_layout_trips.dart';

/// Sliver Grid View for all trips
class SliverGridView extends StatelessWidget {
  final List<Trip> trips;
  final int length;

  const SliverGridView({Key key, this.trips, this.length}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.screenHeight,
      child: CustomScrollView(slivers: <Widget>[
        SliverStaggeredGrid.countBuilder(
          crossAxisCount: 4,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
          itemCount: trips.length,
          itemBuilder: (context, index) {
            return TappableCrewTripGrid(
              trip: trips[index],
            );
          },
          staggeredTileBuilder: (index) {
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
          child: Column(
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
                padding: const EdgeInsets.all(4.0),
                child: Tooltip(
                    message: trip.tripName,
                    child: Text(
                      trip.tripName ?? trip.location,
                      style: Theme.of(context).textTheme.headline4,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 1.2,
                    )),
              ),
              Flexible(
                flex: 2,
                child: ListTile(
                  title: Text(
                    trip.startDate != null
                        ? '${TCFunctions()
                        .dateToMonthDay(trip.startDate)} - ${trip.endDate}'
                        : 'Dates',
                    style: Theme.of(context).textTheme.subtitle1,
                    textScaleFactor: 2,
                  ),
                  trailing: Tooltip(
                    message: 'Members',
                    child: Wrap(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 3,
                      children: <Widget>[
                        Text(
                          '${trip.accessUsers.length} ',
                          style: Theme.of(context).textTheme.subtitle1,
                          textScaleFactor: 2,
                        ),
                        const IconThemeWidget(
                          icon: Icons.people,
                        ),
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
                    if (trip.favorite.isNotEmpty)
                      Tooltip(
                        message: 'Likes',
                        child: BadgeIcon(
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                          ),
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

  String ownerName(String currentUserID) {
    if (trip.ownerID == currentUserID) {
      return 'You';
    } else {
      return trip.displayName;
    }
  }

  Widget chatNotificationBadges(Trip trip) {
    return StreamBuilder(
      builder: (context, chats) {
        if (chats.hasError) {
          CloudFunction()
              .logError('Error streaming chats for '
              'notifications on Crew cards: ${chats.error.toString()}');
        }
        if (chats.hasData) {
          List<ChatData> chatList = chats.data;
          if (chatList.isNotEmpty) {
            return Tooltip(
              message: 'New Messages',
              child: BadgeIcon(
                icon: const IconThemeWidget(
                  icon: Icons.chat,
                ),
                badgeCount: chatList.length,
              ),
            );
          } else {
            return nil;
          }
        } else {
          return nil;
        }
      },
      stream: DatabaseService(
              tripDocID: trip.documentId, uid: userService.currentUserID)
          .chatListNotification,
    );
  }

  Widget needListBadges(Trip trip) {
    return StreamBuilder<List<Need>>(
      builder: (context, items) {
        List<Need> needs = items.data;
        if (items.hasError) {
          CloudFunction()
              .logError('Error streaming need '
              'list for Crew trip cards: ${items.error.toString()}');
        }
        if (items.hasData && needs.isNotEmpty) {
          return Tooltip(
            message: 'Need List',
            child: BadgeIcon(
              icon: const IconThemeWidget(
                icon: Icons.shopping_basket,
              ),
              badgeCount: items.data.length,
            ),
          );
        } else {
          return nil;
        }
      },
      stream: DatabaseService().getNeedList(trip.documentId),
    );
  }
}
