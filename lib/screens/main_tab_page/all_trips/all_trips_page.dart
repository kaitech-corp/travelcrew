import 'package:flutter/material.dart';

import 'layout_items/ad_list_us.dart';
import 'layout_items/suggestions_list.dart';
import 'layout_items/trip_list.dart';


/// All public trips page
class AllTrips extends StatefulWidget {
  @override
  _AllTripsState createState() => _AllTripsState();
}

class _AllTripsState extends State<AllTrips>
    with SingleTickerProviderStateMixin<AllTrips> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                  style: Theme.of(context).textTheme.headline3,
                  children: [
                    const TextSpan(
                        text: " What's",
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
            SliverGridTripList(),
            RichText(
              text: TextSpan(
                  style: Theme.of(context).textTheme.headline3,
                  children: [
                    const TextSpan(
                        text: " U.S.",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            fontSize: 28)),
                    TextSpan(
                      text: " Destinations",
                      style: Theme.of(context).textTheme.headline6,
                    ),

                  ]),
            ),
            SliverGridAdList(),
            RichText(
              text: TextSpan(
                  style: Theme.of(context).textTheme.headline3,
                  children: [
                    const TextSpan(
                        text: " Friend",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                            fontSize: 28)),
                    TextSpan(
                      text: " Recommendations",
                      style: Theme.of(context).textTheme.headline6,
                    ),

                  ]),
            ),
            SliverGridTripSuggestionList(),
          ],
        ),
      ),
    );
  }
}





