// ignore_for_file: always_specify_types

import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/current_profile_bloc/current_profile_bloc.dart';
import '../../blocs/generics/generic_bloc.dart';
import '../../blocs/notification_bloc/notification_bloc.dart';
import '../../blocs/notification_bloc/notification_event.dart';
import '../../blocs/notification_bloc/notification_state.dart';
import '../../models/trip_model.dart';
import '../../repositories/current_user_profile_repository.dart';
import '../../repositories/trip_repositories/private_trip_repository.dart';
import '../../services/widgets/loading.dart';
import '../main_tab_page/main_tab_page.dart';

/// Profile stream to initiate all blocs
class ProfileStream extends StatefulWidget {
  const ProfileStream({
    Key? key,
    required this.uid,
  }) : super(key: key);
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
        providers: [
          BlocProvider(
              create: (BuildContext context) => CurrentProfileBloc(
                  currentUserProfileRepository: CurrentUserProfileRepository()
                    ..refresh())),
        ],
        child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (BuildContext context, NotificationState state) {
          if (state is NotificationLoadingState) {
            return const Loading();
          } else if (state is NotificationHasDataState) {
            FlutterAppBadger.updateBadgeCount(state.data.length);
            return MainTabPage(
              notifications: state.data,
            );
          } else {
            return const MainTabPage(
              notifications: [],
            );
          }
        }));
  }
}
