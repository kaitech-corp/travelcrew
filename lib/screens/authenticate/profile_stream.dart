import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/generics/generic_bloc.dart';
import '../../blocs/notifications_bloc/notification_bloc.dart';
import '../../blocs/notifications_bloc/notification_event.dart';
import '../../blocs/notifications_bloc/notification_state.dart';
import '../../models/custom_objects.dart';
import '../../models/trip_model.dart';
import '../../repositories_v2/current_user_profile_repository.dart';
import '../../repositories_v2/generic_repository.dart';
import '../../repositories_v2/trip_ad_repository.dart';
import '../../repositories_v2/trip_repositories/all_trip_repository.dart';
import '../../repositories_v2/trip_repositories/current_trip_repository.dart';
import '../../repositories_v2/trip_repositories/favorite_trip_repository.dart';
import '../../repositories_v2/trip_repositories/past_trip_repository.dart';
import '../../repositories_v2/trip_repositories/private_trip_repository.dart';
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
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => GenericBloc<Trip,CurrentTripRepository>(repository: GenericRepository<Trip, CurrentTripRepository>()..refresh())),
          BlocProvider(create: (context) => GenericBloc<Trip,PastTripRepository>(repository: GenericRepository<Trip, PastTripRepository>()..refresh())),
          BlocProvider(create: (context) => GenericBloc<Trip,PrivateTripRepository>(repository: GenericRepository<Trip, PrivateTripRepository>()..refresh())),
          BlocProvider(create: (context) => GenericBloc<Trip,AllTripsRepository>(repository: GenericRepository<Trip, AllTripsRepository>()..refresh())),
          BlocProvider(create: (context) => GenericBloc<Trip,FavoriteTripRepository>(repository: GenericRepository<Trip, FavoriteTripRepository>()..refresh())),
          BlocProvider(create: (context) => GenericBloc<UserPublicProfile,CurrentUserProfileRepository>(repository: GenericRepository<UserPublicProfile, CurrentUserProfileRepository>()..refresh())),
          BlocProvider(create: (context) => GenericBloc<TripAds,TripAdRepository>(repository: GenericRepository<TripAds, TripAdRepository>()..refresh())),
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
        ));
  }
}

