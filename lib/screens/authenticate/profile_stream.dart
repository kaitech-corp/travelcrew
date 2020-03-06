import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/main_tab_page/main_tab_page.dart';
import 'package:travelcrew/services/database.dart';



class ProfileStream extends StatelessWidget{
  @override

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    return StreamProvider<UserProfile>.value(
      value: DatabaseService(uid: user.uid).currentUserPublicProfile,
      child: MaterialApp(
        home: MainTabPage(),
      ),
    );
  }
}