import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_basic_layout.dart';
import 'package:travelcrew/services/auth.dart';

class ExploreBasic extends StatelessWidget {

  final AuthService _auth = AuthService();
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
            leading: PopupMenuButton<String>(
              onSelected: (value){
                if (value == 'signout'){
                  _auth.logOut();
                  print(value);
                }else{
                  print(value);
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
                  value: 'signout',
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Signout'),
                  ),
                ),
              ],
            ),
            title: Text('${trip.location}'.toUpperCase()),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),

            ],
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                for (final tab in tabs) Tab(text: tab),
              ],
            ),
          ),
          body: ExploreBasicLayout(tripdetails: trip,),
      ),
    );
  }
}