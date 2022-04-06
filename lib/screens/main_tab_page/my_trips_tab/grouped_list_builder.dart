import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../../models/trip_model.dart';
import '../../../services/functions/tc_functions.dart';
import 'crew_trip_card.dart';

/// Grouped list view for current past and private trips
class GroupedListTripView extends StatefulWidget {
  final dynamic data;
  final bool isPast;
  const GroupedListTripView({Key key, this.data, this.isPast})
      : super(key: key);

  @override
  _GroupedListTripViewState createState() => _GroupedListTripViewState();
}

class _GroupedListTripViewState extends State<GroupedListTripView> {
  @override
  Widget build(BuildContext context) {
    return GroupedListView<Trip, String>(
      elements: widget.data,
      groupBy: (trip) => DateTime(trip.endDateTimeStamp.toDate().year,
              trip.endDateTimeStamp.toDate().month)
          .toString(),
      order: widget.isPast ? GroupedListOrder.DESC : GroupedListOrder.ASC,
      groupSeparatorBuilder: (trip) => Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Center(
            child: Text(
          TCFunctions().dateToYearMonthFromTimestamp(
              Timestamp.fromDate(DateTime.parse(trip))),
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(color: Colors.black54),
        )),
      ),
      itemComparator: (a, b) =>
          (a.startDateTimeStamp.compareTo(b.startDateTimeStamp)),
      itemBuilder: (context, trip) {
        return CrewTripCard(
          trip: trip,
          heroTag: trip.urlToImage,
        );
      },
    );
  }
}
