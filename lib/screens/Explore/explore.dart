// ignore_for_file: always_specify_types

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/public_profile_bloc/public_profile_bloc.dart';
import '../../../repositories/chat_repository.dart';
import '../../../repositories/lodging_repository.dart';
import '../../../repositories/split_repository.dart';
import '../../../repositories/user_profile_repository.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/theme/text_styles.dart';
import '../../../size_config/size_config.dart';
import '../../models/activity_model/activity_model.dart';
import '../../models/chat_model/chat_model.dart';
import '../../models/lodging_model/lodging_model.dart';
import '../../models/split_model/split_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../../repositories/activity_repository.dart';
import '../Activities/activity_page.dart';
import '../Lodging/lodging_page.dart';
import '../Menu/main_menu.dart';
import '../Split/split_page.dart';
import '../chat/chat_page.dart';
import 'explore_member_layout.dart';
import 'explore_owner_layout.dart';

/// Explore page for trip
class Explore extends StatefulWidget {
  const Explore({
    super.key,
    required this.trip,
  });

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
      length: 5,
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
           
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  navigationService.pop();
                },
              ),
            ],
            bottom: TabBar(
              indicatorColor: Colors.blueGrey,
              labelStyle: SizeConfig.tablet
                  ? headlineSmall(context)
                  : titleSmall(context),
              // isScrollable: true,
              tabs: <Tab>[
                Tab(
                  icon: tabIcon(Icons.home)
                ),
                Tab(
                  icon: tabIcon(
                    Icons.monetization_on,
                  ),
                ),
                Tab(
                  icon: tabIcon(
                    Icons.hotel,
                  ),
                ),
                Tab(
                  icon: tabIcon(
                    Icons.directions_bike,
                  ),
                ),
                Tab(
                  icon: tabIcon(
                    Icons.chat,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              checkOwner(),
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

  Widget tabIcon(IconData icon) {
    return CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: Icon(
          icon, color: Colors.black87,
        ));
  }

  Widget checkOwner() {
    final String uid = userService.currentUserID;
    if (widget.trip.ownerID == uid) {
      return ExploreOwnerLayout(
        trip: widget.trip,
        scaffoldKey: scaffoldKey,
      );
    } else {
      return ExploreMemberLayout(
        trip: widget.trip,
        scaffoldKey: scaffoldKey,
      );
    }
  }
}
