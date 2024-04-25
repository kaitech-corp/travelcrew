import 'package:flutter/material.dart';

import '../../../services/widgets/reusable_widgets.dart';
import '../../models/public_profile_model/public_profile_model.dart';
import '../Profile/profile_widget.dart';


class UserProfilePage extends StatelessWidget{

  const UserProfilePage({super.key,  required this.user});
  final UserPublicProfile user;

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Stack(
        children: <Widget>[
          HangingImageTheme3(user: user,),
          ProfileWidget(user: user),
        ],
      ),
    );
  }
}
