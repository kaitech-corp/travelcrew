import 'package:flutter/material.dart';

import '../../../services/widgets/appearance_widgets.dart';
import 'layout_items/suggestions_list.dart';
import 'layout_items/trip_list.dart';

/// All public trips page
class AllTrips extends StatefulWidget {
  const AllTrips({Key? key}) : super(key: key);

  @override
  State<AllTrips> createState() => _AllTripsState();
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
          children: <Widget>[
            RichText(
              text: TextSpan(
                  style: responsiveTextStyleTopics(context),
                  children: <TextSpan>[
                    TextSpan(
                      text: " What's",
                      style: responsiveTextStyleTopics(context).copyWith(
                        color: Colors.greenAccent,
                      ),
                    ),
                    TextSpan(
                      text: ' New',
                      style: responsiveTextStyleTopicsSub(context),
                    ),
                  ]),
            ),
            const SliverGridTripList(
              isPast: false,
            ),
            RichText(
              text: TextSpan(
                  // style: ,
                  children: <TextSpan>[
                    TextSpan(
                      text: ' Past',
                      style: responsiveTextStyleTopics(context).copyWith(
                        color: Colors.redAccent,
                      ),
                    ),
                    TextSpan(
                      text: ' Gems',
                      style: responsiveTextStyleTopicsSub(context),
                    ),
                  ]),
            ),
            const SliverGridTripList(
              isPast: true,
            ),
            RichText(
              text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: ' Friend',
                  style: responsiveTextStyleTopics(context).copyWith(
                    color: Colors.orangeAccent,
                  ),
                ),
                TextSpan(
                  text: ' Recommendations',
                  style: responsiveTextStyleTopicsSub(context),
                ),
              ]),
            ),
            const SliverGridTripSuggestionList(),
          ],
        ),
      ),
    );
  }
}
