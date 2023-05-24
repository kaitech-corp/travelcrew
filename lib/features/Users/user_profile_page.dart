import 'package:flutter/material.dart';

import '../../../services/widgets/reusable_widgets.dart';
import '../../models/public_profile_model/public_profile_model.dart';
import '../Profile/profile_widget.dart';


class UserProfilePage extends StatelessWidget{

  const UserProfilePage({Key? key,  required this.user}) : super(key: key);
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
