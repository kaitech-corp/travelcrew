import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/loading.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/add_trip/add_trip.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_basic.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/size_config/size_config.dart';
import 'dart:math' as math;

import 'ad_card_layout.dart';

var userService = locator<UserService>();

bool animatePress = false;

class AllTripsNewDesign extends StatefulWidget{

  
  @override
  _AllTripsNewDesignState createState() => _AllTripsNewDesignState();
}

class _AllTripsNewDesignState extends State<AllTripsNewDesign> with SingleTickerProviderStateMixin{

  bool pressed = true;
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    animatePress = false;
    _animationController = AnimationController(duration: Duration(milliseconds: 750), vsync: this);
    _animation = IntTween(begin: 4, end: 32).animate(_animationController);
    _animation.addListener(() => setState(() {
      if(_animation.isCompleted){
        animatePress = !animatePress;
      }
    }));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: const DecorationImage(
            image: const AssetImage('assets/images/space3.jpg'),
            fit: BoxFit.fitHeight,
          ),
        ),
        height: SizeConfig.screenHeight,
        child: Column(
          children: [
            Flexible(
              flex: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                            style: Theme.of(context).textTheme.headline3,
                            children: [
                              TextSpan(text: pressed ? 'Coming' : "What's",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 28)),
                              TextSpan(text: pressed ? ' Up' : " New",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
                            ]
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.filter_list_sharp,color: Colors.white,),
                          iconSize: 30,
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
              flex: _animation.value,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                              style: Theme.of(context).textTheme.headline3,
                              children: [
                                TextSpan(text: 'Social',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                TextSpan(text: " Distancing",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent,fontSize: 28))
                              ]
                          ),
                        ),
                        IconButton(
                            icon: animatePress ? Transform.rotate(
                              angle: 180 * math.pi / 180,
                              child: IconButton(
                                  icon: Icon(
                                    Icons.filter_list_sharp,
                                    color: Colors.white,
                                  ),
                                  onPressed: (){
                                    if (_animationController.value == 0.0) {
                                      _animationController.forward();
                                    } else {
                                      _animationController.reverse();
                                      setState(() {
                                        animatePress = !animatePress;
                                      });
                                    }
                                  }),
                            ) :  Icon(Icons.filter_list_sharp,color: Colors.white,),
                            iconSize: 30,
                            onPressed: (){
                              if (_animationController.value == 0.0) {
                                _animationController.forward();
                              } else {
                                _animationController.reverse();
                                setState(() {
                                  animatePress = !animatePress;
                                });
                              }
                            }),
                      ],
                    ),
                    Expanded(
                      child: AdTileCard(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class SliverGridList extends StatefulWidget {

  final bool pressed;

  SliverGridList({this.pressed});

  @override
  _SliverGridListState createState() => _SliverGridListState();
}

class _SliverGridListState extends State<SliverGridList> {
  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  @override
  Widget build(BuildContext context) {

    final trips = Provider.of<List<Trip>>(context);
    List<Trip> trips2 = List();
    List<Trip> trips4 = List();

    if (trips != null) {
      var trips3 = trips.where((trip) =>
      !trip.accessUsers.contains(userService.currentUserID));
      if(widget.pressed) {

        trips3.forEach((f) => trips2.add(f));
        trips4 = trips3.where((trip) =>
            trip.startDateTimeStamp.toDate().isAfter(DateTime.now())).toList();
        try {
          trips4 = trips4.where((trip) =>
          !currentUserProfile.blockedList.contains(trip.ownerID)).toList();
        } catch (e){
          // print(e.toString());
        }
      }
      else{
        trips3.forEach((f) => trips2.add(f));
        trips2.sort((a,b) => b.dateCreatedTimeStamp.compareTo(a.dateCreatedTimeStamp));
        trips4 = trips2.where((trip) =>
            trip.endDateTimeStamp.toDate().isAfter(DateTime.now())).toList();
        try {
          trips4 = trips4.where((trip) =>
          !currentUserProfile.blockedList.contains(trip.ownerID)).toList();
        } catch (e){
          // print(e.toString());
        }
      }
    }
    return Flexible(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
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

  favorite(String uid, Trip trip){
    if (trip.favorite.contains(uid)){

      return Icon(Icons.favorite, color: Colors.white,);
    } else {
      return Icon(Icons.favorite_border, color: Colors.white,);
    }
  }

  return InkWell(
    key: Key(trip.documentId),
    splashColor: Colors.blue.withAlpha(30),

    child: Container (
      margin: const EdgeInsets.only(left: 25, bottom: 20, top: 10),
      decoration: BoxDecoration(
          color: const Color(0xAA2D3D49),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Flexible(
            flex: 4,
            child: ListTile(
              title: Text((trip.location != '' ? trip.location : 'Trip Name'),style: TextStyle(fontFamily:'RockSalt', fontSize: 18, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis,),
              subtitle: Text("${trip.travelType}",
                textAlign: TextAlign.start,style: Theme.of(context).textTheme.headline5, maxLines: 1, overflow: TextOverflow.ellipsis,),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExploreBasic(trip: trip,)),
                );
              },
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 5)),
          Flexible(
            flex: 2,
              child: ListTile(
                title: Text('${trip.startDate}',style: Theme.of(context).textTheme.headline5,),
                subtitle: Text('${trip.displayName}',style: Theme.of(context).textTheme.headline5, maxLines: 1, overflow: TextOverflow.ellipsis,),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExploreBasic(trip: trip,)),
                  );
                },
              ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: FlatButton(
                child: favorite(userService.currentUserID, trip),
                onPressed: () {
                  if (trip.favorite.contains(userService.currentUserID)){
                    CloudFunction().removeFavoriteFromTrip(trip.documentId);
                  } else {
                    CloudFunction().addFavoriteTrip(trip.documentId);
                  }
                },
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 10)),
        ],
      ),
    ),
  );
}