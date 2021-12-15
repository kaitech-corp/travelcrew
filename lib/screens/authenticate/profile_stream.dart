import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/all_trips_bloc/all_trips_bloc.dart';
import '../../blocs/crew_trips_bloc/current_crew_trips_bloc/current_crew_trips_bloc.dart';
import '../../blocs/crew_trips_bloc/past_crew_trips_bloc/past_crew_trips_bloc.dart';
import '../../blocs/crew_trips_bloc/private_crew_trips_bloc/private_crew_trips_bloc.dart';
import '../../blocs/current_profile_bloc/current_profile_bloc.dart';
import '../../blocs/favorite_trips_bloc/favorite_trip_bloc.dart';
import '../../blocs/notifications_bloc/notification_bloc.dart';
import '../../blocs/notifications_bloc/notification_event.dart';
import '../../blocs/notifications_bloc/notification_state.dart';
import '../../blocs/trip_ad_bloc/trip_ad_bloc.dart';
import '../../repositories/current_user_profile_repository.dart';
import '../../repositories/trip_ad_repository.dart';
import '../../repositories/trip_repositories/all_trip_repository.dart';
import '../../repositories/trip_repositories/current_trip_repository.dart';
import '../../repositories/trip_repositories/favorite_trip_repository.dart';
import '../../repositories/trip_repositories/past_trip_repository.dart';
import '../../repositories/trip_repositories/private_trip_repository.dart';
import '../../services/locator.dart';
import '../../services/widgets/loading.dart';
import '../main_tab_page/main_tab_page.dart';


/// Profile stream to initiate all blocs
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
              BlocProvider(create: (context) => CurrentCrewTripBloc(tripRepository: CurrentTripRepository()..refresh() )),
              BlocProvider(create: (context) => PastCrewTripBloc(tripRepository: PastTripRepository()..refresh() )),
              BlocProvider(create: (context) => PrivateTripBloc(tripRepository: PrivateTripRepository()..refresh() )),
              BlocProvider(create: (context) => AllTripBloc(tripRepository: AllTripRepository()..refresh() )),
              BlocProvider(create: (context) => FavoriteTripBloc(tripRepository: FavoriteTripRepository()..refresh() )),
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

