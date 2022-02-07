import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/generics/generic_state.dart';
import '../../../blocs/generics/generics_event.dart';
import '../../../models/custom_objects.dart';
import '../../../models/trip_model.dart';
import '../../../repositories_v2/trip_ad_repository.dart';
import '../../../repositories_v2/trip_repositories/all_trip_repository.dart';
import '../../../services/analytics_service.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/locator.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/widgets/loading.dart';
import '../../../size_config/size_config.dart';
import 'ad_card.dart';


/// All public trips
class AllTrips extends StatefulWidget {
  @override
  _AllTripsState createState() => _AllTripsState();
}

final AnalyticsService _analyticsService = AnalyticsService();

class _AllTripsState extends State<AllTrips>
    with SingleTickerProviderStateMixin<AllTrips> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: SizeConfig.screenHeight,
        margin: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      style: Theme.of(context).textTheme.headline3,
                      children: [
                        const TextSpan(
                            text: "What's",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                                fontSize: 28)),
                        TextSpan(
                          text: ' New',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ]),
                ),
                Row(
                  children: [
                    SizedBox(
                        height: SizeConfig.screenWidth * .03,
                        width: SizeConfig.screenWidth * .03,
                        child: Image.asset(starImage)),
                    Text(
                      'Suggestion',
                      style: Theme.of(context).textTheme.subtitle1,
                    )
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
  UserPublicProfile currentUserProfile =
      locator<UserProfileService>().currentUserProfileDirect();

  GenericBloc<Trip,AllTripsRepository> allTripBloc;
  GenericBloc<TripAds,TripAdRepository>  tripAdBloc;

  int crossAxisCount = 3;
  int count = 3;

  @override
  void initState() {
    super.initState();
    allTripBloc = BlocProvider.of<GenericBloc<Trip,AllTripsRepository>>(context);
    allTripBloc.add(LoadingGenericData());
    tripAdBloc = BlocProvider.of<GenericBloc<TripAds,TripAdRepository>>(context);
    tripAdBloc.add(LoadingGenericData());
  }

  @override
  Widget build(BuildContext context) {
    if (SizeConfig.tablet) {
      setState(() {
        crossAxisCount = 4;
        count = 2;
      });
    }

    return BlocBuilder<GenericBloc<Trip,AllTripsRepository>, GenericState>(
      builder: (context, state) {
        if (state is LoadingState) {
          return Expanded(child: Loading());
        } else if (state is HasDataState<Trip>) {
          List<Trip> tripList = state.data;
          return BlocBuilder<GenericBloc<TripAds,TripAdRepository>, GenericState>(
              builder: (context, state) {
            if (state is LoadingState) {
              List<dynamic> combinedList = [];
              combinedList.addAll(tripList);
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: CustomScrollView(
                    slivers: [
                      SliverStaggeredGrid.countBuilder(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        itemCount: combinedList.length,
                        itemBuilder: (context, index) {
                          return combinedList[index] is Trip
                              ? (combinedList[index].urlToImage.isEmpty
                                  ? cardWithoutImage(
                                      context, combinedList[index])
                                  : cardWithImage(context, combinedList[index]))
                              : AdCard(tripAds: combinedList[index]);
                        },
                        staggeredTileBuilder: (index) {
                          if (combinedList[index] is Trip) {
                            if (combinedList[index].urlToImage.isNotEmpty) {
                              return StaggeredTile.count(
                                  count, count.toDouble());
                            } else {
                              return StaggeredTile.count(count, 1);
                            }
                          } else {
                            return StaggeredTile.count(count, count.toDouble());
                          }
                        },
                      )
                    ],
                  ),
                ),
              );
            } else if (state is HasDataState) {
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
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        itemCount: combinedList.length,
                        itemBuilder: (context, index) {
                          return combinedList[index] is Trip
                              ? (combinedList[index].urlToImage.isEmpty
                                  ? cardWithoutImage(
                                      context, combinedList[index])
                                  : cardWithImage(context, combinedList[index]))
                              : AdCard(tripAds: combinedList[index]);
                        },
                        staggeredTileBuilder: (index) {
                          if (combinedList[index] is Trip) {
                            if (combinedList[index].urlToImage.isNotEmpty) {
                              return StaggeredTile.count(
                                  count, count.toDouble());
                            } else {
                              return StaggeredTile.count(count, 1);
                            }
                          } else {
                            return StaggeredTile.count(count, count.toDouble());
                          }
                        },
                      )
                    ],
                  ),
                ),
              );
            } else {
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
    Icon favorite(String uid, Trip trip) {
      if (trip.favorite.contains(uid)) {
        return const Icon(
          Icons.favorite,
          color: Colors.red,
          size: 30,
        );
      } else {
        return const Icon(
          Icons.favorite_border,
          color: Colors.white,
          size: 30,
        );
      }
    }

    return InkWell(
      key: Key(trip.documentId),
      splashColor: Colors.blue.withAlpha(30),
      child: GestureDetector(
        onTap: () {
          _analyticsService.viewedTrip();
          navigationService.navigateTo(ExploreBasicRoute, arguments: trip);
        },
        child: Hero(
          tag: trip.urlToImage,
          transitionOnUserGestures: true,
          child: Container(
            margin:
                const EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 10),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  trip.urlToImage,
                ),
                fit: BoxFit.fill,
              ),
              color: const Color(0xAA91AFD0), //
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    if (trip.favorite.contains(userService.currentUserID)) {
                      CloudFunction().removeFavoriteFromTrip(trip.documentId);
                    } else {
                      CloudFunction().addFavoriteTrip(trip.documentId);
                    }
                  },
                  child: favorite(userService.currentUserID, trip),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool onLikedButtonTapped(Trip trip, bool isLiked) {
    if (trip.favorite.contains(userService.currentUserID)) {
            CloudFunction().removeFavoriteFromTrip(trip.documentId);

            return false;
          } else {
            CloudFunction().addFavoriteTrip(trip.documentId);
            return true;
          }
  }
}

Widget cardWithoutImage(BuildContext context, Trip trip) {
  Icon favorite(String uid, Trip trip) {
    if (trip.favorite.contains(uid)) {
      return const Icon(
        Icons.favorite,
        color: Colors.red,
        size: 30,
      );
    } else {
      return const Icon(
        Icons.favorite_border,
        color: Colors.white,
        size: 30,
      );
    }
  }

  return InkWell(
    key: Key(trip.documentId),
    splashColor: Colors.blue.withAlpha(30),
    child: Container(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.lightBlueAccent.shade200]),
      ),
      child: Stack(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Tooltip(
              message: '${trip.tripName}',
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 15, right: 5),
                title: Text(
                  (trip.tripName),
                  style: const TextStyle(fontFamily: 'RockSalt', color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor: (SizeConfig.tablet) ? 2 : 1,
                ),
                subtitle: Text(
                  '${trip.displayName}',
                  style: Theme.of(context).textTheme.subtitle1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor: (SizeConfig.tablet) ? 2 : 1,
                ),
                trailing: TextButton(
                  onPressed: () {
                    if (trip.favorite.contains(userService.currentUserID)) {
                      CloudFunction().removeFavoriteFromTrip(trip.documentId);
                    } else {
                      CloudFunction().addFavoriteTrip(trip.documentId);
                    }
                  },
                  child: favorite(
                    userService.currentUserID,
                    trip,),
                ),
                onTap: () {
                  _analyticsService.viewedTrip();
                  navigationService.navigateTo(ExploreBasicRoute,
                      arguments: trip);
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: Text(
                '${TCFunctions().dateToMonthDay(trip.startDate)} - ${trip.endDate}',
                style: Theme.of(context).textTheme.subtitle2,
                textScaleFactor: (SizeConfig.tablet) ? 2 : 1,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
