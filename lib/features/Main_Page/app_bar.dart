import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/generics/generic_bloc.dart';

import '../../blocs/generics/generic_state.dart';
import '../../blocs/generics/generics_event.dart';
import '../../models/notification_model/notification_model.dart';
import '../../models/public_profile_model/public_profile_model.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/user_repository.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../services/widgets/badge_icon.dart';
import '../../services/widgets/reusable_widgets.dart';
import '../../size_config/size_config.dart';
import '../Profile/logic/logic.dart';
import '../Trip_Management/logic/logic.dart';

/// Custom app bar
class CustomAppBar extends StatefulWidget {
  const CustomAppBar({
    Key? key,
    required this.bottomNav,
  }) : super(key: key);

  final bool bottomNav;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late GenericBloc<NotificationModel, NotificationRepository> bloc;
  @override
  void initState() {
    bloc =
        BlocProvider.of<GenericBloc<NotificationModel, NotificationRepository>>(
            context);
    bloc.add(LoadingGenericData());
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomShape(),
      child: Container(
        height: SizeConfig.screenHeight * .22,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Colors.blue[900]!, Colors.lightBlueAccent],
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              blurRadius: 10.0,
            ),
            BoxShadow(
              color: Colors.blueAccent,
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 16.0, 0),
          child: AppBar(
            toolbarHeight: SizerUtil.deviceType == DeviceType.tablet
                ? SizeConfig.screenHeight * .1
                : SizeConfig.screenHeight * .075,
            shadowColor: const Color(0x00000000),
            backgroundColor: const Color(0x00000000),
            actions: <Widget>[
              StreamBuilder(
                  stream: currentUserPublicProfile,
                  builder: (context, snapshot) {
                    
                    if (snapshot.hasData) {
                      UserPublicProfile profile = snapshot.data as UserPublicProfile;
                      return Center(
                        child: InkWell(
                          onTap: () {
                            navigationService.navigateTo(ProfilePageRoute);
                          },
                          child: Hero(
                            tag: profile.uid,
                            transitionOnUserGestures: true,
                            child: CircleAvatar(
                              radius: SizeConfig.screenWidth / 8.0,
                              backgroundImage: (profile.urlToImage?.isNotEmpty ?? false)
                                  ? NetworkImage(profile.urlToImage)
                                  : const NetworkImage(profileImagePlaceholder),
                            ),
                          ),
                        ),
                      );
                    } else{
                      return Center(
                        child: InkWell(
                          onTap: () {
                            navigationService.navigateTo(ProfilePageRoute);
                          },
                          child: Hero(
                            tag: userService.currentUserID,
                            transitionOnUserGestures: true,
                            child: CircleAvatar(
                              radius: SizeConfig.screenWidth / 8.0,
                              backgroundImage: const NetworkImage(profileImagePlaceholder),
                            ),
                          ),
                        ),
                      );
                    }
                  }),
              BlocBuilder<
                  GenericBloc<NotificationModel, NotificationRepository>,
                  GenericState>(
                builder: (BuildContext context, GenericState state) {
                  if (state is HasDataState) {
                    final List<NotificationModel> notifications =
                        state.data as List<NotificationModel>;

                    return IconButton(
                      icon: BadgeIcon(
                        icon: const IconThemeWidget(
                            icon: Icons.notifications_active),
                        badgeCount: notifications.length,
                      ),
                      onPressed: () {
                        navigationService.navigateTo(
                          NotificationsRoute,
                          arguments: notifications,
                        );
                      },
                    );
                  } else {
                    return IconButton(
                      icon:
                          const IconThemeWidget(icon: Icons.notifications_none),
                      onPressed: () {
                        navigationService.navigateTo(NotificationsRoute,
                            arguments: <NotificationModel>[]);
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
