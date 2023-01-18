
// ignore_for_file: only_throw_errors

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
