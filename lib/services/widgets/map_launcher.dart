// import 'package:map_launcher/map_launcher.dart';
//
// import '../../models/activity_model.dart';
//
// class MapLauncherWidget {
//
//   Future<void> openMap(ActivityData activity) async {
//     final availableMaps = await MapLauncher.installedMaps;
//
//     await availableMaps.first.showMarker(
//       coords: Coords(activity, lng),
//       title: "Ocean Beach",
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapSearch {
  Future<void> searchAddress(String address,BuildContext context) async {
    // Android
    String url = 'geo:0,0?q=$address';

    // iOS
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      url = 'maps://?q=$address';
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}