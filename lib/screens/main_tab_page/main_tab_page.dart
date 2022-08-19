import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../models/notification_model.dart';
import '../../models/trip_model.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../services/widgets/badge_icon.dart';
import '../../size_config/size_config.dart';
import '../add_trip/add_trip_page.dart';
import '../app_bar/app_bar.dart';
import '../menu_screens/main_menu.dart';
import 'all_trips/all_trips_page.dart';
import 'favorites/favorites_page.dart';
import 'my_trips_tab/current_trips/current_trips_page.dart';
import 'my_trips_tab/past_trips/past_trip_page.dart';
import 'my_trips_tab/private_trips/private_trip_page.dart';
import 'notifications/notification_page.dart';


/// Main screen
class MainTabPage extends StatefulWidget {

  final List<NotificationData>? notifications;

  MainTabPage({Key? key, this.notifications}) :  super(key: key);


  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();

}
class _MyStatefulWidgetState extends State<MainTabPage> {

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      RemoteNotification message =  event.notification!;
      String tripDocID = event.data['docID'] ?? '';
      if (tripDocID.isNotEmpty) {
        CloudFunction().addNewNotification(type: 'Chat',message: message.title!,documentID: tripDocID,ownerID: userService.currentUserID);
      }
      Fluttertoast.showToast(
              msg: message.title!,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
            );
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) async {
      // RemoteNotification message =  event.notification;
      String tripDocID = event.data['docID'] ?? '';
      if(tripDocID.isNotEmpty){
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
    // FirebaseCrashlytics.instance.crash();
    setState(() {
      _selectedIndex = index;
    });
  }
  

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          drawer: MenuDrawer(),
          body: (_selectedIndex == 0) ? Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const CustomAppBar(bottomNav: true,),
                      Padding(
                        padding: EdgeInsets.only(
                            top: SizeConfig.screenHeight*.18),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: TabBar(
                            labelStyle: responsiveTextStyleTopicsSub(context),
                            isScrollable: true,
                            tabs: <Widget> [
                              Tab(text: Intl.message('Current'),),
                              Tab(text: Intl.message('Past'),),
                              Tab(text: Intl.message('Private'),),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: SizeConfig.screenHeight/2*.45),
                        child: _widgetOptions.elementAt(_selectedIndex),
                      ),
                    ],
                  ):
                  Stack(
                    children: [
                      const CustomAppBar(bottomNav: false,),
                      Padding(
                        padding: EdgeInsets.only(
                            top: SizeConfig.screenHeight*.1785),
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
              const IconThemeWidget(icon:Icons.list_rounded),
              const IconThemeWidget(icon:Icons.search),
              const IconThemeWidget(icon: Icons.add_outlined,),
              const IconThemeWidget(icon:Icons.favorite_border),
              BadgeIcon(
                icon: const IconThemeWidget(icon:Icons.notifications_active),
                badgeCount: widget.notifications != null ?
                widget.notifications!.length : 0,
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

