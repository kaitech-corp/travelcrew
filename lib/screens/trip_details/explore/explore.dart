import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/blocs/activities_bloc/activity_bloc.dart';
import 'package:travelcrew/blocs/chat_bloc/chat_bloc.dart';
import 'package:travelcrew/blocs/lodging_bloc/lodging_bloc.dart';
import 'package:travelcrew/blocs/public_profile_bloc/public_profile_bloc.dart';
import 'package:travelcrew/blocs/transportation_bloc/transportation_bloc.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/repositories/activity_repository.dart';
import 'package:travelcrew/repositories/chat_repository.dart';
import 'package:travelcrew/repositories/lodging_repository.dart';
import 'package:travelcrew/repositories/transportation_repository.dart';
import 'package:travelcrew/repositories/user_profile_repository.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/screens/trip_details/activity/activity_page.dart';
import 'package:travelcrew/screens/trip_details/chat/chat_page.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_member_layout.dart';
import 'package:travelcrew/screens/trip_details/lodging/lodging_page.dart';
import 'package:travelcrew/screens/trip_details/split/split_page.dart';
import 'package:travelcrew/screens/trip_details/transportation/transportation_page.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/widgets/badge_icon.dart';
import 'package:travelcrew/size_config/size_config.dart';

import 'explore_owner_layout.dart';


class Explore extends StatelessWidget {

  final Trip trip;
  Explore({this.trip,});

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        key: scaffoldKey,
        drawer: BlocProvider(
          create: (context) => PublicProfileBloc(
              profileRepository: PublicProfileRepository()..refresh(userService.currentUserID)),
          child: MenuDrawer(),),
        appBar: AppBar(
          centerTitle: true,
          title: Text('Explore',style: Theme.of(context).textTheme.headline5,),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _closeModalBottomSheet;
                navigationService.pop();
              },
            ),
          ],
          bottom: TabBar(
            labelStyle: SizeConfig.tablet ? Theme.of(context).textTheme.headline6 : Theme.of(context).textTheme.subtitle2,
            isScrollable: true,
            tabs: [
              const Tab(icon: const Icon(Icons.home,),),
              const Tab(icon: const Icon(Icons.monetization_on,),),
              const Tab(icon: const Icon(Icons.flight_takeoff,),),
              const Tab(icon: const Icon(Icons.hotel,),),
              const Tab(icon: const Icon(Icons.directions_bike,),),
              Tab(icon: getChatNotificationBadge()),
            ],
          ),
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => ActivityBloc(activityRepository: ActivityRepository()..refresh(trip.documentId))),
            BlocProvider(create: (context) => ChatBloc(chatRepository: ChatRepository()..refresh(trip.documentId))),
            BlocProvider(create: (context) => LodgingBloc(lodgingRepository: LodgingRepository()..refresh(trip.documentId))),
            BlocProvider(create: (context) => TransportationBloc(transportationRepository: TransportationRepository()..refresh(trip.documentId))),
          ],
          child: TabBarView(
            children: [
              checkOwner(userService.currentUserID),
              SplitPage(tripDetails: trip),
              TransportationPage(trip: trip,),
              LodgingPage(trip: trip,),
              ActivityPage(trip: trip,),
              ChatPage(trip: trip,),
            ],
          ),
        )
      ),
    );
  }

  void _closeModalBottomSheet() {
    if (controller != null) {
      controller.close();
      controller = null;
    }
  }

   checkOwner(String uid) {
  if (trip.ownerID == uid){
  return ExploreOwnerLayout(tripDetails: trip,controller: controller,scaffoldKey: scaffoldKey,);
  } else {
  return ExploreMemberLayout(tripDetails: trip,controller: controller,scaffoldKey: scaffoldKey,);
  }
}

Widget getChatNotificationBadge (){
    return StreamBuilder(
        builder: (context, chats){
          if(chats.hasError){
            CloudFunction().logError('Error streaming chats for explore chat notification: ${chats.error.toString()}');
          }
          if(chats.hasData){
            if(chats.data.length > 0) {
              int chatNotifications = chats.data.length;
              return Tooltip(
                message: 'Messages',
                child: BadgeIcon(
                  icon: const Icon(Icons.chat,),
                  badgeCount: chatNotifications,
                ),
              );
            } else {
              return BadgeIcon(
                icon: const Icon(Icons.chat, ),
                badgeCount: 0,
              );
            }
          } else {
            return BadgeIcon(
              icon: const Icon(Icons.chat, ),
              badgeCount: 0,
            );
          }
        },
      stream: DatabaseService(tripDocID: trip.documentId).chatListNotification,
    );
}
}

