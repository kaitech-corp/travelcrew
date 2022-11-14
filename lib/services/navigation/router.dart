
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
import '../../repositories/all_users_repository.dart';
import '../../repositories/user_settings_repository.dart';
import '../../screens/add_trip/add_trip_page.dart';
import '../../screens/add_trip/edit_trip.dart';
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


Route<dynamic> generateRoute(RouteSettings settings) {
  final Object? args = settings.arguments;
  switch (settings.name!) {
    case ActivityRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: ActivityPage(trip: args as Trip,),
      );
    case AddNewActivityRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: AddNewActivity(trip: args as Trip,),
      );
    case AddNewLodgingRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: AddNewLodging(trip: args as Trip,),
      );
    case AddNewTransportationRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: AddNewModeOfTransport(trip: args as Trip,),
      );
    case AddNewTripRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: AddTripPage(addedLocation: args as String,),
      );
    case AdminPageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const AdminPage(),
      );
    case AllTripsPageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const AllTrips(),
      );
    case BasketListPageRoute:
      final BasketListArguments arguments = settings.arguments as BasketListArguments;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: BasketListPage(
          trip: arguments.trip,
          controller: arguments.basketController,
        ),
      );
    case ChatRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: ChatPage(trip: args as Trip,),
      );
    case CostPageRoute:
      final Trip arguments = settings.arguments as Trip;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: SplitPage(trip: arguments,),
      );
    case CurrentCrewTripsRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const CurrentTrips(),
      );
    case DetailsPageRoute:
      final DetailsPageArguments arguments = settings.arguments as DetailsPageArguments;
      return _getPageRoute(
        routeName: settings.name!,
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
        routeName: settings.name!,
        viewToShow: DMChat(user: args as UserPublicProfile,),
      );
    case DMChatListPageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const DMChatListPage(),
      );
    case EditActivityRoute:
      final EditActivityArguments arguments = settings.arguments as EditActivityArguments;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: EditActivity(
          activity: arguments.activity,
          trip: arguments.trip,),
      );
    case EditLodgingRoute:
      final EditLodgingArguments arguments = settings.arguments as EditLodgingArguments;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: EditLodging(
          trip: arguments.trip,
          lodging: arguments.lodging,),
      );
    case EditProfilePageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const EditProfilePage(),
      );
    case EditTransportationRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: EditTransportation(transportationData: args as TransportationData,),
      );
    case EditTripDataRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: EditTripData(trip: args as Trip,),
      );
    case ExploreRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: Explore(trip: args as Trip,),
      );
    case ExploreBasicRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: ExploreBasic(trip: args as Trip,),
      );
    case FavoritesRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const FavoritesPage(),
      );
    case FeedbackPageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const FeedbackPage(),
      );
    case FollowingListRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: FollowingList(trip: args as Trip,),
      );
    // case GooglePlacesRoute:
    //   return _getPageRoute(
    //     routeName: settings.name!,
    //     viewToShow: GooglePlaces(controller: ,),
    //   );
    case HelpPageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const HelpPage(),
      );
    case LaunchIconBadgerRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const LaunchIconBadger(),
      );
    case AddToListPageRoute:
      final AddToListPageArguments arguments = settings.arguments as AddToListPageArguments;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: AddToListPage(
          controller: arguments.controller as BasketController,
          scaffoldKey: arguments.scaffoldKey,
          trip: arguments.trip,),
      );
    case LodgingRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: LodgingPage(trip: args as Trip,),
      );
    case MainTabPageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const MainTabPage(),
      );
    case MembersLayoutRoute:
      final MembersLayoutArguments arguments = settings.arguments as MembersLayoutArguments;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: MembersLayout(
          trip: arguments.trip,
          ownerID: arguments.ownerID,),
      );
    case MenuDrawerRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const MenuDrawer(),
      );
    case NotificationsRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const NotificationPage(),
      );
    case ReportContentRoute:
      final ReportArguments arguments = settings.arguments as ReportArguments;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: ReportContent(activity: arguments.activity,
          lodging: arguments.lodging, trip: arguments.trip,
          type: arguments.type,userAccount: arguments.userAccount,),
      );
    case SettingsRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: BlocProvider(
            create: (BuildContext context) => UserSettingsBloc(
                userSettingsRepository: UserSettingsRepository()..refresh())
            ,child: const Settings()),
      );
    case SignUpScreenRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const SignupScreen(),
      );
    case SplitDetailsPageRoute:
      final SplitDetailsArguments arguments = settings.arguments as SplitDetailsArguments;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: SplitDetailsPage(
          trip: arguments.trip,
          splitObject: arguments.splitObject,),
      );
    case UsersRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: BlocProvider(
            create: (BuildContext context) => GenericBloc<UserPublicProfile, AllUserRepository>(
                repository: AllUserRepository(),),
          child: const AllUserPage(),
        ),
      );
    case UserProfilePageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: UserProfilePage(user: args as UserPublicProfile,),
      );
    case ProfilePageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const ProfilePage(),
      );
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Oops!'),
            ),
            body: Center(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 10,),
                    Image.asset(error,fit: BoxFit.cover,width: SizeConfig.screenWidth*.9,height: SizeConfig.screenWidth*.9,),
                    const Text('Something went wrong. Sorry about that.',textScaleFactor: 1.5,textAlign: TextAlign.center,style: TextStyle(color: Colors.redAccent),),
                    const SizedBox(height: 10,),
                    const Text('Be sure to check your network connection just in case.',textScaleFactor: 1.5,textAlign: TextAlign.center,),
                  ],
                )),
          ));
  }
}

MaterialPageRoute<Object> _getPageRoute({required String routeName, required Widget viewToShow }) {
  return MaterialPageRoute<Object>(
      settings: RouteSettings(
        name: routeName,
      ),
      builder: (BuildContext context) => viewToShow);
}



class EditActivityArguments{

  EditActivityArguments(this.activity, this.trip);
  final Trip trip;
  final ActivityData activity;
}
class EditLodgingArguments{

  EditLodgingArguments(this.lodging, this.trip);
  final Trip trip;
  final LodgingData lodging ;
}
class DetailsPageArguments{

  DetailsPageArguments({
    this.activity,
    this.lodging,
    this.transport,
    required this.trip,
    required this.type});
  final ActivityData? activity;
  final LodgingData? lodging;
  final TransportationData? transport;
  final Trip trip;
  final String type;

}
class AddToListPageArguments{

  AddToListPageArguments({required this.trip, required this.scaffoldKey, required this.controller});
  final Trip trip;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final PersistentBottomSheetController<dynamic> controller;
}
class MembersLayoutArguments{

  MembersLayoutArguments(this.members, this.trip, this.ownerID);
  final List<Members> members;
  final Trip trip;
  final String ownerID;
}
class ReportArguments{

  ReportArguments(
      this.type,
      this.userAccount,
      this.activity,
      this.trip,
      this.lodging);
  final String type;
  final UserPublicProfile userAccount;
  final ActivityData? activity;
  final LodgingData? lodging;
  final Trip? trip;
}
class SplitArguments{

  SplitArguments(this.trip);
  final Trip trip;
}
class SplitDetailsArguments{

  SplitDetailsArguments({required this.splitObject, required this.trip});
  final SplitObject splitObject;
  final Trip trip;

}

class BasketListArguments{

  BasketListArguments({required this.trip, required this.basketController});
  final Trip trip;
  final BasketController basketController;

}
