import 'package:flutter/material.dart';
import 'package:travelcrew/screens/add_trip/add_trip.dart';
import 'package:travelcrew/screens/app_bar/main_menu.dart';

class TravelCrewAppBar extends StatelessWidget with PreferredSizeWidget{

  final bool bottomTabBar;
  TravelCrewAppBar({this.bottomTabBar});

  @override
  Widget build(BuildContext context) {

    return AppBar(
      centerTitle: true,
      leading: MainMenuButtons(),
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
      bottom: bottomTabBar ? TabBar(
        labelStyle: Theme.of(context).textTheme.subtitle1,
        isScrollable: true,
        tabs: [
          Tab(text: 'Current',),
          Tab(text: 'Past',),
          Tab(text: 'Private',),
        ],
      ): null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(75);
}