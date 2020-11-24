import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/reusableWidgets.dart';

class UserProfilePage extends StatelessWidget{
  UserPublicProfile user;
  var userService = locator<UserService>();


  UserProfilePage({this.user});

  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Profile',style: Theme.of(context).textTheme.headline3,),
      ),
      body: ProfileWidget( user: user),
    );
  }
}

