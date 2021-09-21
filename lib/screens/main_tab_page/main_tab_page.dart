import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:travelcrew/models/notification_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/add_trip/add_trip_page.dart';
import 'package:travelcrew/screens/app_bar/app_bar.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/badge_icon.dart';
import 'package:travelcrew/size_config/size_config.dart';

import '../../size_config/size_config.dart';
import 'all_trips/all_trips_page.dart';
import 'favorites/favorites_page.dart';
import 'my_trips_tab/current_trips/current_trips_page.dart';
import 'my_trips_tab/past_trips/past_trip_page.dart';
import 'my_trips_tab/private_trips/private_trip_page.dart';
import 'notifications/notification_page.dart';

class MainTabPage extends StatefulWidget {

  final List<NotificationData> notifications;

  MainTabPage({Key key, this.notifications}) :  super(key: key);


  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();

}
class _MyStatefulWidgetState extends State<MainTabPage> {

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      RemoteNotification message =  event.notification;
      String tripDocID = event.data['docID'];
      if (tripDocID?.isNotEmpty ?? false) {
        CloudFunction().addNewNotification(type: 'Chat',message: message.title,documentID: tripDocID,ownerID: userService.currentUserID);
      }
      Fluttertoast.showToast(
              msg: message.title,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
            );
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) async {
      // RemoteNotification message =  event.notification;
      String tripDocID = event.data['docID'];
      if(tripDocID?.isNotEmpty ?? false){
        Trip trip = await DatabaseService().getTrip(tripDocID);
        try {
          navigationService.navigateTo(ExploreRoute, arguments: trip);
        } catch (e) {
          CloudFunction().logError('onMessageOpenedApp- Not a valid trip:  ${e.toString()}');
        }
      } else{
        navigationService.navigateTo(DMChatListPageRoute);
      }
    });
  }

  void dispose(){
    super.dispose();
}

  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    TabBarView(
      children: [
        CurrentTrips(),
        PastTrips(),
        PrivateTrips(),

      ],
    ),
    AllTrips(),
    AddTripPage(),
    FavoritesPage(),
    NotificationPage(),];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          drawer: MenuDrawer(),
          body: (_selectedIndex == 0) ? Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomAppBar(bottomNav: true,),
                      Padding(
                        padding: EdgeInsets.only(top: SizeConfig.screenHeight*.175),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: TabBar(
                            labelStyle: Theme.of(context).textTheme.headline6,
                            isScrollable: true,
                            tabs: [
                              const Tab(text: 'Current',),
                              const Tab(text: 'Past',),
                              const Tab(text: 'Private',),
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
                        padding: EdgeInsets.only(top: SizeConfig.screenHeight*.1785),
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
              const IconThemeWidget(icon:Icons.group),
              const IconThemeWidget(icon:Icons.search),
              const IconThemeWidget(icon: Icons.add_outlined,),
              const IconThemeWidget(icon:Icons.favorite_border),
              BadgeIcon(
                icon: IconThemeWidget(icon:Icons.notifications_active),
                badgeCount: widget.notifications != null ? widget.notifications.length : 0,
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

