import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_basic.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';


class AllTripsNewDesign extends StatefulWidget{


  @override
  _AllTripsNewDesignState createState() => _AllTripsNewDesignState();
}

class _AllTripsNewDesignState extends State<AllTripsNewDesign> {

  bool pressed = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                          style: Theme.of(context).textTheme.headline6,
                          children: [
                            TextSpan(text: 'Social Distancing', style: TextStyle(fontSize: 18)),
                            TextSpan(text: " Suggestions",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent))
                          ]
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
                            TileCard(country: 'Nature Park', text: 'Bike Ride',),
                            TileCard(country: 'Hiking Trails',text: 'Hike',),
                            TileCard(country: 'Riverbed',text: 'Rent a Canoe',),
                            TileCard(country: 'Park', text: 'Have a picnic',)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                            style: Theme.of(context).textTheme.headline6,
                            children: [
                              TextSpan(text: pressed ? 'Coming' : "What's",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
                              TextSpan(text: pressed ? ' Up' : " New", style: TextStyle(fontSize: 18)),
                            ]
                        ),
                      ),
                      IconButton(icon: Icon(Icons.swap_horiz),
                          onPressed: (){
                            setState(() {
                              pressed = !pressed;
                            });
                          }),
                    ],
                  ),
                  SliverGridList(pressed: pressed,),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                        style: Theme.of(context).textTheme.headline5,
                        children: [
                          TextSpan(text: 'Popular', style: TextStyle(fontSize: 20)),
                          TextSpan(text: " Destinations",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent))
                        ]
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          TileCard(country: 'Spain', text: 'Dance Flamenco in Granada',),
                          TileCard(country: 'Hawaii',text: 'Snorkel in Waikiki',),
                          TileCard(country: 'Brazil',text: 'Visit Cristo!',),
                          TileCard(country: 'Monaco', text: 'Grand Prix',)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
class TileCard extends StatelessWidget {
  final String country;
  final String text;

  const TileCard({Key key, this.country, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 25, bottom: 20, top: 10),
      height: 75,
      width: 200,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            offset: Offset(0, 10),
            blurRadius: 33,
            color: Color(0xFFD3D3D3).withOpacity(.84),
            spreadRadius: 5,
          )
          ]),
      child: ListTile(
        title: Text(country),
        subtitle: Text(text),
      ),
    );
  }
}

class SliverGridList extends StatelessWidget {
  final bool pressed;

  SliverGridList({this.pressed});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);
    final trips = Provider.of<List<Trip>>(context);
    List<Trip> trips2 = List();
    List<Trip> trips4 = List();

    if (trips != null) {
      if(pressed) {
        var trips3 = trips.where((trip) =>
        !trip.accessUsers.contains(user.uid));
        trips3.forEach((f) => trips2.add(f));
        trips4 = trips3.where((trip) =>
            trip.endDateTimeStamp.toDate().isAfter(DateTime.now())).toList();
      }
      else{
        var trips3 = trips.where((trip) =>
        !trip.accessUsers.contains(user.uid));
        trips3 = trips3.where((trip) => trip.dateCreatedTimeStamp != null);
        trips3.forEach((f) => trips2.add(f));
        trips2.sort((a,b) => b.dateCreatedTimeStamp.compareTo(a.dateCreatedTimeStamp));
        trips4 = trips2.where((trip) =>
            trip.endDateTimeStamp.toDate().isAfter(DateTime.now())).toList();
      }
    }
    return Flexible(
      flex: 1,
      child: Container(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        height: MediaQuery.of(context).size.height * .6,
        // width: MediaQuery.of(context).size.width,
        child: CustomScrollView(
            slivers: <Widget>[
              SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                  ),
                  delegate: SliverChildBuilderDelegate((BuildContext context, int index){
                    return TripCard3(context, trips4[index]);
                  },
                    childCount: trips4.length,
                  )
              )]),
      ),
    );
  }
}
Widget TripCard3(BuildContext context, Trip trip) {
  final user = Provider.of<UserProfile>(context);

  favorite(String uid, Trip trip){
    if (trip.favorite.contains(uid)){

      return Icon(Icons.favorite);
    } else {
      return Icon(Icons.favorite_border);
    }
  }

  return InkWell(
    splashColor: Colors.blue.withAlpha(30),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ExploreBasic(trip: trip,)),
      );

    },
    child: Container (
      margin: EdgeInsets.only(left: 25, bottom: 20, top: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          boxShadow: [BoxShadow(
            offset: Offset(0, 10),
            blurRadius: 33,
            color: Color(Colors.blueGrey.value).withOpacity(.84),
            spreadRadius: 5,
          )
          ]),
      child: Stack(
          children: <Widget>[
            ListTile(
              title: Text((trip.location != '' ? trip.location : 'Trip Name'), textScaleFactor: 1,),
              subtitle: Text("${trip.travelType}",
                textAlign: TextAlign.start,),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                  height: 50,
                  child: Text('${trip.startDate}')),
            ),
            Positioned(
              bottom: 0,
              left: 20,
              child: Container(
                height: 50,
                  child: Text('${trip.displayName}')),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: ButtonBar(
                  children: <Widget>[ FlatButton(
                    child: favorite(user.uid, trip),
                    onPressed: () {
                      if (trip.favorite.contains(user.uid)){
                        try {
                          CloudFunction().removeFavoriteFromTrip(trip.documentId, user.uid);
                          // DatabaseService(tripDocID: trip.documentId).removeFavoriteFromTrip(user.uid);
                        } catch (e) {
                          print('Error removing favorite. ${e.toString()}');
                        }
                      } else {
                        try {
                          // CloudFunction().addFavoriteToTrip(trip.documentId, user.uid);
                          DatabaseService(tripDocID: trip.documentId)
                              .addFavoriteToTrip(user.uid);
                        } catch (e) {
                          print('Error adding favorite. ${e.toString()}');
                        }
                      }
                      },
                  ),
                  ]),
            ),
          ]
      ),
    ),
  );
}