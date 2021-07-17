import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/size_config/size_config.dart';

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
}
