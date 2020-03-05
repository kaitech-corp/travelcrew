import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/main_tab_page/users/user_list.dart';
import 'package:travelcrew/services/database.dart';

class Users extends StatelessWidget{

  Users();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<UserProfile>>.value(
      value: DatabaseService().userList,
      child: Container (
        child: UserList(),
      ),
    );
  }
}