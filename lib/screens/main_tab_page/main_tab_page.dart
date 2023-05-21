// ignore_for_file: always_specify_types

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../blocs/generics/generic_bloc.dart';
import '../../models/trip_model.dart';
import '../../repositories/trip_repositories/all_trip_repository.dart';
import '../../repositories/trip_repositories/current_trip_repository.dart';
import '../../repositories/trip_repositories/past_trip_repository.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../size_config/size_config.dart';
import '../add_trip/add_trip_page.dart';
import '../app_bar/app_bar.dart';
import '../menu_screens/main_menu.dart';
import 'all_trips/all_trips_page.dart';
import 'my_trips_tab/current_trips/current_trips_page.dart';
import 'my_trips_tab/past_trips/past_trip_page.dart';


/// Main screen
class MainTabPage extends StatefulWidget {
  const MainTabPage({Key? key}) : super(key: key);

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  @override
  void initState() {
    // LocationHandler().getLocationData();
    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      final RemoteNotification message = event.notification!;
      final String tripDocID = event.data['docID'] as String;
      if (tripDocID.isNotEmpty) {
        CloudFunction().addNewNotification(
            type: 'Chat',
            message: message.title!,
            documentID: tripDocID,
            ownerID: userService.currentUserID);
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
      final String tripDocID = event.data['docID'] as String;
      if (tripDocID.isNotEmpty) {
        final Trip trip = await DatabaseService().getTrip(tripDocID);
        try {
          navigationService.navigateTo(ExploreRoute, arguments: trip);
        } catch (e) {
          CloudFunction().logError('onMessageOpenedApp- Not a valid trip:  $e');
        }
      } else {
        navigationService.navigateTo(DMChatListPageRoute);
      }
    });
    super.initState();
  }

  

  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    BlocProvider(
      create: (BuildContext context) => GenericBloc<Trip, AllTripsRepository>(
          repository: AllTripsRepository()),
      child: const AllTrips(),
    ),
    const AddTripPage(),
    TabBarView(
      children: <Widget>[
        BlocProvider(
          create: (BuildContext context) =>
              GenericBloc<Trip, CurrentTripRepository>(
                  repository: CurrentTripRepository()),
          child: const CurrentTrips(),
        ),
        BlocProvider(
          create: (BuildContext context) =>
              GenericBloc<Trip, PastTripRepository>(
                  repository: PastTripRepository()),
          child: const PastTrips(),
        ),
      ],
    ),
  ];

  void _onItemTapped(int index) {
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
        length: 2,
        child: Scaffold(
          drawer: const MenuDrawer(),
          body: (_selectedIndex == 2)
              ? Column(
                  children: <Widget>[
                    Stack(
                      children: [
                        const CustomAppBar(
                          bottomNav: true,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: SizeConfig.screenHeight * .18),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: TabBar(
                              labelStyle: responsiveTextStyleTopicsSub(context),
                              isScrollable: true,
                              tabs: <Widget>[
                                Tab(
                                  text: Intl.message('Current'),
                                ),
                                Tab(
                                  text: Intl.message('Past'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
                  ],
                )
              : Stack(
                  children: <Widget>[
                    const CustomAppBar(
                      bottomNav: false,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: SizeConfig.screenHeight * .1785),
                      child: Center(
                        child: _widgetOptions.elementAt(_selectedIndex),
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: CurvedNavigationBar(
            backgroundColor: ReusableThemeColor().bottomNavColor(context),
            color: ReusableThemeColor().color(context),
            items: const <Widget>[
              IconThemeWidget(icon: Icons.home),
              IconThemeWidget(
                icon: Icons.add_outlined,
              ),
              IconThemeWidget(icon: Icons.people),
            ],
            onTap: _onItemTapped,
            index: _selectedIndex,
          ),
        ),
      ),
    );
  }
}
