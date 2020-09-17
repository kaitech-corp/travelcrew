import 'package:flutter/material.dart';
import 'package:travelcrew/screens/menu_screens/help/help.dart';
import 'package:travelcrew/screens/menu_screens/users/users.dart';
import 'package:travelcrew/screens/profile_page/profile_page.dart';
import 'package:travelcrew/services/auth.dart';

class PopupMenuButtons extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    // TODO: implement build
    return PopupMenuButton<String>(
      onSelected: (value){
        switch (value){
          case "profile": {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          }
          break;
          case "users": {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Users()),
            );
          }
          break;
          case "help": {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpPage()),
            );
          }
          break;
          case "signout": {
            _auth.logOut();
          }
          break;
          default: {

          }
          break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (context) =>[
        const PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
        ),
        const PopupMenuItem(
          value: 'users',
          child: ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Users'),
          ),
        ),
        const PopupMenuItem(
          value: 'help',
          child: ListTile(
            leading: Icon(Icons.info),
            title: Text('Help & Feedback'),
          ),
        ),
        const PopupMenuItem(
          value: 'signout',
          child: ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Signout'),
          ),
        ),
      ],
    );
  }

}