import 'package:flutter/material.dart';

import '../../../models/trip_model.dart';
import 'crew_trip_card.dart';

/// Grouped list view for current past and private trips
class GroupedListTripView extends StatefulWidget {
  const GroupedListTripView(
      {Key? key, required this.data, required this.isPast})
      : super(key: key);
  final List<Trip> data;
  final bool isPast;

  @override
  State<GroupedListTripView> createState() => _GroupedListTripViewState();
}

class _GroupedListTripViewState extends State<GroupedListTripView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.data.length,
        itemBuilder: (BuildContext context, int index) {
          final Trip trip = widget.data[index];
          return CrewTripCard(
            trip: trip,
            heroTag: trip.urlToImage,
          );
        });
  }
}
