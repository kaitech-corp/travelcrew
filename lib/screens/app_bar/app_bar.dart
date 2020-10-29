import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/add_trip/add_trip.dart';
import 'package:travelcrew/services/database.dart';

class TravelCrewAppBar extends StatelessWidget with PreferredSizeWidget{

  final bool bottomTabBar;

  TravelCrewAppBar({this.bottomTabBar});

  @override
  Widget build(BuildContext context) {

    return AppBar(
      centerTitle: true,
      // leading: MainMenuButtons(),
      title: Text('Travel Crew',style: Theme.of(context).textTheme.headline3,),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: (){
            Navigator.pushNamed(context, '/addTrip');

          },
        ),
      ],
      bottom: bottomTabBar ? TabBar(
        labelStyle: Theme.of(context).textTheme.subtitle1,
        isScrollable: true,
        tabs: [
          const Tab(text: 'Current',),
          const Tab(text: 'Private',),
          const Tab(text: 'Past',),
        ],
      ): null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(75);
}