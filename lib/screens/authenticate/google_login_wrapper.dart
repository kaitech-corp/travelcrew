import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/screens/authenticate/profile_stream.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/loading.dart';
import 'package:travelcrew/screens/login_screen/complete_profile_page.dart';
import 'package:travelcrew/services/database.dart';

class GoogleLoginWrapper extends StatefulWidget{
  @override
  _GoogleLoginWrapperState createState() => _GoogleLoginWrapperState();
}

class _GoogleLoginWrapperState extends State<GoogleLoginWrapper> {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

      return FutureBuilder(
        builder: (context, data) {
          if (data.data == false) {
            return CompleteProfile();
          } else if (data.data == null){
            return Loading();
          }
          return ProfileStream();
        },
        future: DatabaseService(uid: user.uid).checkUserHasProfile(),
      );
  }
}