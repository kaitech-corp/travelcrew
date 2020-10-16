import 'package:flutter/material.dart';
import 'package:travelcrew/admin/admin_page.dart';
import 'package:travelcrew/screens/menu_screens/help/help.dart';
import 'package:travelcrew/screens/menu_screens/users/users.dart';
import 'package:travelcrew/screens/profile_page/profile_page.dart';
import 'package:travelcrew/services/auth.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/size_config/size_config.dart';

class MainMenuButtons extends StatelessWidget{

  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    return PopupMenuButton<String>(

      shape: Border.all(color: Colors.grey, width: 5),
      onSelected: (value) async{
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
            Navigator.pop(context);
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
         PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('${currentUserProfile.displayName}'),
          ),
        ),
        const PopupMenuItem(
          value: 'users',
          child: ListTile(
            leading: Icon(Icons.people),
            title: Text('TC Members'),
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

class MenuDrawer extends StatelessWidget{

  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  final AuthService _auth = AuthService();
  double defaultSize = SizeConfig.defaultSize;

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            // child: Align(alignment: Alignment.bottomCenter ,child: Text('Menu')),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: defaultSize * 0.25, //8
              ),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: (currentUserProfile.urlToImage?.isNotEmpty ?? false) ? NetworkImage(currentUserProfile.urlToImage,) :
                AssetImage(profileImagePlaceholder)
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('${currentUserProfile.displayName}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('TC Members'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Users()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Help & Feedback'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()),
              );
            },
          ),
          if(currentUserProfile.uid.contains('XCVzgl7xIG3')) ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              if(currentUserProfile.uid.contains('XCVzgl7xIG3')) Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Signout'),
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/wrapper', (route) => false);
              _auth.logOut();
            },
          ),
        ],
      ),
    );
  }

}