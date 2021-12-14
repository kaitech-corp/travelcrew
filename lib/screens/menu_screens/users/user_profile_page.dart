import 'package:flutter/material.dart';
import '../../../models/custom_objects.dart';
import '../../profile_page/profile_widget.dart';
import '../../../services/widgets/reusableWidgets.dart';

class UserProfilePage extends StatelessWidget{
  final UserPublicProfile user;

  UserProfilePage({this.user});

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

