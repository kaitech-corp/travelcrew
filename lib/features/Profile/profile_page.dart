import 'package:flutter/material.dart';

import '../../models/public_profile_model/public_profile_model.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/widgets/reusable_widgets.dart';
import '../../size_config/size_config.dart';
import 'logic/logic.dart';
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
                        '${userData.error}');
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
                return ProfileWidget(user: UserPublicProfile.mock());
              }
            },
            stream: currentUserPublicProfile,
          ),
        ],
      ),
    );
  }
}
