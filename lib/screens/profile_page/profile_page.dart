import 'package:flutter/material.dart';

import '../../models/custom_objects.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/widgets/reusableWidgets.dart';
import '../../size_config/size_config.dart';
import 'profile_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double defaultSize = SizeConfig.defaultSize;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          StreamBuilder<UserPublicProfile>(
            builder: (BuildContext context,
                AsyncSnapshot<UserPublicProfile> userData) {
              if (userData.hasError) {
                CloudFunction()
                    .logError('Error streaming user data for Profile Page: '
                        '${userData.error.toString()}');
              }
              if (userData.hasData) {
                final UserPublicProfile user = userData.data!;

                return Stack(children: <Widget>[
                  HangingImageTheme3(
                    user: user,
                  ),
                  ProfileWidget(user: user)
                ]);
              } else {
                return ProfileWidget(user: defaultProfile);
              }
            },
            stream: DatabaseService().currentUserPublicProfile,
          ),
        ],
      ),
    );
  }
}
