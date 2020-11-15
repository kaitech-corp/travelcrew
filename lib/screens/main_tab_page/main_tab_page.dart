import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/app_bar/app_bar.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/screens/main_tab_page/all_trips_page/all_trips_page.dart';
import 'package:travelcrew/screens/main_tab_page/favorites/favorites.dart';
import 'package:travelcrew/screens/main_tab_page/notifications/notifications.dart';
import 'package:travelcrew/services/badge_icon.dart';
import 'package:travelcrew/services/push_notifications.dart';
import 'crew_trips/crew_trips.dart';
import 'crew_trips/private_trips.dart';


class MainTabPage extends StatefulWidget {
  MainTabPage({Key key}) : super(key: key);


  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();

}
class _MyStatefulWidgetState extends State<MainTabPage> {

  Color bottomNavColor = Colors.grey;

  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    TabBarView(
      children: [
        CrewTrips(type: 0),
        PrivateTripList(),
        CrewTrips(type: 1),

      ],
    ),
    AllTripsPage(),
    // SuggestionsPage(),
    Favorites(),
    Notifications(),];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
      FirebaseMessaging().configure(
      onMessage:
          (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // showDialog(
        //   context: context,
        //   builder: (context) =>
        //       AlertDialog(
        //         content: ListTile(
        //           title: Text(message['aps']['alert']['title']),
        //           subtitle: Text(message['aps']['alert']['body']),
        //         ),
        //         actions: <Widget>[
        //           FlatButton(
        //             child: const Text('Ok'),
        //             onPressed: () => Navigator.of(context).pop(),
        //           ),
        //         ],
        //       ),
        // );
      },
      onLaunch: (Map<String, dynamic> message) async {

      },
      onResume: (Map<String, dynamic> message) async {
        // print("onResume: $message");
        print(message['aps']['alert']['title']);

        var type = message['aps']['category'];
        switch (type){
          case 'chat':{
            Navigator.pushReplacementNamed(context, '/wrapper');
          }
          break;
          case 'notifications':{
            Navigator.pushReplacementNamed(context, '/wrapper');
          }
          break;
          default: {
            showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    content: ListTile(
                      title: Text(message['aps']['alert']['title']),
                      subtitle: Text(message['aps']['alert']['body']),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('Ok'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
            );
          }
        }

      },
    );
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(ThemeProvider.themeOf(context).id == 'light_theme'){
      setState(() {
        bottomNavColor = Colors.black12;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = Provider.of<List<NotificationData>>(context);

    return _selectedIndex == 0 ? DefaultTabController(
      length: 3,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: TravelCrewAppBar(bottomTabBar: true,),
          drawer: MenuDrawer(),
          body: Center(
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.black,

            items:  <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.group),
                label: 'My Crew',
                backgroundColor: bottomNavColor,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.assignment),
                label: 'All Trips',
                backgroundColor: bottomNavColor,
              ),
              // BottomNavigationBarItem(
              //   icon: const Icon(Icons.photo_library),
              //   label: 'Explore',
              //   backgroundColor: Colors.grey,
              // ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite),
                label: 'Favorites',
                backgroundColor: bottomNavColor,
              ),
              BottomNavigationBarItem(
                icon: BadgeIcon(
                  icon: const Icon(Icons.notifications_active),
                  badgeCount: notifications != null ? notifications.length : 0,
                ),
                label: 'Notifications',
                backgroundColor: bottomNavColor,
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.lightBlue[100],
            onTap: _onItemTapped,
          ),
        ),
      ),
    ):
    Scaffold(
      drawer: MenuDrawer(),
      appBar: TravelCrewAppBar(bottomTabBar: false),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.group),
            label: 'My Crew',
            backgroundColor: bottomNavColor,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment),
            label: 'All Trips',
            backgroundColor: bottomNavColor,
          ),
          // BottomNavigationBarItem(
          //   icon: const Icon(Icons.photo_library),
          //   label: 'Explore',
          //   backgroundColor: Colors.grey,
          // ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: 'Favorites',
            backgroundColor: bottomNavColor,
          ),
          BottomNavigationBarItem(
            icon: BadgeIcon(
              icon: const Icon(Icons.notifications_active),
              badgeCount: notifications != null ? notifications.length : 0,
            ),
            label: 'Notifications',
            backgroundColor: bottomNavColor,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue[100],
        onTap: _onItemTapped,
      ),
    );
  }



}