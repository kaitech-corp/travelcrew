import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/generics/generic_bloc.dart';
import '../../../../blocs/generics/generic_state.dart';
import '../../../../blocs/generics/generics_event.dart';
import '../../../../models/trip_model.dart';
import '../../../../repositories/trip_repositories/all_trip_repository.dart';

import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../../../../services/functions/tc_functions.dart';
import '../../../../services/navigation/route_names.dart';
import '../../../../services/theme/text_styles.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';

class SliverGridTripList extends StatefulWidget {
  const SliverGridTripList({Key? key, required this.isPast}) : super(key: key);
  final bool isPast;

  @override
  State<SliverGridTripList> createState() => _SliverGridTripListState();
}

class _SliverGridTripListState extends State<SliverGridTripList> {
  late GenericBloc<Trip, AllTripsRepository> allTripBloc;

  int crossAxisCount = 2;
  int count = 3;

  @override
  void initState() {
    super.initState();
    allTripBloc =
        BlocProvider.of<GenericBloc<Trip, AllTripsRepository>>(context);
    allTripBloc.add(LoadingGenericData());
  }

  @override
  void dispose() {
    allTripBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (SizeConfig.tablet) {
      setState(() {
        crossAxisCount = 4;
        count = 2;
      });
    }

    return BlocBuilder<GenericBloc<Trip, AllTripsRepository>, GenericState>(
        builder: (BuildContext context, GenericState state) {
      if (state is LoadingState) {
        return const Flexible(child: Loading());
      } else if (state is HasDataState) {
        final List<Trip> result = state.data as List<Trip>;
        final List<Trip> tripList = (widget.isPast)
            ? result
                .where((Trip trip) =>
                    trip.endDateTimeStamp.toDate().isBefore(DateTime.now()))
                .toList()
                // .sublist(0,20)
                .where((Trip trip) => trip.urlToImage.isNotEmpty)
                .toList()
            : result
                .where((Trip trip) =>
                    trip.endDateTimeStamp.toDate().isAfter(DateTime.now()))
                .toList();
        return SizedBox(
          height: SizeConfig.screenWidth * .55,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: List<Widget>.generate(tripList.length, (int index) {
              return tripList[index].urlToImage.isEmpty
                  ? cardWithoutImage(context, tripList[index])
                  : cardWithImage(context, tripList[index]);
            }),
          ),
        );
      } else {
        return Container();
      }
    });
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
          navigationService.navigateTo(ExploreBasicRoute, arguments: trip);
        },
        child: Hero(
          tag: trip.urlToImage,
          transitionOnUserGestures: true,
          child: Container(
            height: SizeConfig.screenWidth * .5,
            width: SizeConfig.screenWidth * .5,
            margin:
                const EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 10),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(trip.urlToImage), fit: BoxFit.fill),
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

    return GestureDetector(
      onTap: () {
        navigationService.navigateTo(ExploreBasicRoute, arguments: trip);
      },
      child: InkWell(
        key: Key(trip.documentId),
        splashColor: Colors.blue.withAlpha(30),
        child: Container(
          height: SizeConfig.screenWidth * .5,
          width: SizeConfig.screenWidth * .5,
          margin:
              const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Colors.blue.shade50,
                  Colors.lightBlueAccent.shade200
                ]),
          ),
          child: Stack(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Tooltip(
                  message: trip.tripName,
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 15, right: 5),
                    title: Text(
                      trip.tripName,
                      style: const TextStyle(
                          fontFamily: 'RockSalt', color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: (SizeConfig.tablet) ? 2 : 1,
                    ),
                    subtitle: Text(
                      trip.displayName,
                      style: titleMedium(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: (SizeConfig.tablet) ? 2 : 1,
                    ),
                    // trailing:
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 5),
                  child: Text(
                    '${TCFunctions().dateToMonthDay(trip.startDate)} - ${trip.endDate}',
                    style: titleSmall(context),
                    textScaleFactor: (SizeConfig.tablet) ? 2 : 1,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    if (trip.favorite.contains(userService.currentUserID)) {
                      CloudFunction().removeFavoriteFromTrip(trip.documentId);
                    } else {
                      CloudFunction().addFavoriteTrip(trip.documentId);
                    }
                  },
                  child: favorite(
                    userService.currentUserID,
                    trip,
                  ),
                ),
              ),
            ],
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
