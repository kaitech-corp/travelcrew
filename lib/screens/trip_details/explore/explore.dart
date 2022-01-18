import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/activities_bloc/activity_bloc.dart';
import '../../../blocs/chat_bloc/chat_bloc.dart';
import '../../../blocs/lodging_bloc/lodging_bloc.dart';
import '../../../blocs/public_profile_bloc/public_profile_bloc.dart';
import '../../../blocs/split_bloc/split_bloc.dart';
import '../../../blocs/transportation_bloc/transportation_bloc.dart';
import '../../../models/chat_model.dart';
import '../../../models/trip_model.dart';
import '../../../repositories/activity_repository.dart';
import '../../../repositories/chat_repository.dart';
import '../../../repositories/lodging_repository.dart';
import '../../../repositories/split_repository.dart';
import '../../../repositories/transportation_repository.dart';
import '../../../repositories/user_profile_repository.dart';
import '../../menu_screens/main_menu.dart';
import '../activity/activity_page.dart';
import '../chat/chat_page.dart';
import 'explore_member_layout.dart';
import '../lodging/lodging_page.dart';
import '../split/split_page.dart';
import '../transportation/transportation_page.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/widgets/badge_icon.dart';
import '../../../size_config/size_config.dart';
import 'explore_owner_layout.dart';


class Explore extends StatelessWidget {

  final Trip trip;
  Explore({this.trip,});

  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  static PersistentBottomSheetController controller;


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        key: scaffoldKey,
        drawer: BlocProvider(
          create: (BuildContext context) => PublicProfileBloc(
              profileRepository: PublicProfileRepository()..refresh(userService.currentUserID)),
          child: MenuDrawer(),),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: canvasColor,
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
            labelStyle: SizeConfig.tablet
                ? Theme.of(context).textTheme.headline6
                : Theme.of(context).textTheme.subtitle2,
            isScrollable: true,
            tabs:   <Tab>[
              const Tab(icon: Icon(Icons.home,),),
              const Tab(icon: Icon(Icons.monetization_on,),),
              const Tab(icon: Icon(Icons.flight_takeoff,),),
              const Tab(icon: Icon(Icons.hotel,),),
              const Tab(icon: Icon(Icons.directions_bike,),),
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
            BlocProvider(create: (context) => SplitBloc(splitRepository: SplitRepository()..refresh(trip.documentId))),
          ],
          child: TabBarView(
                    children: <Widget>[
                      checkOwner(userService.currentUserID),
                      SplitPage(tripDetails: trip),
                      TransportationPage(trip: trip,),
                      LodgingPage(trip: trip,),
                      ActivityPage(trip: trip,),
                      ChatPage(trip: trip,),
                    ],
                  )
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

   Widget checkOwner(String uid) {
  if (trip.ownerID == uid){
    return StreamBuilder<Trip>(
        stream: DatabaseService(tripDocID: trip.documentId).singleTripData,
        builder: (context, document){
          if(document.hasData){
            final Trip tripDetails = document.data;
            return ExploreOwnerLayout(
              tripDetails: tripDetails,
              controller: controller,
              scaffoldKey: scaffoldKey,);
          } else {
            return ExploreOwnerLayout(
              tripDetails: trip,
              controller: controller,
              scaffoldKey: scaffoldKey,);
          }
        }
    );
  } else {
  return ExploreMemberLayout(tripDetails: trip,controller: controller,scaffoldKey: scaffoldKey,);
  }
}

Widget getChatNotificationBadge (){
    return StreamBuilder<List<ChatData>>(
        builder: (context, chats){
          if(chats.hasError){
            CloudFunction()
                .logError('Error streaming chats for explore'
                ' chat notification: ${chats.error.toString()}');
          }
          if(chats.hasData){
            final List<ChatData> chatList = chats.data;
            if(chatList.isNotEmpty) {
              final int chatNotifications = chats.data.length;
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
              );
            }
          } else {
            return BadgeIcon(
              icon: const Icon(Icons.chat, ),
            );
          }
        },
      stream: DatabaseService(tripDocID: trip.documentId).chatListNotification,
    );
}
}

