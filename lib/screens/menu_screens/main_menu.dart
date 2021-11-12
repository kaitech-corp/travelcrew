import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:travelcrew/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:travelcrew/blocs/authentication_bloc/authentication_event.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/size_config/size_config.dart';

final ValueNotifier chatNotifier = ValueNotifier(int);

class MenuDrawer extends StatefulWidget {

  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  double defaultSize = SizeConfig.defaultSize;

  @override
  void initState() {
    super.initState();
    chatNotifier.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: SafeArea(
        child: Drawer(
            child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: StreamBuilder<UserPublicProfile>(
                builder: (context, profile) {
                  if (profile.hasData) {
                    final UserPublicProfile currentUser = profile.data;
                    return Stack(
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text('TC',
                                style: Theme.of(context).textTheme.headline5)),
                        Align(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            radius: SizerUtil.deviceType == DeviceType.tablet
                                ? SizeConfig.screenWidth / 8.0
                                : SizeConfig.screenWidth / 4.0,
                            backgroundImage:
                                (currentUser.urlToImage?.isNotEmpty ?? false)
                                    ? NetworkImage(
                                        currentUser.urlToImage,
                                      )
                                    : AssetImage(profileImagePlaceholder),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text('TC',
                              style: Theme.of(context).textTheme.headline5),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            radius: SizerUtil.deviceType == DeviceType.tablet
                                ? SizeConfig.screenWidth / 8.0
                                : SizeConfig.screenWidth / 4.0,
                            backgroundImage:
                                const AssetImage(profileImagePlaceholder),
                          ),
                        ),
                      ],
                    );
                  }
                },
                stream: DatabaseService().currentUserPublicProfile,
              ),
            ),
            ListTile(
              leading: const IconThemeWidget(icon: Icons.people),
              title: Text('TC Members',
                  style: Theme.of(context).textTheme.subtitle1),
              onTap: () {
                navigationService.navigateTo(UsersRoute);
              },
            ),
            ListTile(
              leading: const IconThemeWidget(
                icon: Icons.message,
              ),
              title:
                  Text('Chats', style: Theme.of(context).textTheme.subtitle1),
              onTap: () {
                navigationService.navigateTo(DMChatListPageRoute);
              },
            ),
            ListTile(
              leading: const IconThemeWidget(icon: Icons.info),
              title: Text('Help & Feedback',
                  style: Theme.of(context).textTheme.subtitle1),
              onTap: () {
                navigationService.navigateTo(HelpPageRoute);
              },
            ),
            ListTile(
              leading: const IconThemeWidget(icon: Icons.settings),
              title: Text('Settings',
                  style: Theme.of(context).textTheme.subtitle1),
              onTap: () {
                navigationService.navigateTo(SettingsRoute);
              },
            ),
            if (userService.currentUserID.contains('XCVzgl7xIG3'))
              ListTile(
                leading: const IconThemeWidget(
                    icon: Icons.admin_panel_settings),
                title:
                    Text('Admin', style: Theme.of(context).textTheme.subtitle1),
                onTap: () {
                  if (userService.currentUserID.contains('XCVzgl7xIG3'))
                    navigationService.navigateTo(AdminPageRoute);
                },
              ),
            ListTile(
              leading: const IconThemeWidget(icon: Icons.exit_to_app),
              title:
                  Text('Logout', style: Theme.of(context).textTheme.subtitle1),
              onTap: () {
                // locator.reset();
                BlocProvider.of<AuthenticationBloc>(context)
                    .add(AuthenticationLoggedOut());
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: currentVersion(context),
            )
          ],
        )),
      ),
    );
  }

  Widget currentVersion(BuildContext context) {
    return FutureBuilder<String>(
      future: DatabaseService().getVersion(),
      builder: (context, data) {
        if (data.hasData) {
          final String version = data.data;
          return Text(version, style: Theme.of(context).textTheme.subtitle1);
        } else {
          return const Text('');
        }
      },
    );
  }
}
