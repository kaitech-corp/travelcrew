// ignore_for_file: always_specify_types

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/public_profile_bloc/public_profile_bloc.dart';

import '../../../repositories/chat_repository.dart';
import '../../../repositories/lodging_repository.dart';
import '../../../repositories/split_repository.dart';
import '../../../repositories/transportation_repository.dart';
import '../../../repositories/user_profile_repository.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/badge_icon.dart';
import '../../../size_config/size_config.dart';

import '../../models/activity_model/activity_model.dart';
import '../../models/chat_model/chat_model.dart';
import '../../models/lodging_model/lodging_model.dart';
import '../../models/split_model/split_model.dart';
import '../../models/transportation_model/transportation_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../Activities/activity_page.dart';
import '../Activities/logic/activity_repository.dart';
import '../Chat/logic/logic.dart';
import '../Lodging/lodging_page.dart';
import '../Menu/main_menu.dart';
import '../Split/split_page.dart';
import '../Transportation/transportation_page.dart';
import '../Trips/logic/logic.dart';
import '../chat/chat_page.dart';

import 'explore_member_layout.dart';
import 'explore_owner_layout.dart';

/// Explore page for trip
class Explore extends StatefulWidget {
  const Explore({
    Key? key,
    required this.trip,
  }) : super(key: key);

  final Trip trip;

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ValueNotifier<String> title = ValueNotifier<String>('Explore');

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
          key: scaffoldKey,
          drawer: BlocProvider<PublicProfileBloc>(
            create: (BuildContext context) => PublicProfileBloc(
                profileRepository: PublicProfileRepository()
                  ..refresh(userService.currentUserID)),
            child: const MenuDrawer(),
          ),
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: canvasColor,
            title: Text(
              widget.trip.tripName,
              style: headlineSmall(context),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  navigationService.pop();
                },
              ),
            ],
            bottom: TabBar(
              labelStyle: SizeConfig.tablet
                  ? headlineSmall(context)
                  : titleSmall(context),
              isScrollable: true,
              tabs: <Tab>[
                const Tab(
                  icon: Icon(
                    Icons.home,
                  ),
                ),
                const Tab(
                  icon: Icon(
                    Icons.monetization_on,
                  ),
                ),
                const Tab(
                  icon: Icon(
                    Icons.flight_takeoff,
                  ),
                ),
                const Tab(
                  icon: Icon(
                    Icons.hotel,
                  ),
                ),
                const Tab(
                  icon: Icon(
                    Icons.directions_bike,
                  ),
                ),
                Tab(icon: getChatNotificationBadge()),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              checkOwner(userService.currentUserID),
              BlocProvider(
                create: (BuildContext context) =>
                    GenericBloc<SplitObject, SplitRepository>(
                        repository:
                            SplitRepository(tripDocID: widget.trip.documentId)),
                child: SplitPage(
                  trip: widget.trip,
                ),
              ),
              BlocProvider(
                create: (BuildContext context) =>
                    GenericBloc<TransportationModel, TransportationRepository>(
                        repository: TransportationRepository(
                            tripDocID: widget.trip.documentId)),
                child: TransportationPage(
                  trip: widget.trip,
                ),
              ),
              BlocProvider(
                create: (BuildContext context) =>
                    GenericBloc<LodgingModel, LodgingRepository>(
                        repository: LodgingRepository(
                            tripDocID: widget.trip.documentId)),
                child: LodgingPage(
                  trip: widget.trip,
                ),
              ),
              BlocProvider(
                create: (BuildContext context) =>
                    GenericBloc<ActivityModel, ActivityRepository>(
                        repository: ActivityRepository(
                            tripDocID: widget.trip.documentId)),
                child: ActivityPage(
                  trip: widget.trip,
                ),
              ),
              BlocProvider(
                create: (BuildContext context) =>
                    GenericBloc<ChatModel, ChatRepository>(
                        repository:
                            ChatRepository(tripDocID: widget.trip.documentId)),
                child: ChatPage(
                  trip: widget.trip,
                ),
              ),
            ],
          )),
    );
  }

  Widget checkOwner(String uid) {
    if (widget.trip.ownerID == uid) {
      return StreamBuilder<Trip?>(
          stream:
              singleTripData,
          builder: (BuildContext context, AsyncSnapshot<Trip?> document) {
            if (document.hasData) {
              final Trip tripDetails = document.data!;
              return ExploreOwnerLayout(
                trip: tripDetails,
                scaffoldKey: scaffoldKey,
              );
            } else {
              return ExploreOwnerLayout(
                trip: widget.trip,
                scaffoldKey: scaffoldKey,
              );
            }
          });
    } else {
      return ExploreMemberLayout(
        tripDetails: widget.trip,
        scaffoldKey: scaffoldKey,
      );
    }
  }

  Widget getChatNotificationBadge() {
    return StreamBuilder<List<ChatModel>>(
      builder: (BuildContext context, AsyncSnapshot<List<ChatModel>> chats) {
        if (chats.hasError) {
          CloudFunction().logError('Error streaming chats for explore'
              ' chat notification: ${chats.error}');
        }
        if (chats.hasData) {
          final List<ChatModel> chatList = chats.data!;
          if (chatList.isNotEmpty) {
            final int chatNotifications = chatList.length;
            return Tooltip(
              message: 'Messages',
              child: BadgeIcon(
                icon: const Icon(
                  Icons.chat,
                ),
                badgeCount: chatNotifications,
              ),
            );
          } else {
            return const BadgeIcon(
              icon: Icon(
                Icons.chat,
              ),
            );
          }
        } else {
          return const BadgeIcon(
            icon: Icon(
              Icons.chat,
            ),
          );
        }
      },
      stream: chatListNotification,
    );
  }
}
