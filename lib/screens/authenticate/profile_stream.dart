import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/blocs/all_trips_bloc/all_trips_bloc.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/current_crew_trips_bloc/current_crew_trips_bloc.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/past_crew_trips_bloc/past_crew_trips_bloc.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/private_crew_trips_bloc/private_crew_trips_bloc.dart';
import 'package:travelcrew/blocs/current_profile_bloc/current_profile_bloc.dart';
import 'package:travelcrew/blocs/favorite_trips_bloc/favorite_trip_bloc.dart';
import 'package:travelcrew/blocs/notifications_bloc/notification_bloc.dart';
import 'package:travelcrew/blocs/notifications_bloc/notification_event.dart';
import 'package:travelcrew/blocs/notifications_bloc/notification_state.dart';
import 'package:travelcrew/blocs/trip_ad_bloc/trip_ad_bloc.dart';
import 'package:travelcrew/repositories/current_user_profile_repository.dart';
import 'package:travelcrew/repositories/trip_ad_repository.dart';
import 'package:travelcrew/repositories/trip_repository.dart';
import 'package:travelcrew/screens/main_tab_page/main_tab_page.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/widgets/loading.dart';



class ProfileStream extends StatefulWidget {
  final String uid;

  const ProfileStream({Key key, this.uid,}) : super(key: key);

  @override
  _ProfileStreamState createState() => _ProfileStreamState();
}

class _ProfileStreamState extends State<ProfileStream> {
  NotificationBloc bloc;
  final currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  @override
  void initState() {
    bloc = BlocProvider.of<NotificationBloc>(context);
    bloc.add(LoadingNotificationData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => CurrentCrewTripBloc(tripRepository: TripRepository()..refresh() )),
              BlocProvider(create: (context) => PastCrewTripBloc(tripRepository: TripRepository()..refreshPastTrips() )),
              BlocProvider(create: (context) => PrivateTripBloc(tripRepository: TripRepository()..refreshPrivateTrips() )),
              BlocProvider(create: (context) => AllTripBloc(tripRepository: TripRepository()..refreshAllTrips() )),
              BlocProvider(create: (context) => FavoriteTripBloc(tripRepository: TripRepository()..refreshFavoriteTrips() )),
              BlocProvider(create: (context) => CurrentProfileBloc(currentUserProfileRepository: CurrentUserProfileRepository()..refresh())),
              BlocProvider(create: (context) => TripAdBloc(tripAdRepository: TripAdRepository()..refresh())),
            ],
            child: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state){
                  if(state is NotificationLoadingState){
                    return Loading();
                  } else if (state is NotificationHasDataState){
                    FlutterAppBadger.updateBadgeCount(state.data.length);
                    return MainTabPage(notifications: state.data,);
                  } else {
                    return MainTabPage(notifications: null,);
                  }}
            )));
  }
}

