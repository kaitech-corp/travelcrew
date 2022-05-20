import 'package:flutter/material.dart';

import '../../../models/custom_objects.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../size_config/size_config.dart';


/// Layout for trip Ads
class AdCard extends StatelessWidget{

  final TripAds tripAds;

  const AdCard({Key key, this.tripAds}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return InkWell(
      key: Key(tripAds.documentID),
      splashColor: Colors.blue.withAlpha(30),

      child: GestureDetector(
        onTap: () {
          TCFunctions().launchURL(tripAds.link);
          CloudFunction().updateClicks(tripAds.documentID);
        },
        child: Container (
          height: SizeConfig.screenWidth*.5,
          width: SizeConfig.screenWidth*.5,
          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 10),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(tripAds.urlToImage,),
              fit: BoxFit.fill,
            ),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
          ),
        ),
      ),
    );
  }
}
