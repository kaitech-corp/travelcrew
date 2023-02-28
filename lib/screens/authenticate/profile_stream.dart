// ignore_for_file: always_specify_types

import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/current_profile_bloc/current_profile_bloc.dart';
import '../../blocs/notification_bloc/notification_bloc.dart';
import '../../blocs/notification_bloc/notification_event.dart';
import '../../blocs/notification_bloc/notification_state.dart';
import '../../repositories/current_user_profile_repository.dart';
import '../../repositories/notification_repository.dart';
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
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
          create: (BuildContext context) => CurrentProfileBloc(
              currentUserProfileRepository: CurrentUserProfileRepository()
                ..refresh())),
      BlocProvider(
          create: (BuildContext context) => NotificationBloc(
              notificationRepository: NotificationRepository()..refresh()))
    ], child: const MainTabPage());
  }
}
