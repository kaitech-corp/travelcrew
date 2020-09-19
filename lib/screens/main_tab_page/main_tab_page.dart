import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/add_trip/add_trip.dart';
import 'package:travelcrew/screens/app_bar/app_bar.dart';
import 'package:travelcrew/screens/main_tab_page/all_trips_page/all_trips_page.dart';
import 'package:travelcrew/screens/main_tab_page/favorites/favorites.dart';
import 'package:travelcrew/screens/main_tab_page/notifications/notifications.dart';
import 'package:travelcrew/screens/menu_screens/users/users.dart';
import 'package:travelcrew/screens/profile_page/profile_page.dart';
import 'package:travelcrew/services/auth.dart';
import 'package:travelcrew/services/badge_icon.dart';
import 'crew_trips/crew_trips.dart';
import 'crew_trips/private_trips.dart';
import 'explore_main/explore_main.dart';


class MainTabPage extends StatefulWidget {
  MainTabPage({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();

}
class _MyStatefulWidgetState extends State<MainTabPage> {

  int _selectedIndex = 0;
  final AuthService _auth = AuthService();
  final List<Widget> _widgetOptions = <Widget>[
    TabBarView(
      children: [
        CrewTrips(type: 0),
        CrewTrips(type: 1),
        PrivateTripList(),
      ],
    ),
    AllTripsPage(),
    // ExploreMain(),
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
        body: Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
        bottomNavigationBar: BottomNavigationBar(

          items:  <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              title: Text('My Crew'),
              backgroundColor: Colors.grey,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              title: Text('All Trips'),
              backgroundColor: Colors.grey,
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.search),
            //   title: Text('Explore'),
            //   backgroundColor: Colors.grey,
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              title: Text('Favorites'),
              backgroundColor: Colors.grey,
            ),
            BottomNavigationBarItem(
              icon: BadgeIcon(
                icon: Icon(Icons.notifications_active),
                badgeCount: notifications != null ? notifications.length : 0,
              ),
              title: Text('Notifications'),
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
      appBar: AppBar(
        centerTitle: true,
        leading: PopupMenuButton<String>(
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
              value: 'signout',
              child: ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Signout'),
              ),
            ),
          ],
        ),
        title: const Text('Travel Crew'),
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
            title: Text('My Crew'),
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            title: Text('All Trips'),
            backgroundColor: Colors.grey,
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.search),
          //   title: Text('Explore'),
          //   backgroundColor: Colors.grey,
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            title: Text('Favorites'),
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: BadgeIcon(
              icon: Icon(Icons.notifications_active),
              badgeCount: notifications != null ? notifications.length : 0,
            ),
            title: Text('Notifications'),
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