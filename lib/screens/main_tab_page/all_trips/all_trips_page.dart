import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/blocs/all_trips_bloc/all_trip_event.dart';
import 'package:travelcrew/blocs/all_trips_bloc/all_trip_state.dart';
import 'package:travelcrew/blocs/all_trips_bloc/all_trips_bloc.dart';
import 'package:travelcrew/blocs/trip_ad_bloc/trip_ad_bloc.dart';
import 'package:travelcrew/blocs/trip_ad_bloc/trip_ad_event.dart';
import 'package:travelcrew/blocs/trip_ad_bloc/trip_ad_state.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/services/analytics_service.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/size_config/size_config.dart';

import 'ad_card.dart';

class AllTrips extends StatefulWidget{


  @override
  _AllTripsState createState() => _AllTripsState();
}
final AnalyticsService _analyticsService = AnalyticsService();

class _AllTripsState extends State<AllTrips> with SingleTickerProviderStateMixin<AllTrips>{

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
                        TextSpan(text: " New",style: Theme.of(context).textTheme.headline6,),
                      ]
                  ),
                ),
                Row(
                  children: [
                    Container(
                        height: SizeConfig.screenWidth*.025,
                        width: SizeConfig.screenWidth*.025,
                        child: Image.asset(starImage)),
                    Text('Suggestion',style: Theme.of(context).textTheme.subtitle1,)
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

  // var tripPopUp;

  // bool _showCard = false;

  @override
  _SliverGridListState createState() => _SliverGridListState();
}

class _SliverGridListState extends State<SliverGridList> {

  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  AllTripBloc allTripBloc;
  TripAdBloc tripAdBloc;

  @override
  void initState() {
    super.initState();
    allTripBloc = BlocProvider.of<AllTripBloc>(context);
    allTripBloc.add(LoadingData());
    tripAdBloc = BlocProvider.of<TripAdBloc>(context);
    tripAdBloc.add(LoadingTripAdData());
  }

  @override
  void dispose() {
    // allTripBloc.close();
    // tripAdBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return BlocBuilder<AllTripBloc, TripState>(
      builder: (context, state){
        if(state is TripLoadingState){
          return Loading();
        } else if (state is TripHasDataState){
          List<Trip> tripList = state.data;
          return BlocBuilder<TripAdBloc,TripAdState>(
              builder: (context, state) {
                if (state is TripAdLoadingState) {
                  List<dynamic> combinedList = [];
                  combinedList.addAll(tripList);
                  return Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: CustomScrollView(
                        slivers: [
                          SliverStaggeredGrid.countBuilder(
                            crossAxisCount: 3,
                            mainAxisSpacing: 1,
                            crossAxisSpacing: 1,
                            itemCount: combinedList.length,
                            itemBuilder: (context, index) {
                              return combinedList[index] is Trip ?
                              (combinedList[index].urlToImage.isEmpty ?
                              cardWithoutImage(context, combinedList[index]) :
                              cardWithImage(context, combinedList[index]))
                                  : AdCard(tripAds: combinedList[index]);
                            },
                            staggeredTileBuilder: (index) {
                              if (combinedList[index] is Trip) {
                                if (combinedList[index].urlToImage.isNotEmpty) {
                                  return StaggeredTile.count(3, 3);
                                } else {
                                  return StaggeredTile.count(3, 1);
                                }
                              } else {
                                return StaggeredTile.count(3, 3);
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  );
                } else if (state is TripAdHasDataState) {
                  List<TripAds> adList = state.data;
                  List<dynamic> combinedList = [];
                  combinedList.addAll(tripList);
                  combinedList.addAll(adList);
                  return Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: CustomScrollView(
                        slivers: [
                          SliverStaggeredGrid.countBuilder(
                            crossAxisCount: 3,
                            mainAxisSpacing: 1,
                            crossAxisSpacing: 1,
                            itemCount: combinedList.length,
                            itemBuilder: (context, index) {
                              return combinedList[index] is Trip ?
                              (combinedList[index].urlToImage.isEmpty ?
                              cardWithoutImage(context, combinedList[index]) :
                              cardWithImage(context, combinedList[index]))
                                  : AdCard(tripAds: combinedList[index]);
                            },
                            staggeredTileBuilder: (index) {
                              if (combinedList[index] is Trip) {
                                if (combinedList[index].urlToImage.isNotEmpty) {
                                  return StaggeredTile.count(3, 3);
                                } else {
                                  return StaggeredTile.count(3, 1);
                                }
                              } else {
                                return StaggeredTile.count(3, 3);
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  );
                }else {
                  return Container();
                }
              });
        } else {
          return Container();
        }
      },
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
              child: TextButton(
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
      margin: const EdgeInsets.only(left: 15,right: 15, bottom: 15, top: 10),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tooltip(
            message: '${trip.tripName}',
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 15,right: 5),
              title: Text((trip.tripName),style: TextStyle(fontFamily:'RockSalt', color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis,),
              subtitle: Text('${trip.displayName}',style: Theme.of(context).textTheme.subtitle1, maxLines: 1, overflow: TextOverflow.ellipsis,),
              trailing: TextButton(
                child: favorite(userService.currentUserID, trip),
                onPressed: () {
                  if (trip.favorite.contains(userService.currentUserID)){
                    CloudFunction().removeFavoriteFromTrip(trip.documentId);
                  } else {
                    CloudFunction().addFavoriteTrip(trip.documentId);
                  }
                },
              ),
              onTap: () {
                _analyticsService.viewedTrip();
                navigationService.navigateTo(ExploreBasicRoute,arguments: trip);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15,right: 5),
            child: Text('${TCFunctions().dateToMonthDay(trip.startDate)} - ${trip.endDate}',style: Theme.of(context).textTheme.subtitle2,),
          ),
          Align(
            alignment: Alignment.bottomRight,
            // child:
          ),
          const Padding(padding: EdgeInsets.only(bottom: 10)),
        ],
      ),
    ),
  );
}

