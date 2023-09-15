import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_costs/ui/split_item_list_screen.dart';

import '../../blocs/generics/generic_bloc.dart';
import '../../models/notification_model/notification_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/trip_repositories/current_trip_repository.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../size_config/size_config.dart';
import '../Main_Page/app_bar.dart';
import '../Menu/main_menu.dart';
import '../Trips/current_trips_page.dart';
import 'home_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    // const FeedScreen(),
    const HomeScreen(),
    const SplitItemListScreen(),
    BlocProvider<GenericBloc<Trip, CurrentTripRepository>>(
      create: (BuildContext context) =>
          GenericBloc<Trip, CurrentTripRepository>(
              repository: CurrentTripRepository()),
      child: const CurrentTrips(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(),
      body: Stack(
        children: <Widget>[
          BlocProvider<GenericBloc<NotificationModel, NotificationRepository>>(
            create: (BuildContext context) =>
                GenericBloc<NotificationModel, NotificationRepository>(
                    repository: NotificationRepository()),
            child: const CustomAppBar(bottomNav: false),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: SizeConfig.screenHeight * (.1785),
            ),
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
          IconThemeWidget(icon: Icons.monetization_on),
          IconThemeWidget(icon: Icons.people),
        ],
        onTap: _onItemTapped,
        index: _selectedIndex,
      ),
    );
  }
}
