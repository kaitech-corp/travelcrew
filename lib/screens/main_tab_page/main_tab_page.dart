import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/add_trip/add_trip.dart';
import 'package:travelcrew/screens/app_bar/app_bar.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/screens/main_tab_page/all_trips_page/all_trips_page.dart';
import 'package:travelcrew/screens/main_tab_page/favorites/favorites.dart';
import 'package:travelcrew/screens/main_tab_page/notifications/notifications.dart';
import 'package:travelcrew/services/badge_icon.dart';
import 'crew_trips/crew_trips.dart';
import 'crew_trips/private_trips.dart';


class MainTabPage extends StatefulWidget {
  MainTabPage({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();

}
class _MyStatefulWidgetState extends State<MainTabPage> {

  String _appBadgeSupported = 'Unknown';

  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    TabBarView(
      children: [
        CrewTrips(type: 0),
        CrewTrips(type: 1),
        PrivateTripList(),
      ],
    ),
    AllTripsPage(),
    Favorites(),
    Notifications(),];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {
    String appBadgeSupported;
    try {
      bool res = await FlutterAppBadger.isAppBadgeSupported();
      if (res) {
        appBadgeSupported = 'Supported';
      } else {
        appBadgeSupported = 'Not supported';
      }
    } on PlatformException {
      appBadgeSupported = 'Failed to get badge support.';
    }

    if (!mounted) return;

    setState(() {
      _appBadgeSupported = appBadgeSupported;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = Provider.of<List<NotificationData>>(context);
    if (notifications != null) {
      FlutterAppBadger.updateBadgeCount(notifications.length);
    }
    return _selectedIndex == 0 ? DefaultTabController(
      length: 3,
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
              icon: Icon(Icons.group),
              label: 'My Crew',
              backgroundColor: Colors.grey,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'All Trips',
              backgroundColor: Colors.grey,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
              backgroundColor: Colors.grey,
            ),
            BottomNavigationBarItem(
              icon: BadgeIcon(
                icon: Icon(Icons.notifications_active),
                badgeCount: notifications != null ? notifications.length : 0,
              ),
              label: 'Notifications',
              backgroundColor: Colors.grey,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.lightBlue[100],
          onTap: _onItemTapped,
        ),
      ),
    ):
    Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Travel Crew',style: Theme.of(context).textTheme.headline3,),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTrip()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(

        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'My Crew',
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'All Trips',
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: BadgeIcon(
              icon: Icon(Icons.notifications_active),
              badgeCount: notifications != null ? notifications.length : 0,
            ),
            label: 'Notifications',
            backgroundColor: Colors.grey,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue[100],
        onTap: _onItemTapped,
      ),
    );
  }



}