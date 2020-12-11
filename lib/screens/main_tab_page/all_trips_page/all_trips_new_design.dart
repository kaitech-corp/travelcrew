import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_basic.dart';
import 'package:travelcrew/services/analytics_service.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/tc_functions.dart';
import 'package:travelcrew/size_config/size_config.dart';

var userService = locator<UserService>();

bool animatePress = false;


class AllTripsNewDesign extends StatefulWidget{


  @override
  _AllTripsNewDesignState createState() => _AllTripsNewDesignState();
}
final AnalyticsService _analyticsService = AnalyticsService();

class _AllTripsNewDesignState extends State<AllTripsNewDesign> with SingleTickerProviderStateMixin,
AutomaticKeepAliveClientMixin<AllTripsNewDesign>{

  bool pressed = false;
  AnimationController _animationController;
  Animation _animation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    animatePress = false;
    _animationController = AnimationController(duration: Duration(milliseconds: 750), vsync: this);
    _animation = IntTween(begin: 4, end: 28).animate(_animationController);
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
        height: SizeConfig.screenHeight,
        margin: EdgeInsets.only(left:8.0, right: 8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      style: Theme.of(context).textTheme.headline3,
                      children: [
                        TextSpan(text: pressed ? 'Coming' : "What's",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 28)),
                        TextSpan(text: pressed ? ' Up' : " New",style: Theme.of(context).textTheme.headline4,),
                      ]
                  ),
                ),
                Row(
                  children: [
                    Container(
                        height: SizeConfig.screenWidth*.025,
                        width: SizeConfig.screenWidth*.025,
                        child: Image.asset(starImage)),
                    Text('Suggestion',style: Theme.of(context).textTheme.headline6,)
                  ],
                )
                // IconButton(
                //     icon: IconThemeWidget(icon: Icons.filter_list_sharp,),
                //     iconSize: 30,
                //     onPressed: (){
                //       setState(() {
                //         pressed = !pressed;
                //       });
                //     }),
              ],
            ),
            SliverGridList(pressed: pressed,),
            // Flexible(
            //   flex: _animation.value,
            //   child: Container(
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             RichText(
            //               text: TextSpan(
            //                   style: Theme.of(context).textTheme.headline3,
            //                   children: [
            //                     TextSpan(text: 'Social',style: Theme.of(context).textTheme.headline4,),
            //                     const TextSpan(text: " Distancing",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent,fontSize: 28))
            //                   ]
            //               ),
            //             ),
            //             IconButton(
            //                 icon: animatePress ? Transform.rotate(
            //                   angle: 180 * math.pi / 180,
            //                   child: IconButton(
            //                       icon: IconThemeWidget(icon: Icons.filter_list_sharp,),
            //                       onPressed: (){
            //                         if (_animationController.value == 0.0) {
            //                           _animationController.forward();
            //                         } else {
            //                           _animationController.reverse();
            //                           setState(() {
            //                             animatePress = !animatePress;
            //                           });
            //                         }
            //                       }),
            //                 ) :  IconThemeWidget(icon: Icons.filter_list_sharp,),
            //                 iconSize: 30,
            //                 onPressed: (){
            //                   if (_animationController.value == 0.0) {
            //                     _animationController.forward();
            //                   } else {
            //                     _animationController.reverse();
            //                     setState(() {
            //                       animatePress = !animatePress;
            //                     });
            //                   }
            //                 }),
            //           ],
            //         ),
            //         Expanded(
            //           child: AdTileCard(),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}


class SliverGridList extends StatefulWidget {

  final bool pressed;

  var tripPopUp;

  bool _showCard = false;

  SliverGridList({this.pressed});

  @override
  _SliverGridListState createState() => _SliverGridListState();
}

class _SliverGridListState extends State<SliverGridList> {

  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();


  @override
  Widget build(BuildContext context) {

    final trips = Provider.of<List<Trip>>(context);
    final tripAds = Provider.of<List<TripAds>>(context);
    List<Trip> trips2 = List();
    List<Trip> trips4 = List();
    List<int> thirdItemList = List();
    List<dynamic> combinedList = List();

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
          for (var i = 0; i < trips4.length; i++) {
            if(i%3==0 && i !=0){
              thirdItemList.add(i);
            }
          }
          combinedList.addAll(trips4);
          for (var i = 0; i < thirdItemList.length; i++){
            combinedList.insert(thirdItemList[i], tripAds[i]);
          }
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
          for (var i = 0; i < trips4.length; i++) {
            if(i%3==0 && i !=0){
              thirdItemList.add(i);
            }
          }
          combinedList.addAll(trips4);
          for (var i = 0; i < thirdItemList.length; i++){
            combinedList.insert(thirdItemList[i], tripAds[i]);
          }
        } catch (e){
          // print(e.toString());
        }
      }
    }


    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        // height: SizeConfig.screenHeight,
        // width: SizeConfig.screenWidth,
        child: CustomScrollView(
          slivers: [
            SliverStaggeredGrid.countBuilder(
              crossAxisCount: 3,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
              itemCount: combinedList.length,
              itemBuilder: (context, index){
                // return trips4[index].urlToImage.isEmpty ? TripCard3(context, trips4[index]) : TripCard4(context, trips4[index]);
                return combinedList[index] is Trip ? (combinedList[index].urlToImage.isEmpty ? CardWithoutImage(context, combinedList[index]) : CardWithImage(context, combinedList[index]) ): AdCard(context,combinedList[index]);
              },
              staggeredTileBuilder: (index){
                if(combinedList[index] is Trip){
                  if(combinedList[index].urlToImage.isNotEmpty){
                    return StaggeredTile.count(3, 3);
                  } else {
                    return StaggeredTile.count(3, 1);
                  }
                } else{
                  return StaggeredTile.count(3,3);
                }
              },
            )
                    // staggeredTileBuilder: (index) {
                    //   if(trips4[index].urlToImage.isNotEmpty){
                    //     return StaggeredTile.count(3, 3);
                    //   } else{
                    //     return StaggeredTile.count(3, 1);
                    //   }
                    // }),
              ],
            ),
      ),
    );


    // return Flexible(
    //   flex: 1,
    //   child: Container(
    //     padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
    //     height: MediaQuery.of(context).size.height * .6,
    //     // width: MediaQuery.of(context).size.width,
    //     child: Stack(
    //       children: [
    //         CustomScrollView(
    //             slivers: <Widget>[
    //               // SliverGrid(
    //               //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //               //         crossAxisCount: 2,
    //               //     ),
    //               //     delegate: SliverChildBuilderDelegate((BuildContext context, int index){
    //               //       return trips4[index].urlToImage.isEmpty ? TripCard3(context, trips4[index]) : TripCard4(context, trips4[index]);
    //               //     },
    //               //       childCount: trips4.length,
    //               //     )
    //               // ),
    //
    //             ]),
    //         if (widget._showCard) ...[
    //           BackdropFilter(
    //             filter: ImageFilter.blur(
    //               sigmaX: 5.0,
    //               sigmaY: 5.0,
    //             ),
    //             child: Container(
    //               color: Colors.white.withOpacity(0.6),
    //             ),
    //           ),
    //           Center(
    //               child: TappableTripPreview(trip: widget.tripPopUp,)
    //           ),
    //         ],
    //       ],
    //     ),
    //   ),
    // );
  }
  Widget AdCard(BuildContext context, TripAds tripAds){
    return InkWell(
      key: Key(tripAds.documentID),
      splashColor: Colors.blue.withAlpha(30),

      child: GestureDetector(
        onTap: () {
          TCFunctions().launchURL(tripAds.link);
          CloudFunction().updateClicks(tripAds.documentID);
        },
        child: Stack(
          children: [
            Container (
              margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(tripAds.urlToImage,),
                  fit: BoxFit.fill,
                ),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                  height: SizeConfig.screenWidth*.1,
                  width: SizeConfig.screenWidth*.1,
                  color: Colors.transparent,
                  child: Image.asset(starImage)),
            ),
          ],
        ),
      ),
    );
  }

  Widget CardWithImage(BuildContext context, Trip trip) {


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

      child: GestureDetector(
        onTap: () {
          _analyticsService.viewedTrip();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExploreBasic(trip: trip,)),
          );
        },
        onLongPress: (){
          setState(() {
            widget._showCard = true;
            widget.tripPopUp = trip;
          });
        },
        onLongPressEnd: (details) {
          setState(() {
            widget._showCard = false;
          });
        },
        child: Hero(
          tag: trip.urlToImage,
          transitionOnUserGestures: true,
          child: Container (
            margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 10),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(trip.urlToImage,),
                fit: BoxFit.fill,
              ),
              color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Color(0xAA91AFD0) : Color(0xAA2D3D49), //
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
            ),
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
        ),
      ),
    );
  }
}
Widget CardWithoutImage(BuildContext context, Trip trip) {

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
      margin: const EdgeInsets.only(left: 15,right: 15, bottom: 20, top: 10),
      decoration: (ThemeProvider.themeOf(context).id == 'light_theme') ?
      BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue,
              Colors.lightBlueAccent
            ]
        ),
      ):
      BoxDecoration(
          color: Color(0xAA2D3D49),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Flexible(
            flex: 4,
            child: Tooltip(
              message: '${trip.tripName}',
              child: ListTile(
                title: Text((trip.tripName),style: TextStyle(fontFamily:'RockSalt', fontSize: 18, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis,),
                subtitle: Text("${trip.travelType}",
                  textAlign: TextAlign.start,style: Theme.of(context).textTheme.headline5, maxLines: 1, overflow: TextOverflow.ellipsis,),
                trailing: Text('${TCFunctions().dateToMonthDay(trip.startDate)} - ${trip.endDate}',style: Theme.of(context).textTheme.headline5,),
                onTap: () {
                  _analyticsService.viewedTrip();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExploreBasic(trip: trip,)),
                  );
                },
              ),
            ),
          ),
          // Padding(padding: EdgeInsets.only(top: 3)),
          Flexible(
            flex: 2,
              child: ListTile(
                // title: Text('${trip.startDate}',style: Theme.of(context).textTheme.headline5,),
                title: Text('${trip.displayName}',style: Theme.of(context).textTheme.headline5, maxLines: 1, overflow: TextOverflow.ellipsis,),
                // trailing: FlatButton(
                //   child: favorite(userService.currentUserID, trip),
                //   onPressed: () {
                //     if (trip.favorite.contains(userService.currentUserID)){
                //       CloudFunction().removeFavoriteFromTrip(trip.documentId);
                //     } else {
                //       CloudFunction().addFavoriteTrip(trip.documentId);
                //     }
                //   },
                // ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExploreBasic(trip: trip,)),
                  );
                },
              ),
          ),
          Flexible(
            flex: 2,
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

