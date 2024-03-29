import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/notification_bloc/notification_bloc.dart';
import '../../blocs/notification_bloc/notification_event.dart';
import '../../blocs/notification_bloc/notification_state.dart';
import '../../models/custom_objects.dart';
import '../../models/notification_model.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../services/widgets/badge_icon.dart';
import '../../services/widgets/reusable_widgets.dart';
import '../../size_config/size_config.dart';

/// Custom app bar
class CustomAppBar extends StatefulWidget {
  const CustomAppBar({
    Key? key,
    required this.bottomNav,
    this.notifications,
  }) : super(key: key);

  final bool bottomNav;
  final List<NotificationData>? notifications;
  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late NotificationBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<NotificationBloc>(context);
    bloc.add(LoadingNotificationData());
    super.initState();
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
                colors: <Color>[Colors.blue[900]!, Colors.lightBlueAccent]),
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
                  StreamBuilder<UserPublicProfile>(
                  stream:DatabaseService().currentUserPublicProfile,
                  builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
                    
                    if (snapshot.hasData) {
                      final UserPublicProfile profile = snapshot.data as UserPublicProfile;
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
                              backgroundImage:NetworkImage(profile.urlToImage.isNotEmpty ? profile.urlToImage : profileImagePlaceholder)
                                  ,
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
                  IconButton(
                    icon: const AppBarIconThemeWidget(icon: Icons.chat),
                    onPressed: () {
                      navigationService.navigateTo(DMChatListPageRoute);
                    },
                  ),
                  BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (BuildContext context, NotificationState state) {
                    if (state is NotificationLoadingState) {
                      return IconButton(
                        icon: const BadgeIcon(
                          icon: IconThemeWidget(icon: Icons.notifications_none),
                        ),
                        onPressed: () {
                          navigationService.navigateTo(NotificationsRoute);
                        },
                      );
                    } else if (state is NotificationHasDataState) {
                      final List<NotificationData> notifications = state.data;
                      return IconButton(
                        icon: BadgeIcon(
                          icon: const IconThemeWidget(
                              icon: Icons.notifications_active),
                          badgeCount: widget.notifications != null
                              ? widget.notifications!.length
                              : 0,
                        ),
                        onPressed: () {
                          navigationService.navigateTo(NotificationsRoute,arguments: notifications);
                        },
                      );
                    } else {
                      return IconButton(
                        icon: const BadgeIcon(
                          icon: IconThemeWidget(icon: Icons.notifications_none),
                        ),
                        onPressed: () {
                          navigationService.navigateTo(NotificationsRoute);
                        },
                      );
                    }
                  }),
                ],
              ))),
    );
  }
}
