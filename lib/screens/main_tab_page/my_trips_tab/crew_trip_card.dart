import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import '../../../models/chat_model.dart';
import '../../../models/custom_objects.dart';
import '../../../models/trip_model.dart';
import '../../image_layout/image_layout_trips.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/badge_icon.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/database.dart';
import '../../../size_config/size_config.dart';

class CrewTripCard extends StatelessWidget {
  final Trip trip;
  final heroTag;

  CrewTripCard({this.trip, this.heroTag});

  @override
  Widget build(BuildContext context) {
    var size = SizeConfig.screenHeight;

    return Card(
      elevation: 5,
      shadowColor: Colors.blueGrey,
      key: Key(trip.documentId),
      margin: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          navigationService.navigateTo(ExploreRoute, arguments: trip);
        },
        child: Container(
          height: trip.urlToImage.isNotEmpty ? size * .31 : size * .11,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Colors.blue.shade50, Colors.lightBlueAccent.shade200]),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if(trip.urlToImage.isNotEmpty)
                      Flexible(
                          flex: 3,
                          child: Hero(
                              tag: trip.urlToImage,
                              transitionOnUserGestures: true,
                              child: ImageLayout(trip.urlToImage))),
                    Flexible(
                      flex: 1,
                      child: ListTile(
                        title: Tooltip(
                            message: trip.tripName,
                            child: Text(
                              trip.tripName ?? trip.location,
                              style: Theme.of(context).textTheme.headline5,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                        subtitle: Text(
                          trip.startDate != null
                              ? '${TCFunctions()
                              .dateToMonthDay(trip.startDate)} '
                              '- ${trip.endDate}'
                              : 'Dates',
                          style: Theme.of(context).textTheme.subtitle2,
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
                      flex: 1,
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
    return StreamBuilder<List<ChatData>>(
      builder: (context, chats) {
        if (chats.hasError) {
          CloudFunction().logError('Error streaming chats for '
              'notifications on Crew cards: ${chats.error.toString()}');
        }
        if (chats.hasData && chats.data.length > 0) {
          return Tooltip(
            message: 'New Messages',
            child: BadgeIcon(
              icon: const IconThemeWidget(
                icon: Icons.chat,
              ),
              badgeCount: chats.data.length,
            ),
          );
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
        if (items.hasError) {
          CloudFunction().logError('Error streaming need list for '
              'Crew trip cards: ${items.error.toString()}');
        }
        if (items.hasData && items.data.length > 0) {
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
          return Container();
        }
      },
      stream: DatabaseService().getNeedList(trip.documentId),
    );
  }
}
