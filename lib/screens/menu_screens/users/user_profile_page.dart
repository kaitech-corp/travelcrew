import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/profile_page/profile_widget.dart';
import 'package:travelcrew/services/reusableWidgets.dart';

class UserProfilePage extends StatelessWidget{
  final UserPublicProfile user;

  UserProfilePage({this.user});

  Widget build(BuildContext context) {


    return Scaffold(
      body: Stack(
        children: [
          HangingImageTheme3(),
          ProfileWidget(user: user),
        ],
      ),
    );
  }
}

