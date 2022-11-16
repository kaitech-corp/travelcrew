import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/current_profile_bloc/current_profile_bloc.dart';
import '../../blocs/generics/generic_bloc.dart';
import '../../blocs/notification_bloc/notification_bloc.dart';
import '../../blocs/notification_bloc/notification_event.dart';
import '../../blocs/notification_bloc/notification_state.dart';
import '../../models/custom_objects.dart';
import '../../models/trip_model.dart';
import '../../repositories/current_user_profile_repository.dart';
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

  const ProfileStream({Key? key, required this.uid,}) : super(key: key);
  final String uid;

  @override
  State<ProfileStream> createState() => _ProfileStreamState();
}

class _ProfileStreamState extends State<ProfileStream> {
  late NotificationBloc bloc;


  @override
  void initState() {
    bloc = BlocProvider.of<NotificationBloc>(context);
    bloc.add(LoadingNotificationData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider(create: (BuildContext context) => GenericBloc<Trip,CurrentTripRepository>(repository: CurrentTripRepository())),
          BlocProvider(create: (BuildContext context) => GenericBloc<Trip,PastTripRepository>(repository: PastTripRepository())),
          BlocProvider(create: (BuildContext context) => GenericBloc<Trip,PrivateTripRepository>(repository: PrivateTripRepository())),
          BlocProvider(create: (BuildContext context) => GenericBloc<Trip,AllTripsRepository>(repository: AllTripsRepository())),
          BlocProvider(create: (BuildContext context) => GenericBloc<Trip,FavoriteTripRepository>(repository: FavoriteTripRepository())),
          BlocProvider(create: (BuildContext context) => CurrentProfileBloc(currentUserProfileRepository: CurrentUserProfileRepository()..refresh())),
          BlocProvider(create: (BuildContext context) => GenericBloc<TripAds,TripAdRepository>(repository: TripAdRepository())),
          BlocProvider(create: (BuildContext context) => GenericBloc<Trip,AllTripsSuggestionRepository>(repository: AllTripsSuggestionRepository())),
        ],
        child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (BuildContext context, NotificationState state){
              if(state is NotificationLoadingState){
                return const Loading();
              } else if (state is NotificationHasDataState){
                FlutterAppBadger.updateBadgeCount(state.data.length);
                return MainTabPage(notifications: state.data,);
              } else {
                return const MainTabPage(notifications: [],);
              }}
        ));
  }
}
