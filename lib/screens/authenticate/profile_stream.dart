import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/blocs/current_profile_bloc/current_profile_bloc.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/repositories/current_user_profile_repository.dart';

import '../../blocs/generics/generic_bloc.dart';
import '../../blocs/notification_bloc/notification_bloc.dart';
import '../../blocs/notification_bloc/notification_event.dart';
import '../../blocs/notification_bloc/notification_state.dart';
import '../../repositories/trip_ad_repository.dart';
import '../../repositories/trip_repositories/all_trip_repository.dart';
import '../../repositories/trip_repositories/all_trip_suggestion_repository.dart';
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
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => GenericBloc<Trip,CurrentTripRepository>(repository: CurrentTripRepository())),
          BlocProvider(create: (context) => GenericBloc<Trip,PastTripRepository>(repository: PastTripRepository())),
          BlocProvider(create: (context) => GenericBloc<Trip,PrivateTripRepository>(repository: PrivateTripRepository())),
          BlocProvider(create: (context) => GenericBloc<Trip,AllTripsRepository>(repository: AllTripsRepository())),
          BlocProvider(create: (context) => GenericBloc<Trip,FavoriteTripRepository>(repository: FavoriteTripRepository())),
          BlocProvider(create: (context) => CurrentProfileBloc(currentUserProfileRepository: CurrentUserProfileRepository()..refresh())),
          BlocProvider(create: (context) => GenericBloc<TripAds,TripAdRepository>(repository: TripAdRepository())),
          BlocProvider(create: (context) => GenericBloc<Trip,AllTripsSuggestionRepository>(repository: AllTripsSuggestionRepository())),
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

