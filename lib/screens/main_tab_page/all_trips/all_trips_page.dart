import 'package:flutter/material.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';

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
                  style: responsiveTextStyleTopics(context),
                  children: [
                    TextSpan(
                        text: " What's",
                        style: responsiveTextStyleTopics(context).copyWith(color: Colors.greenAccent,),),
                    TextSpan(
                      text: ' New',
                      style: responsiveTextStyleTopicsSub(context),
                    ),
                  ]),
            ),
            SliverGridTripList(),
            RichText(
              text: TextSpan(
                  // style: ,
                  children: [
                    TextSpan(
                        text: " Nature",
                        style: responsiveTextStyleTopics(context).copyWith(color: Colors.redAccent,),),

                        // TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.redAccent,
                        //     fontSize: 28)),
                    TextSpan(
                      text: " Lovers",
                      style: responsiveTextStyleTopicsSub(context),
                    ),
                  ]),
            ),
            SliverGridAdList(),
            RichText(
              text: TextSpan(
                  children: [
                    TextSpan(
                        text: " Friend",
                        style: responsiveTextStyleTopics(context).copyWith(color: Colors.orangeAccent,),),
                    TextSpan(
                      text: " Recommendations",
                      style: responsiveTextStyleTopicsSub(context),
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





