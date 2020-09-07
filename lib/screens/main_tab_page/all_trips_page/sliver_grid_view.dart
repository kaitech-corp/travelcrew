import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_basic.dart';
import 'package:travelcrew/services/database.dart';

import 'dart:math' as math;

class SliverGridTripCard extends StatelessWidget {
//
  final List<Trip> trip;
  SliverGridTripCard({this.trip});
//
  final ScrollController controller = ScrollController();
  final _month = DateTime.now().month - 1;
  SliverPersistentHeader makeHeader(String headerText) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 30.0,
        maxHeight: 40.0,
        child: Container(
            color: Colors.lightBlue,
            child: Center(child: Text(headerText))),
      ),
    );
  }
  dynamic returnMonth(int x){
    if(x>11){
      x = x-12;
    }
    List<Trip> januaryTrips = trip.where((item) => item.startDate.contains('Jan')).toList();
    List<Trip> febuaryTrips = trip.where((item) => item.startDate.contains('Feb')).toList();
    List<Trip> marchTrips = trip.where((item) => item.startDate.contains('Mar')).toList();
    List<Trip> aprilTrips = trip.where((item) => item.startDate.contains('Apr')).toList();
    List<Trip> mayTrips = trip.where((item) => item.startDate.contains('May')).toList();
    List<Trip> juneTrips = trip.where((item) => item.startDate.contains('Jun')).toList();
    List<Trip> julyTrips = trip.where((item) => item.startDate.contains('Jul')).toList();
    List<Trip> augustTrips = trip.where((item) => item.startDate.contains('Aug')).toList();
    List<Trip> septemberTrips = trip.where((item) => item.startDate.contains('Sep')).toList();
    List<Trip> octoberTrips = trip.where((item) => item.startDate.contains('Oct')).toList();
    List<Trip> novemberTrips = trip.where((item) => item.startDate.contains('Nov')).toList();
    List<Trip> decemberTrips = trip.where((item) => item.startDate.contains('Dec')).toList();
    Map<String, dynamic> year = ({
      'January': januaryTrips,
      'Febuary': febuaryTrips,
      'March': marchTrips,
      'April': aprilTrips,
      'May': mayTrips,
      'June': juneTrips,
      'July': julyTrips,
      'August': augustTrips,
      'September': septemberTrips,
      'October': octoberTrips,
      'November': novemberTrips,
      'December': decemberTrips,
    });

  return [year.keys.toList()[x], year.values.toList()[x]];
  }
  @override
  Widget build(BuildContext context) {
    Widget _buildList(){
      return ListView.builder(
          itemCount: trip.length,
          itemBuilder: (context, index){
            return TripCard(context, trip[index]);
          });
    }


    return CustomScrollView(
      slivers: <Widget>[
        makeHeader(returnMonth(_month)[0]),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index){
            return TripCard(context, returnMonth(_month)[1][index]);
          },
              childCount: returnMonth(_month)[1].length),
        ),

        makeHeader(returnMonth(_month + 1)[0]),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index){
            return TripCard(context, returnMonth(_month + 1)[1][index]);
          },
              childCount: returnMonth(_month + 1)[1].length),
        ),

        makeHeader(returnMonth(_month + 2)[0]),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index){
            return TripCard(context, returnMonth(_month + 2)[1][index]);
          },
              childCount: returnMonth(_month + 2)[1].length),
        ),

        makeHeader(returnMonth(_month + 3)[0]),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index){
            return TripCard(context, returnMonth(_month + 3)[1][index]);
          },
              childCount: returnMonth(_month + 3)[1].length),
        ),

        makeHeader(returnMonth(_month + 4)[0]),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index){
            return TripCard(context, returnMonth(_month + 4)[1][index]);
          },
              childCount: returnMonth(_month + 4)[1].length),
        ),

        makeHeader(returnMonth(_month + 5)[0]),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index){
            return TripCard(context, returnMonth(_month + 5)[1][index]);
          },
              childCount: returnMonth(_month + 5)[1].length),
        ),

        makeHeader(returnMonth(_month + 6)[0]),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index){
            return TripCard(context, returnMonth(_month + 6)[1][index]);
          },
              childCount: returnMonth(_month + 6)[1].length),
        ),

        makeHeader(returnMonth(_month + 7)[0]),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index){
            return TripCard(context, returnMonth(_month + 7)[1][index]);
          },
              childCount: returnMonth(_month + 7)[1].length),
        ),

        makeHeader(returnMonth(_month + 8)[0]),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index){
            return TripCard(context, returnMonth(_month + 8)[1][index]);
          },
              childCount: returnMonth(_month + 8)[1].length),
        ),

        makeHeader(returnMonth(_month + 9)[0]),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index){
            return TripCard(context, returnMonth(_month + 9)[1][index]);
          },
              childCount: returnMonth(_month + 9)[1].length),
        ),

        makeHeader(returnMonth(_month + 10)[0]),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index){
            return TripCard(context, returnMonth(_month + 10)[1][index]);
          },
              childCount: returnMonth(_month + 10)[1].length),
        ),

        makeHeader(returnMonth(_month + 11)[0]),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index){
            return TripCard(context, returnMonth(_month + 11)[1][index]);
          },
          childCount: returnMonth(_month + 11)[1].length),
        ),
      ],
    );
  }

}


  Widget TripCard(BuildContext context, Trip trip) {
    final user = Provider.of<UserProfile>(context);

    favorite(String uid, Trip trip){
      if (trip.favorite.contains(uid)){

        return Icon(Icons.favorite);
      } else {
        return Icon(Icons.favorite_border);
      }
    }
    ownerName(String uid, Trip trip){
      if (trip.ownerID == uid){
        return 'You';
      }else {
        return trip.displayName;
      }
    }

    return Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExploreBasic(trip: trip,)),
          );
        },
        child: Container(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              ListTile(
                  title: Text((trip.location != '' ? trip.location : 'Trip Name'), textScaleFactor: 1,),
                  subtitle: Text("Travel Type: ${trip.travelType}",
                    textAlign: TextAlign.start,),
              ),
//                Text('Owner: ${trip.displayName}'),
                ButtonBar(
                  children: <Widget>[ FlatButton(
                    child: favorite(user.uid, trip),
                    onPressed: () {
                      if (trip.favorite.contains(user.uid)){
                        try {
                          DatabaseService(tripDocID: trip.documentId).removeFavoriteFromTrip(user.uid);
                        } catch (e) {
                          print('Error removing favorite. ${e.toString()}');
                        }
                      } else {
                        try {
                          DatabaseService(tripDocID: trip.documentId)
                              .addFavoriteToTrip(user.uid);
                        } catch (e) {
                          print('Error adding favorite. ${e.toString()}');
                        }
                      }
                      /* ... */ },
                  ),
                ]),
              ]
          ),
        ),
      ),
    );
  }



class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent)
  {
    return new SizedBox.expand(child: child);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
