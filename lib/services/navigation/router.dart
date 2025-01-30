// ignore_for_file: always_specify_types, cast_nullable_to_non_nullable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../admin/admin_page.dart';
import '../../blocs/generics/generic_bloc.dart';
import '../../models/activity_model/activity_model.dart';
import '../../models/lodging_model/lodging_model.dart';
import '../../models/member_model/member_model.dart';
import '../../models/notification_model/notification_model.dart';
import '../../models/public_profile_model/public_profile_model.dart';
import '../../models/split_model/split_model.dart';
import '../../models/transportation_model/transportation_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../../repositories/all_users_repository.dart';
import '../../screens/Activities/activity_page.dart';
import '../../screens/Activities/add_new_activity.dart';
import '../../screens/Activities/edit_activity.dart';
import '../../screens/Activity_Management/add_activity_page.dart';
import '../../screens/Auth/signup_screen.dart';
import '../../screens/Chat/chat_page.dart';
import '../../screens/Explore/detail_page.dart';
import '../../screens/Explore/explore.dart';
import '../../screens/Explore/explore_basic.dart';
import '../../screens/Explore/followers/user_following_list_page.dart';
import '../../screens/Explore/members/members_layout.dart';
import '../../screens/Lodging/add_new_lodging.dart';
import '../../screens/Lodging/edit_lodging.dart';
import '../../screens/Lodging/lodging_page.dart';
import '../../screens/Main_Page/main_page.dart';
import '../../screens/Menu/help/feedback_page.dart';
import '../../screens/Menu/help/help.dart';
import '../../screens/Menu/help/report.dart';
import '../../screens/Menu/main_menu.dart';
import '../../screens/Menu/settings/settings.dart';
import '../../screens/Notifications/notification_page.dart';
import '../../screens/Profile/edit_profile_page.dart';
import '../../screens/Profile/profile_page.dart';
import '../../screens/Split/split_details_page.dart';
import '../../screens/Split/split_page.dart';
import '../../screens/Transportation/add_new_transportation.dart';
import '../../screens/Transportation/edit_transportation.dart';
import '../../screens/Trip_Management/add_trip_page.dart';
import '../../screens/Trip_Management/edit_trip.dart';
import '../../screens/Trips/current_trips_page.dart';
import '../../screens/Users/all_users_page.dart';
import '../../screens/Users/user_profile_page.dart';
import '../../services/constants/constants.dart';
import '../../services/navigation/route_names.dart';
import '../../size_config/size_config.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final Object? args = settings.arguments;
  switch (settings.name!) {
    case ActivityRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: ActivityPage(
          trip: args! as Trip,
        ),
      );
    case AddNewActivityRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: AddNewActivity(
          trip: args as Trip,
        ),
      );
    case AddActivityRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const AddActivityPage(),
      );
    case AddNewLodgingRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: AddNewLodging(
          trip: args as Trip,
        ),
      );
    case AddNewTransportationRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: AddNewModeOfTransport(
          trip: args as Trip,
        ),
      );
    case AddNewTripRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow:  AddTripPage(
          type: args as String?,
        ),
      );
    case AdminPageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const AdminPage(),
      );
    case ChatRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: ChatPage(
          trip: args as Trip,
        ),
      );
    case CostPageRoute:
      final Trip arguments = settings.arguments as Trip;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: SplitPage(
          trip: arguments,
        ),
      );
    case CurrentCrewTripsRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const CurrentTrips(),
      );
    case DetailsPageRoute:
      final DetailsPageArguments arguments =
          settings.arguments as DetailsPageArguments;
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
    case EditActivityRoute:
      final EditActivityArguments arguments =
          settings.arguments as EditActivityArguments;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: EditActivity(
          activity: arguments.activity,
          trip: arguments.trip,
        ),
      );
    case EditLodgingRoute:
      final EditLodgingArguments arguments =
          settings.arguments as EditLodgingArguments;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: EditLodging(
          trip: arguments.trip,
          lodging: arguments.lodging,
        ),
      );
    case EditProfilePageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const EditProfilePage(),
      );
    case EditTransportationRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: EditTransportation(
          transportationData: args as TransportationModel,
        ),
      );
    case EditTripDataRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: EditTripData(
          trip: args as Trip,
        ),
      );
    case ExploreRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: Explore(
          trip: args as Trip,
        ),
      );
    case ExploreBasicRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: ExploreBasic(
          trip: args as Trip,
        ),
      );
    case FeedbackPageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const FeedbackPage(),
      );
    case FollowingListRoute:
      return _getPageRoute(
          routeName: settings.name!,
          viewToShow: BlocProvider(
            create: (BuildContext context) =>
                GenericBloc<UserPublicProfile, AllUserRepository>(
              repository: AllUserRepository(),
            ),
            child: FollowingList(
              trip: args as Trip,
            ),
          ));
    case HelpPageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const HelpPage(),
      );

    case LodgingRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: LodgingPage(
          trip: args as Trip,
        ),
      );
    case MainPageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const MainPage(),
      );
    case MembersLayoutRoute:
      final MembersLayoutArguments arguments =
          settings.arguments as MembersLayoutArguments;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: MembersLayout(
          trip: arguments.trip,
          ownerID: arguments.ownerID,
        ),
      );
    case MenuDrawerRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const MenuDrawer(),
      );
    case NotificationsRoute:
      final List<NotificationModel> arguments =
          settings.arguments as List<NotificationModel>;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: NotificationPage(
          notifications: arguments,
        ),
      );

    case ReportContentRoute:
      final ReportArguments arguments = settings.arguments as ReportArguments;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: ReportContent(
          activity: arguments.activity,
          lodging: arguments.lodging,
          trip: arguments.trip,
          type: arguments.type,
          userAccount: arguments.userAccount,
        ),
      );
    case SettingsRoute:
      return _getPageRoute(
          routeName: settings.name!,
          viewToShow:
              // BlocProvider(
              //     create: (BuildContext context) => UserSettingsBloc(
              //         userSettingsRepository: UserSettingsRepository()..refresh())
              //     ,child:
              const Settings()
          // ),
          );
    case SignUpScreenRoute:
      return _getPageRoute(
          routeName: settings.name!, viewToShow: const SignupScreen());
    case SplitDetailsPageRoute:
      final SplitDetailsArguments arguments =
          settings.arguments as SplitDetailsArguments;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: SplitDetailsPage(
          trip: arguments.trip,
          splitObject: arguments.splitObject,
        ),
      );
    case UsersRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: BlocProvider(
          create: (BuildContext context) =>
              GenericBloc<UserPublicProfile, AllUserRepository>(
            repository: AllUserRepository(),
          ),
          child: const AllUserPage(),
        ),
      );
    case UserProfilePageRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: UserProfilePage(
          user: args as UserPublicProfile,
        ),
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
                    const SizedBox(
                      height: 10,
                    ),
                    Image.asset(
                      error,
                      fit: BoxFit.cover,
                      width: SizeConfig.screenWidth * .9,
                      height: SizeConfig.screenWidth * .9,
                    ),
                    const Text(
                      'Something went wrong. Sorry about that.',
                      textScaler: TextScaler.linear(1.5),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Be sure to check your network connection just in case.',
                      textScaler: TextScaler.linear(1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )),
              ));
  }
}

MaterialPageRoute<Object> _getPageRoute(
    {required String routeName, required Widget viewToShow}) {
  return MaterialPageRoute<Object>(
      settings: RouteSettings(
        name: routeName,
      ),
      builder: (BuildContext context) => viewToShow);
}

class EditActivityArguments {
  EditActivityArguments(this.activity, this.trip);
  final Trip trip;
  final ActivityModel activity;
}

class EditLodgingArguments {
  EditLodgingArguments(this.lodging, this.trip);
  final Trip trip;
  final LodgingModel lodging;
}

class DetailsPageArguments {
  DetailsPageArguments(
      {this.activity,
      this.lodging,
      this.transport,
      required this.trip,
      required this.type});
  final ActivityModel? activity;
  final LodgingModel? lodging;
  final TransportationModel? transport;
  final Trip trip;
  final String type;
}

class AddToListPageArguments {
  AddToListPageArguments(
      {required this.trip,
      required this.scaffoldKey,
      required this.controller});
  final Trip trip;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final PersistentBottomSheetController controller;
}

class MembersLayoutArguments {
  MembersLayoutArguments(this.members, this.trip, this.ownerID);
  final List<MemberModel> members;
  final Trip trip;
  final String ownerID;
}

class ReportArguments {
  ReportArguments(
      this.type, this.userAccount, this.activity, this.trip, this.lodging);
  final String type;
  final UserPublicProfile userAccount;
  final ActivityModel? activity;
  final LodgingModel? lodging;
  final Trip? trip;
}

class SplitArguments {
  SplitArguments(this.trip);
  final Trip trip;
}

class SplitDetailsArguments {
  SplitDetailsArguments({required this.splitObject, required this.trip});
  final SplitObject splitObject;
  final Trip trip;
}
