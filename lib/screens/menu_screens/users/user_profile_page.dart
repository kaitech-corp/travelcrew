import 'package:flutter/material.dart';

import '../../../models/custom_objects.dart';
import '../../../services/widgets/reusableWidgets.dart';
import '../../profile_page/profile_widget.dart';

class UserProfilePage extends StatelessWidget{
  final UserPublicProfile user;

  UserProfilePage({ required this.user});

  Widget build(BuildContext context) {


    return Scaffold(
      body: Stack(
        children: [
          HangingImageTheme3(user: user,),
          ProfileWidget(user: user),
        ],
      ),
    );
  }
}

