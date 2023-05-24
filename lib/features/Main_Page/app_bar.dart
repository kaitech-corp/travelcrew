import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/notification_bloc/notification_bloc.dart';
import '../../blocs/notification_bloc/notification_state.dart';
import '../../models/notification_model/notification_model.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../services/widgets/badge_icon.dart';
import '../../services/widgets/reusable_widgets.dart';
import '../../size_config/size_config.dart';

/// Custom app bar
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    Key? key,
    required this.bottomNav,
    this.notifications,
  }) : super(key: key);

  final bool bottomNav;
  final List<NotificationModel>? notifications;

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<NotificationBloc>(context);

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
              Center(
                child: InkWell(
                  onTap: () {
                    navigationService.navigateTo(ProfilePageRoute);
                  },
                  child: Hero(
                    tag: userService.currentUserID,
                    transitionOnUserGestures: true,
                    child: CircleAvatar(
                      radius: SizeConfig.screenWidth / 8.0,
                      backgroundImage: urlToImage.value.isNotEmpty
                          ? NetworkImage(urlToImage.value)
                          : const NetworkImage(profileImagePlaceholder),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const AppBarIconThemeWidget(icon: Icons.chat),
                onPressed: () {
                  navigationService.navigateTo(DMChatListPageRoute);
                },
              ),
              // BlocBuilder<NotificationBloc, NotificationState>(
              //   bloc: bloc,
              //   builder: (BuildContext context, NotificationState state) {
              //     if (state is NotificationLoadingState) {
              //       return IconButton(
              //         icon: const BadgeIcon(
              //           icon: IconThemeWidget(icon: Icons.notifications_none),
              //         ),
              //         onPressed: () {
              //           navigationService.navigateTo(NotificationsRoute);
              //         },
              //       );
              //     } else if (state is NotificationHasDataState) {
              //       final List<NotificationModel> notifications =
              //           state.data;
              //       return IconButton(
              //         icon: const BadgeIcon(
              //           icon: IconThemeWidget(icon: Icons.notifications_active),
              //         ),
              //         onPressed: () {
              //           navigationService.navigateTo(
              //             NotificationsRoute,
              //             arguments: notifications,
              //           );
              //         },
              //         // badgeCount: this.notifications?.length ?? 0,
              //       );
              //     } else {
              //       return IconButton(
              //         icon: const BadgeIcon(
              //           icon: IconThemeWidget(icon: Icons.notifications_none),
              //         ),
              //         onPressed: () {
              //           navigationService.navigateTo(NotificationsRoute);
              //         },
              //       );
              //     }
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}