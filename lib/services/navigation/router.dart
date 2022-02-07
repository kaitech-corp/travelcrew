
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../admin/admin_page.dart';
import '../../blocs/generics/generic_bloc.dart';
import '../../blocs/settings_bloc/settings_bloc.dart';
import '../../models/activity_model.dart';
import '../../models/custom_objects.dart';
import '../../models/lodging_model.dart';
import '../../models/split_model.dart';
import '../../models/transportation_model.dart';
import '../../models/trip_model.dart';
import '../../repositories_v1/user_settings_repository.dart';
import '../../repositories_v2/all_users_repository.dart';
import '../../repositories_v2/generic_repository.dart';
import '../../screens/add_trip/edit_trip.dart';
import '../../screens/add_trip/google_places.dart';
import '../../screens/main_tab_page/all_trips/all_trips_page.dart';
import '../../screens/main_tab_page/favorites/favorites_page.dart';
import '../../screens/main_tab_page/main_tab_page.dart';
import '../../screens/main_tab_page/my_trips_tab/current_trips/current_trips_page.dart';
import '../../screens/main_tab_page/notifications/notification_page.dart';
import '../../screens/menu_screens/help/feedback_page.dart';
import '../../screens/menu_screens/help/help.dart';
import '../../screens/menu_screens/help/report.dart';
import '../../screens/menu_screens/main_menu.dart';
import '../../screens/menu_screens/settings/settings.dart';
import '../../screens/menu_screens/users/all_users/all_users_page.dart';
import '../../screens/menu_screens/users/dm_chat/chats_page.dart';
import '../../screens/menu_screens/users/dm_chat/dm_chat.dart';
import '../../screens/menu_screens/users/user_profile_page.dart';
import '../../screens/profile_page/edit_profile_page.dart';
import '../../screens/profile_page/profile_page.dart';
import '../../screens/signup/signup_page.dart';
import '../../screens/trip_details/activity/activity_page.dart';
import '../../screens/trip_details/activity/add_new_activity.dart';
import '../../screens/trip_details/activity/edit_activity.dart';
import '../../screens/trip_details/basket_list/controller/basket_controller.dart';
import '../../screens/trip_details/basket_list/list_page.dart';
import '../../screens/trip_details/chat/chat_page.dart';
import '../../screens/trip_details/details/detail_page.dart';
import '../../screens/trip_details/explore/explore.dart';
import '../../screens/trip_details/explore/explore_basic.dart';
import '../../screens/trip_details/explore/followers/user_following_list_page.dart';
import '../../screens/trip_details/explore/lists/addToListPage.dart';
import '../../screens/trip_details/explore/members/members_layout.dart';
import '../../screens/trip_details/lodging/add_new_lodging.dart';
import '../../screens/trip_details/lodging/edit_lodging.dart';
import '../../screens/trip_details/lodging/lodging_page.dart';
import '../../screens/trip_details/split/split_details_page.dart';
import '../../screens/trip_details/split/split_page.dart';
import '../../screens/trip_details/transportation/add_new_transportation.dart';
import '../../screens/trip_details/transportation/edit_transportation.dart';
import '../../services/constants/constants.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/launch_icon_badger.dart';
import '../../size_config/size_config.dart';

/// The routes for all the widgets in this application.
Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case ActivityRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: ActivityPage(trip: args,),
      );
    case AddNewActivityRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: AddNewActivity(trip: args,),
      );
    case AddNewLodgingRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: AddNewLodging(trip: args,),
      );
    case AddNewTransportationRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: AddNewModeOfTransport(trip: args,),
      );
    case AdminPageRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: AdminPage(),
      );
    case AllTripsPageRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: AllTrips(),
      );
    case BasketListPageRoute:
      BasketListArguments arguments = settings.arguments;
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: BasketListPage(
          tripDetails: arguments.tripDetails,
          controller: arguments.basketController,
        ),
      );
    case ChatRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: ChatPage(trip: args,),
      );
    case CostPageRoute:
      Trip arguments = settings.arguments;
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: SplitPage(tripDetails: arguments,),
      );
    case CurrentCrewTripsRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: CurrentTrips(),
      );
    case DetailsPageRoute:
      DetailsPageArguments arguments = settings.arguments;
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: DetailsPage(
          trip: arguments.trip,
          activity: arguments.activity,
          lodging: arguments.lodging,
          type: arguments.type,
          transport: arguments.transport,
        ),
      );
    case DMChatRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: DMChat(user: args,),
      );
    case DMChatListPageRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: DMChatListPage(),
      );
    case EditActivityRoute:
      EditActivityArguments arguments = settings.arguments;
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: EditActivity(
          activity: arguments.activity,
          trip: arguments.trip,),
      );
    case EditLodgingRoute:
      EditLodgingArguments arguments = settings.arguments;
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: EditLodging(
          trip: arguments.trip,
          lodging: arguments.lodging,),
      );
    case EditProfilePageRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: EditProfilePage(),
      );
    case EditTransportationRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: EditTransportation(transportationData: args,),
      );
    case EditTripDataRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: EditTripData(tripDetails: args,),
      );
    case ExploreRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: Explore(trip: args,),
      );
    case ExploreBasicRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: ExploreBasic(trip: args,),
      );
    case FavoritesRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: FavoritesPage(),
      );
    case FeedbackPageRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: FeedbackPage(),
      );
    case FollowingListRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: FollowingList(tripDetails: args,),
      );
    case GooglePlacesRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: GooglePlaces(),
      );
    case HelpPageRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: HelpPage(),
      );
    case LaunchIconBadgerRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: LaunchIconBadger(),
      );
    case AddToListPageRoute:
      AddToListPageArguments arguments = settings.arguments;
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: AddToListPage(
          // controller: arguments.controller,
          scaffoldKey: arguments.scaffoldKey,
          tripDetails: arguments.tripDetails,),
      );
    case LodgingRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: LodgingPage(trip: args,),
      );
    case MainTabPageRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: MainTabPage(),
      );
    case MembersLayoutRoute:
      MembersLayoutArguments arguments = settings.arguments;
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: MembersLayout(
          tripDetails: arguments.tripDetails,
          ownerID: arguments.ownerID,),
      );
    case MenuDrawerRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: MenuDrawer(),
      );
    case NotificationsRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: NotificationPage(),
      );
    case ReportContentRoute:
      ReportArguments arguments = settings.arguments;
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: ReportContent(activity: arguments.activity,
          lodging: arguments.lodging,tripDetails: arguments.tripDetails,
          type: arguments.type,userAccount: arguments.userAccount,),
      );
    case SettingsRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: BlocProvider(
            create: (context) => UserSettingsBloc(
                userSettingsRepository: UserSettingsRepository()..refresh())
            ,child: Settings()),
      );
    case SignUpScreenRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: SignupScreen(),
      );
    case SplitDetailsPageRoute:
      SplitDetailsArguments arguments = settings.arguments;
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: SplitDetailsPage(
          tripDetails: arguments.trip,
          purchasedByUID: arguments.purchasedByUID,
          splitObject: arguments.splitObject,),
      );
    case UsersRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: BlocProvider(
            create: (context) => GenericBloc<UserPublicProfile, AllUserRepository>(
                repository: GenericRepository<UserPublicProfile, AllUserRepository>()..refresh()),
            child: AllUserPage()),
      );
    case UserProfilePageRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: UserProfilePage(user: args,),
      );
    case ProfilePageRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: ProfilePage(),
      );
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Oops!'),
            ),
            body: Center(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Image.asset(error,fit: BoxFit.cover,width: SizeConfig.screenWidth*.9,height: SizeConfig.screenWidth*.9,),
                    Text('Something went wrong. Sorry about that.',textScaleFactor: 1.5,textAlign: TextAlign.center,style: TextStyle(color: Colors.redAccent),),
                    SizedBox(height: 10,),
                    Text('Be sure to check your network connection just in case.',textScaleFactor: 1.5,textAlign: TextAlign.center,),
                  ],
                )),
          ));
  }
}

CupertinoPageRoute _getPageRoute({String routeName, Widget viewToShow }) {
  return CupertinoPageRoute(
      settings: RouteSettings(
        name: routeName,
      ),
      builder: (BuildContext context) => viewToShow);
}



class EditActivityArguments{
  final Trip trip;
  final ActivityData activity;

  EditActivityArguments(this.activity, this.trip);
}
class EditLodgingArguments{
  final Trip trip;
  final LodgingData lodging ;

  EditLodgingArguments(this.lodging, this.trip);
}
class DetailsPageArguments{
  final ActivityData activity;
  final LodgingData lodging;
  final TransportationData transport;
  final Trip trip;
  final String type;

  DetailsPageArguments({
    this.activity,
    this.lodging,
    this.transport,
    this.trip,
    this.type});

}
class AddToListPageArguments{
  final Trip tripDetails;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final PersistentBottomSheetController controller;

  AddToListPageArguments({this.tripDetails, this.scaffoldKey, this.controller});
}
class MembersLayoutArguments{
  final List<Members> members;
  final Trip tripDetails;
  final String ownerID;

  MembersLayoutArguments(this.members, this.tripDetails, this.ownerID);
}
class ReportArguments{
  final String type;
  final UserPublicProfile userAccount;
  final ActivityData activity;
  final LodgingData lodging;
  final Trip tripDetails;

  ReportArguments(
      this.type,
      this.userAccount,
      this.activity,
      this.tripDetails,
      this.lodging);
}
class SplitArguments{
  final Trip trip;

  SplitArguments(this.trip);
}
class SplitDetailsArguments{
  final SplitObject splitObject;
  final String purchasedByUID;
  final Trip trip;

  SplitDetailsArguments({this.splitObject, this.purchasedByUID, this.trip});

}

class BasketListArguments{
  final Trip tripDetails;
  final BasketController basketController;

  BasketListArguments({this.tripDetails, this.basketController});

}