import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/add_trip/add_trip_page.dart';
import 'package:travelcrew/screens/app_bar/app_bar.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/current_crew_trips.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/past_crew_trips.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/screens/main_tab_page/all_trips_page/all_trips_page.dart';
import 'package:travelcrew/screens/main_tab_page/favorites/favorites.dart';
import 'package:travelcrew/screens/main_tab_page/notifications/notifications.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/badge_icon.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/push_notifications.dart';
import 'package:travelcrew/size_config/size_config.dart';
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
        CurrentCrewTrips(),
        PrivateTripList(),
        PastCrewTrips(),
      ],
    ),
    AllTripsPage(),
    AddTripPage(),
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
        // showSimpleNotification(
        if(message['aps']['category'] == 'chat') {
          Fluttertoast.showToast(
              msg: message['aps']['alert']['title'],
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
          );
        }

      },
      onLaunch: (Map<String, dynamic> message) async {

      },
      onResume: (Map<String, dynamic> message) async {
        // print("onResume: $message");
        print(message['aps']['alert']['title']);

        var type = message['aps']['category'];
        switch (type){
          case 'chat':{
            navigationService.pushReplacementNamed(WrapperRoute);
            // Navigator.pushReplacementNamed(context, '/wrapper');
          }
          break;
          case 'notifications':{
            navigationService.pushReplacementNamed(WrapperRoute);
            // Navigator.pushReplacementNamed(context, '/wrapper');
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
  Widget build(BuildContext context) {
    final notifications = Provider.of<List<NotificationData>>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          // appBar: TravelCrewAppBar(bottomTabBar: true,),
          drawer: MenuDrawer(),
          body: (_selectedIndex == 0) ? Stack(
            overflow: Overflow.visible,
            children: [
              CustomAppBar(bottomNav: true,),
              Padding(
                padding: EdgeInsets.only(top: SizeConfig.screenHeight/2*.32),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: TabBar(
                    labelStyle: Theme.of(context).textTheme.headline2,
                    isScrollable: true,
                    tabs: [
                      const Tab(text: 'Current',),
                      const Tab(text: 'Private',),
                      const Tab(text: 'Past',),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: SizeConfig.screenHeight/2*.45),
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
            ],
          ):
          Stack(
            children: [
              CustomAppBar(bottomNav: false,),
              Padding(
                padding: EdgeInsets.only(top: SizeConfig.screenHeight/2*.335),
                child: Center(
                  child: _widgetOptions.elementAt(_selectedIndex),
                ),
              ),
            ],
          ),
          bottomNavigationBar: CurvedNavigationBar(
            backgroundColor: ReusableThemeColor().bottomNavColor(context),
            color: ReusableThemeColor().color(context),
            items: [
              IconThemeWidget(icon:Icons.group),
              IconThemeWidget(icon:Icons.search),
              IconThemeWidget(icon: Icons.add_outlined,),
              IconThemeWidget(icon:Icons.favorite_border),
              BadgeIcon(
                icon: IconThemeWidget(icon:Icons.notifications_active),
                badgeCount: notifications != null ? notifications.length : 0,
              ),
            ],
            onTap: _onItemTapped,
            index: _selectedIndex,
          ),
        ),
      ),
    );
  }
}