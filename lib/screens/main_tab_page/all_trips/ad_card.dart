import 'package:flutter/material.dart';

import '../../../models/custom_objects.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/widgets/link_previewer.dart';
import '../../../size_config/size_config.dart';


/// Layout for trip Ads
class AdCard extends StatelessWidget{

  const AdCard({Key? key, required this.tripAds}) : super(key: key);

  final DestinationModel tripAds;

  @override
  Widget build(BuildContext context) {

    return InkWell(
      key: Key(tripAds.name!),
      splashColor: Colors.blue.withAlpha(30),

      child: GestureDetector(
        onTap: () {
          TCFunctions().launchURL(tripAds.url!);
          // CloudFunction().updateClicks(tripAds.documentID);
        },
        child: Container (
          height: SizeConfig.screenWidth*.5,
          width: SizeConfig.screenWidth*.5,
          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 10),
          decoration: const BoxDecoration(
            // image: DecorationImage(
            //   image:
            //   fit: BoxFit.fill,
            // ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
          ),
          child: ViewAnyLink(
            link: tripAds.url!,
            function: () => <void>{},
          ),
        ),
      ),
    );
  }
}
