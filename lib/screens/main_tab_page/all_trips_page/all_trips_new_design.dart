import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/analytics_service.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/size_config/size_config.dart';


bool animatePress = false;


class AllTripsNewDesign extends StatefulWidget{


  @override
  _AllTripsNewDesignState createState() => _AllTripsNewDesignState();
}
final AnalyticsService _analyticsService = AnalyticsService();

class _AllTripsNewDesignState extends State<AllTripsNewDesign> with SingleTickerProviderStateMixin<AllTripsNewDesign>{


  // @override
  // bool get wantKeepAlive => true;


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
                        TextSpan(text: "What's",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 28)),
                        TextSpan(text: " New",style: Theme.of(context).textTheme.headline4,),
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
              ],
            ),
            SliverGridList(),
          ],
        ),
      ),
    );
  }
}


class SliverGridList extends StatefulWidget {

  var tripPopUp;

  // bool _showCard = false;

  @override
  _SliverGridListState createState() => _SliverGridListState();
}

class _SliverGridListState extends State<SliverGridList> {

  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();


  @override
  Widget build(BuildContext context) {

    final trips = Provider.of<List<Trip>>(context);
    final tripAds = Provider.of<List<TripAds>>(context);
    List<Trip> trips2 = [];
    List<Trip> trips4 = [];
    List<int> thirdItemList = [];
    List<dynamic> combinedList = [];

    if (trips != null) {
      var trips3 = trips.where((trip) =>
      !trip.accessUsers.contains(userService.currentUserID));
//Logic to display trips from latest date created minus trips for user or blocked trips
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
            var j = (i < 10) ? i : (i- 9);
            combinedList.insert(thirdItemList[i], tripAds[j]);
          }
        } catch (e){
          // print(e.toString());
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
                return combinedList[index] is Trip ? (combinedList[index].urlToImage.isEmpty ? cardWithoutImage(context, combinedList[index]) : cardWithImage(context, combinedList[index]) ): adCard(context,combinedList[index]);
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
              ],
            ),
      ),
    );
  }
  Widget adCard(BuildContext context, TripAds tripAds){
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

  Widget cardWithImage(BuildContext context, Trip trip) {


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
          navigationService.navigateTo(ExploreBasicRoute,arguments: trip);
        },
        // onLongPress: (){
        //   setState(() {
        //     widget._showCard = true;
        //     widget.tripPopUp = trip;
        //   });
        // },
        // onLongPressEnd: (details) {
        //   setState(() {
        //     widget._showCard = false;
        //   });
        // },
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
Widget cardWithoutImage(BuildContext context, Trip trip) {

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
              Colors.blue.shade50,
              Colors.lightBlueAccent.shade200
            ]
        ),
      ):
      BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade700,
              Color(0xAA2D3D49)
            ]
        ),
      ),
      child: Column(
        children: [
          Flexible(
            flex: 4,
            child: Tooltip(
              message: '${trip.tripName}',
              child: ListTile(
                title: Text((trip.tripName),style: TextStyle(fontFamily:'RockSalt', fontSize: 18, color: Colors.black), maxLines: 2, overflow: TextOverflow.ellipsis,),
                subtitle: Text("${trip.travelType}",
                  textAlign: TextAlign.start,style: Theme.of(context).textTheme.headline5, maxLines: 1, overflow: TextOverflow.ellipsis,),
                trailing: Text('${TCFunctions().dateToMonthDay(trip.startDate)} - ${trip.endDate}',style: Theme.of(context).textTheme.headline5,),
                onTap: () {
                  _analyticsService.viewedTrip();
                  navigationService.navigateTo(ExploreBasicRoute,arguments: trip);
                },
              ),
            ),
          ),
          Flexible(
            flex: 2,
              child: ListTile(
                // title: Text('${trip.startDate}',style: Theme.of(context).textTheme.headline5,),
                title: Text('${trip.displayName}',style: Theme.of(context).textTheme.headline5, maxLines: 1, overflow: TextOverflow.ellipsis,),
                onTap: () {
                  navigationService.navigateTo(ExploreBasicRoute,arguments: trip);
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

