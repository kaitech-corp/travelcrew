import 'package:flutter/material.dart';
import 'package:travelcrew/admin/admin_page.dart';
import 'package:travelcrew/services/auth.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/size_config/size_config.dart';


final ValueNotifier chatNotifier = ValueNotifier(int);

class MenuDrawer extends StatefulWidget{

  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  final AuthService _auth = AuthService();

  double defaultSize = SizeConfig.defaultSize;



  @override
  void initState() {
    super.initState();
    chatNotifier.value = 0;
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: SafeArea(
        child: Drawer(
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
                    width: defaultSize * 0.3, //8
                  ),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: (currentUserProfile.urlToImage?.isNotEmpty ?? false) ? NetworkImage(currentUserProfile.urlToImage,) :
                    AssetImage(profileImagePlaceholder)
                  ),
                ), child: const Text('TC'),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: Text('${currentUserProfile?.displayName ?? 'Just a sec...'}'),
                onTap: () {
                  Navigator.pushNamed(context, '/profilePage');
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: Text('TC Members'),
                onTap: () {
                  Navigator.pushNamed(context, '/usersFromMenu');
                },
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Chats'),
                onTap: () {
                  Navigator.pushNamed(context, '/chats_page');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text('Help & Feedback'),
                onTap: () {
                  Navigator.pushNamed(context, '/help');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  Navigator.pushNamed((context), '/settings');
                },
              ),
              if(currentUserProfile.uid.contains('XCVzgl7xIG3')) ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: Text('Admin'),
                onTap: () {
                  if(currentUserProfile.uid.contains('XCVzgl7xIG3')) Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: Text('Signout'),
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/wrapper', (route) => false);
                  _auth.logOut();
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(currentVersion),
              )
            ],
          ),
        ),
      ),
    );
  }

}