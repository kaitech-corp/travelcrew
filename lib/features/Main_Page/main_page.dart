import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/generics/generic_bloc.dart';

import '../../models/trip_model/trip_model.dart';
import '../../repositories/trip_repositories/current_trip_repository.dart';
import '../../repositories/trip_repositories/past_trip_repository.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../size_config/size_config.dart';

import '../Main_Page/app_bar.dart';
import '../Menu/main_menu.dart';

import '../Feed/feed_screen.dart';
import '../Trips/current_trips_page.dart';
import '../Trips/past_trip_page.dart';
import 'home_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const FeedScreen(),
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const MenuDrawer(),
        body: Stack(
          children: <Widget>[
            CustomAppBar(bottomNav: _selectedIndex == 2),
            Padding(
              padding: EdgeInsets.only(
                top: SizeConfig.screenHeight *
                    (_selectedIndex == 2 ? .18 : .1785),
              ),
              child: Center(
                child: _selectedIndex == 2
                    ? Column(
                        children: <Widget>[
                          TabBar(
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
                          Expanded(
                            child: _widgetOptions[2],
                            
                          ),
                        ],
                      )
                    : _widgetOptions.elementAt(_selectedIndex),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: ReusableThemeColor().bottomNavColor(context),
          color: ReusableThemeColor().color(context),
          items: const <Widget>[
            IconThemeWidget(icon: Icons.home),
            IconThemeWidget(icon: Icons.feed),
            IconThemeWidget(icon: Icons.people),
          ],
          onTap: _onItemTapped,
          index: _selectedIndex,
        ),
      ),
    );
  }
}
