import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/main_tab_page/users/users_text_section.dart';

import '../../loading.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();

}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    bool loading = true;
    final allUsersList = Provider.of<List<UserProfile>>(context);
    if(allUsersList != null) {
      setState(() {
       loading = false;
      });
    }

    return loading ? Loading() : ListView.builder(
        itemCount: allUsersList.length ?? 0,
        itemBuilder: (context, index){
          return UsersTextSection(allUsers: allUsersList[index]);
        });
  }
}