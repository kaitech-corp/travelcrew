import 'package:flutter/material.dart';
import 'package:nil/nil.dart';

import '../../../models/chat_model.dart';
import '../../../models/custom_objects.dart';
import '../../../models/trip_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/badge_icon.dart';
import '../../../size_config/size_config.dart';
import '../../image_layout/image_layout_trips.dart';

class CrewTripCard extends StatelessWidget {
  const CrewTripCard({Key? key, required this.trip, required this.heroTag})
      : super(key: key);
  final Trip trip;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
                        height: SizeConfig.screenHeight * .3,
                  width: SizeConfig.screenWidth * .5,
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Card(
              elevation: 5,
              shadowColor: Colors.blueGrey,
              key: Key(trip.documentId),
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Colors.white,
              child: Expanded(
                flex: 6,
                child: InkWell(
                  onTap: () {
                    navigationService.navigateTo(ExploreRoute, arguments: trip);
                  },
                  child: Container(
                    height: SizeConfig.screenHeight * .25,
                    width: SizeConfig.screenWidth * .5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: (trip.urlToImage.isNotEmpty)?
                      Hero(
                          tag: heroTag,
                          transitionOnUserGestures: true,
                          child: ImageLayout(trip.urlToImage))
                    :
                      Hero(
                          tag: trip.documentId,
                          transitionOnUserGestures: true,
                          child: const ImageLayout(travelImage)),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: Text(trip.tripName, maxLines: 1,overflow: TextOverflow.ellipsis,))
        ],
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
      builder: (BuildContext context, AsyncSnapshot<List<ChatData>> chats) {
        if (chats.hasError) {
          CloudFunction().logError('Error streaming chats for '
              'notifications on Crew cards: ${chats.error}');
        }
        if (chats.hasData && chats.data!.isNotEmpty) {
          return Tooltip(
            message: 'New Messages',
            child: BadgeIcon(
              icon: const IconThemeWidget(
                icon: Icons.chat,
              ),
              badgeCount: chats.data!.length,
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
      builder: (BuildContext context, AsyncSnapshot<List<Need>> items) {
        if (items.hasError) {
          CloudFunction().logError('Error streaming need list for '
              'Crew trip cards: ${items.error}');
        }
        if (items.hasData && items.data!.isNotEmpty) {
          return Tooltip(
            message: 'Need List',
            child: BadgeIcon(
              icon: const IconThemeWidget(
                icon: Icons.shopping_basket,
              ),
              badgeCount: items.data!.length,
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
