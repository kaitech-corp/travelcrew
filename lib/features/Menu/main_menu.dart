// import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../blocs/authentication_bloc/authentication_event.dart';
import '../../models/public_profile_model/public_profile_model.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/navigation/route_names.dart';
import '../../services/theme/text_styles.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../size_config/size_config.dart';
import '../Profile/logic/logic.dart';

final ValueNotifier<int> chatNotifier = ValueNotifier<int>(0);

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  double defaultSize = SizeConfig.defaultSize;

  @override
  void initState() {
    super.initState();
    chatNotifier.value = 0;
  }

  double get imageSize {
    if (SizerUtil.deviceType == DeviceType.tablet) {
      return SizeConfig.screenWidth / 8.0;
    } else {
      return SizeConfig.screenWidth / 4.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SafeArea(
        child: Drawer(
            child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: StreamBuilder<UserPublicProfile>(
                  stream: currentUserPublicProfile,
                  builder:
                      (BuildContext context, AsyncSnapshot<Object?> snapshot) {
                    if (snapshot.hasData) {
                      final UserPublicProfile profile =
                          snapshot.data as UserPublicProfile;
                      return Stack(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'TC',
                                style: headlineMedium(context),
                              )),
                          Align(
                            child: CircleAvatar(
                              radius: imageSize,
                              backgroundImage:
                                  NetworkImage(profile.urlToImage!),
                            ),
                          )
                        ],
                      );
                    } else {
                      return Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'TC',
                              style: headlineMedium(context),
                            ),
                          ),
                          Align(
                            child: CircleAvatar(
                              radius: SizerUtil.deviceType == DeviceType.tablet
                                  ? SizeConfig.screenWidth / 8.0
                                  : SizeConfig.screenWidth / 4.0,
                              backgroundImage:
                                  const NetworkImage(profileImagePlaceholder),
                            ),
                          ),
                        ],
                      );
                    }
                  }),
            ),
            ListTile(
              leading: const IconThemeWidget(icon: Icons.people),
              title: Text('TC Members', style: titleMedium(context)),
              onTap: () {
                navigationService.navigateTo(UsersRoute);
              },
            ),
            ListTile(
              leading: const IconThemeWidget(icon: Icons.info),
              title: Text('Help & Feedback', style: titleMedium(context)),
              onTap: () {
                navigationService.navigateTo(HelpPageRoute);
              },
            ),
            ListTile(
              leading: const IconThemeWidget(icon: Icons.settings),
              title: Text('Settings', style: titleMedium(context)),
              onTap: () {
                navigationService.navigateTo(SettingsRoute);
              },
            ),
            if (userService.currentUserID.contains('XCVzgl7xIG3'))
              ListTile(
                leading:
                    const IconThemeWidget(icon: Icons.admin_panel_settings),
                title: Text('Admin', style: titleMedium(context)),
                onTap: () {
                  if (userService.currentUserID.contains('XCVzgl7xIG3')) {
                    navigationService.navigateTo(AdminPageRoute);
                  }
                },
              ),
            ListTile(
              leading: const IconThemeWidget(icon: Icons.exit_to_app),
              title: Text('Logout', style: titleMedium(context)),
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
      builder: (BuildContext context, AsyncSnapshot<String> data) {
        if (data.hasData) {
          final String version = data.data!;
          return Text(version, style: titleMedium(context));
        } else {
          return const Text('');
        }
      },
    );
  }
}
