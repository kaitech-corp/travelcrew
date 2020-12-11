import 'package:flutter/material.dart';
import 'package:travelcrew/admin/admin_page.dart';
import 'package:travelcrew/services/appearance_widgets.dart';
import 'package:travelcrew/services/auth.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/database.dart';
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
            children: <Widget>[
              DrawerHeader(
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('TC',style: Theme.of(context).textTheme.subtitle1),
                    CircleAvatar(
                      radius: SizeConfig.screenWidth/4.0,
                      backgroundImage: (currentUserProfile?.urlToImage?.isNotEmpty ?? false) ? NetworkImage(currentUserProfile.urlToImage,) : AssetImage(profileImagePlaceholder),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: IconThemeWidget(icon:Icons.people),
                title: Text('TC Members',style: Theme.of(context).textTheme.subtitle1),
                onTap: () {
                  Navigator.pushNamed(context, '/usersFromMenu');
                },
              ),
              ListTile(
                leading: IconThemeWidget(icon: Icons.message,),
                title: Text('Chats',style: Theme.of(context).textTheme.subtitle1),
                onTap: () {
                  Navigator.pushNamed(context, '/chats_page');
                },
              ),
              ListTile(
                leading: IconThemeWidget(icon:Icons.info),
                title: Text('Help & Feedback',style: Theme.of(context).textTheme.subtitle1),
                onTap: () {
                  Navigator.pushNamed(context, '/help');
                },
              ),
              ListTile(
                leading: IconThemeWidget(icon:Icons.settings),
                title: Text('Settings',style: Theme.of(context).textTheme.subtitle1),
                onTap: () {
                  Navigator.pushNamed((context), '/settings');
                },
              ),
              if(currentUserProfile.uid.contains('XCVzgl7xIG3')) ListTile(
                leading: IconThemeWidget(icon:Icons.admin_panel_settings),
                title: Text('Admin',style: Theme.of(context).textTheme.subtitle1),
                onTap: () {
                  if(currentUserProfile.uid.contains('XCVzgl7xIG3')) Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminPage()),
                  );
                },
              ),
              ListTile(
                leading: IconThemeWidget(icon:Icons.exit_to_app),
                title: Text('Signout',style: Theme.of(context).textTheme.subtitle1),
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/wrapper', (route) => false);
                  // locator.reset();
                  _auth.logOut();
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: CurrentVersion(context),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  Widget CurrentVersion(BuildContext context){
    return FutureBuilder(
      future: DatabaseService().getVersion(),
        builder: (context, data){
          if(data.hasData){
            var version = data.data;
            return Text(version);
          } else {
            return Text('');
          }
        },
    );
}

}