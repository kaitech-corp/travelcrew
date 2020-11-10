import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/app_bar/app_bar.dart';
import 'package:travelcrew/screens/main_tab_page/explore_main/suggestions_page.dart';
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
  Widget build(BuildContext context) {
    final notifications = Provider.of<List<NotificationData>>(context);

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
              icon: const Icon(Icons.group),
              label: 'My Crew',
              backgroundColor: Colors.grey,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.assignment),
              label: 'All Trips',
              backgroundColor: Colors.grey,
            ),
            // BottomNavigationBarItem(
            //   icon: const Icon(Icons.photo_library),
            //   label: 'Explore',
            //   backgroundColor: Colors.grey,
            // ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite),
              label: 'Favorites',
              backgroundColor: Colors.grey,
            ),
            BottomNavigationBarItem(
              icon: BadgeIcon(
                icon: const Icon(Icons.notifications_active),
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
      appBar: TravelCrewAppBar(bottomTabBar: false),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(

        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.group),
            label: 'My Crew',
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment),
            label: 'All Trips',
            backgroundColor: Colors.grey,
          ),
          // BottomNavigationBarItem(
          //   icon: const Icon(Icons.photo_library),
          //   label: 'Explore',
          //   backgroundColor: Colors.grey,
          // ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: 'Favorites',
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: BadgeIcon(
              icon: const Icon(Icons.notifications_active),
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