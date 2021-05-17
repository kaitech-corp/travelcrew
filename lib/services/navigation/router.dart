import 'package:flutter/material.dart';
import 'package:travelcrew/admin/admin_page.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/add_trip/edit_trip.dart';
import 'package:travelcrew/screens/add_trip/google_places.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/screens/login_screen/signup_screen.dart';
import 'package:travelcrew/screens/main_tab_page/all_trips_page/all_trips_page.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/current_crew_trips.dart';
import 'package:travelcrew/screens/main_tab_page/favorites/favorites.dart';
import 'package:travelcrew/screens/main_tab_page/main_tab_page.dart';
import 'package:travelcrew/screens/main_tab_page/notifications/notifications.dart';
import 'package:travelcrew/screens/menu_screens/dm_chats/chats_page.dart';
import 'package:travelcrew/screens/menu_screens/help/feedback_page.dart';
import 'package:travelcrew/screens/menu_screens/help/help.dart';
import 'package:travelcrew/screens/menu_screens/help/report.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/screens/menu_screens/settings.dart';
import 'package:travelcrew/screens/menu_screens/users/dm_chat/dm_chat.dart';
import 'package:travelcrew/screens/menu_screens/users/user_profile_page.dart';
import 'package:travelcrew/screens/menu_screens/users/users.dart';
import 'package:travelcrew/screens/profile_page/edit_profile_page.dart';
import 'package:travelcrew/screens/profile_page/profile_page.dart';
import 'package:travelcrew/screens/trip_details/activity/activity.dart';
import 'package:travelcrew/screens/trip_details/activity/add_new_activity.dart';
import 'package:travelcrew/screens/trip_details/activity/edit_activity.dart';
import 'package:travelcrew/screens/trip_details/chat/chat.dart';
import 'package:travelcrew/screens/trip_details/cost/cost_split_page.dart';
import 'package:travelcrew/screens/trip_details/explore/explore.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_basic.dart';
import 'package:travelcrew/screens/trip_details/explore/followers/user_following_list_page.dart';
import 'package:travelcrew/screens/trip_details/explore/members/members_layout.dart';
import 'package:travelcrew/screens/trip_details/lodging/add_new_lodging.dart';
import 'package:travelcrew/screens/trip_details/lodging/edit_lodging.dart';
import 'package:travelcrew/screens/trip_details/lodging/lodging.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/size_config/size_config.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case ActivityRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: Activity(trip: args,),
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
    case AdminPageRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: AdminPage(),
      );
    case AllTripsPageRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: AllTripsPage(),
      );
    case ChatRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: Chat(trip: args,),
      );
    case CostPageRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: CostPage(tripDetails: args,),
      );
    case CurrentCrewTripsRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: CurrentCrewTrips(),
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
        viewToShow: EditActivity(activity: arguments.activity,trip: arguments.trip,),
      );
    case EditLodgingRoute:
      EditLodgingArguments arguments = settings.arguments;
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: EditLodging(trip: arguments.trip,lodging: arguments.lodging,),
      );
    case EditProfilePageRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: EditProfilePage(),
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
        viewToShow: Favorites(),
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
    case LodgingRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: Lodging(trip: args,),
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
        viewToShow: MembersLayout(members: arguments.members,tripDetails: arguments.tripDetails,ownerID: arguments.ownerID,),
      );
    case MenuDrawerRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: MenuDrawer(),
      );
    case NotificationsRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: Notifications(),
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
        viewToShow: Settings(),
      );
    case SignUpScreenRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: SignUpScreen(),
      );
    case UsersRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: Users(),
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
    // case WebViewScreenRoute:
    //   WebViewScreen argument = args;
    //   return _getPageRoute(
    //     routeName: settings.name,
    //     viewToShow: WebViewScreen(url: argument.url, key: argument.key,),
    //   );
    case WrapperRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: Wrapper(),
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

PageRoute _getPageRoute({String routeName, Widget viewToShow }) {
  return MaterialPageRoute(
      settings: RouteSettings(
        name: routeName,
      ),
      builder: (_) => viewToShow);
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

  ReportArguments(this.type, this.userAccount, this.activity,this.tripDetails,this.lodging);
}