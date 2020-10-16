import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_basic_layout.dart';

class ExploreBasic extends StatelessWidget {

  final Trip trip;
  ExploreBasic({this.trip});

  @override
  Widget build(BuildContext context) {
    List<String> tabs = [
      'Explore',
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: MainMenuButtons(),
            title: Text('${trip.location}'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),

            ],
            bottom: TabBar(
              labelStyle: Theme.of(context).textTheme.subtitle1,
              isScrollable: true,
              tabs: [
                for (final tab in tabs) Tab(text: tab),
              ],
            ),
          ),
          body: ExploreBasicLayout(tripDetails: trip,),
      ),
    );
  }
}